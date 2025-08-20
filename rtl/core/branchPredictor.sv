module branchPredictor #(
    parameter int BTB_ENTRIES    = 64,
    parameter int TARGET_WIDTH   = 32,
    parameter int COUNTER_WIDTH  = 2,
    parameter int INDEX_WIDTH    = $clog2(BTB_ENTRIES),
    parameter int TAG_WIDTH      = 32 - INDEX_WIDTH
  )(
    input  logic                   clk,
    input  logic                   rst,
    input  logic [31:0]            fetchPc,
    output logic                   fetchHit,
    output logic [TARGET_WIDTH-1:0] fetchTarget,
    input  logic                   exTaken,
    input  logic                   exBranch,
    input  logic [31:0]            exPc,
    input  logic [TARGET_WIDTH-1:0] exTarget
  );

  // Memory layout: [TAG | TARGET | COUNTER | VALID]
  localparam int VALID_BIT     = 0;
  localparam int COUNTER_LSB   = VALID_BIT + 1;
  localparam int COUNTER_MSB   = COUNTER_LSB + COUNTER_WIDTH - 1;
  localparam int TARGET_LSB    = COUNTER_MSB + 1;
  localparam int TARGET_MSB    = TARGET_LSB + TARGET_WIDTH - 1;
  localparam int TAG_LSB       = TARGET_MSB + 1;
  localparam int TAG_MSB       = TAG_LSB + TAG_WIDTH - 1;
  localparam int MEM_WIDTH     = TAG_MSB + 1;

  logic [MEM_WIDTH-1:0] btb_mem [BTB_ENTRIES-1:0];

  logic [INDEX_WIDTH-1:0] fetchIndex, exIndex;
  logic [TAG_WIDTH-1:0] fetchTag, exTag;
  logic [TAG_WIDTH-1:0] fetchTagBtb, exTagBtb;
  logic [COUNTER_WIDTH-1:0] fetchCounter, exCounter;

  logic [MEM_WIDTH-1:0] fetchEntry, exEntry_, exEntryUpdated;
  logic [1:0] count, nextCount;
  logic exHit;

  assign fetchIndex = fetchPc[INDEX_WIDTH+1:2];
  assign exIndex    = exPc[INDEX_WIDTH+1:2];

  assign fetchEntry = btb_mem[fetchIndex];
  assign exEntry_   = btb_mem[exIndex];

  assign fetchTag   = fetchPc[31:INDEX_WIDTH];
  assign exTag      = exPc[31:INDEX_WIDTH];

  assign fetchTagBtb = fetchEntry[TAG_MSB:TAG_LSB];
  assign exTagBtb    = exEntry_[TAG_MSB:TAG_LSB];

  assign fetchCounter = fetchEntry[COUNTER_MSB:COUNTER_LSB];
  assign exCounter    = exEntry_[COUNTER_MSB:COUNTER_LSB];

  assign fetchHit    = fetchEntry[VALID_BIT] && (fetchTagBtb == fetchTag) && (!fetchCounter[0]);
  assign fetchTarget = fetchEntry[TARGET_MSB:TARGET_LSB];
  assign exHit       = exEntry_[VALID_BIT] && (exTagBtb == exTag);
  assign count       = exCounter;

  localparam [1:0]
             sTaken = 2'b10,
             wTaken = 2'b00, //default taken
             wNtaken = 2'b01,
             sNtaken = 2'b11;


  always_comb
  begin
    case (count)
      wTaken:
        nextCount = exTaken ? sTaken : wNtaken;
      sTaken:
        nextCount = exTaken ? sTaken : wTaken;
      wNtaken:
        nextCount = exTaken ? wTaken : sNtaken;
      sNtaken:
        nextCount = exTaken ? wNtaken : sNtaken;
      default:
        nextCount = wTaken;
    endcase
  end

  always_comb
  begin
    exEntryUpdated = '0;
    if (exHit)
    begin
      exEntryUpdated = exEntry_;
      exEntryUpdated[COUNTER_MSB:COUNTER_LSB] = nextCount;
    end
    else if (exTaken)
    begin
      exEntryUpdated[VALID_BIT]               = 1'b1;
      exEntryUpdated[TAG_MSB:TAG_LSB]         = exTag;
      exEntryUpdated[TARGET_MSB:TARGET_LSB]   = exTarget;
      exEntryUpdated[COUNTER_MSB:COUNTER_LSB] = wTaken;
    end
  end

  always_ff @(posedge clk)
  begin
    if (!rst)
    begin
      if (exHit | exTaken)
        btb_mem[exIndex] <= exEntryUpdated;
    end
  end

endmodule
