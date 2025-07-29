module branchPredictorGshare#(
    parameter int BTB_ENTRIES = 256,
    parameter int PHT_ENTRIES = 1024,
    parameter int GHR_WIDTH = $clog2(PHT_ENTRIES),
    parameter int BTB_INDEX_WIDTH = $clog2(BTB_ENTRIES),
    parameter int BTB_TAG_WIDTH = 32 - BTB_INDEX_WIDTH
  ) (
    input  logic         clk,
    input  logic         rst,

    // Fetch stage inputs
    input  logic [31:0]  fetchPc,
    output logic         fetchHit,
    output logic [31:0]  fetchTarget,

    // EX stage update inputs
    input  logic         exTaken,
    input logic          exBranch,
    input  logic [31:0]  exPc,
    input  logic [31:0]  exTarget
  );


  typedef struct packed {
            logic valid;
            logic [BTB_TAG_WIDTH-1:0] tag;
            logic [31:0] target;
          } btb_entry;
  typedef struct packed {
            logic [1:0] counter;
          }pht_entry;


  btb_entry btb_mem [BTB_ENTRIES-1:0];
  pht_entry pht_mem [PHT_ENTRIES-1:0];

  logic [GHR_WIDTH-1:0] ghr,pcBitsGhr,phtIndex;
  logic [BTB_INDEX_WIDTH-1:0] fetchIndex;
  logic [BTB_TAG_WIDTH-1:0]   fetchTag;
  logic [BTB_INDEX_WIDTH-1:0] exIndex;
  logic [BTB_TAG_WIDTH-1:0]   exTag;
  logic exHit;

  logic [1:0] nextCount,count;
  localparam [1:0]
             sNtaken = 2'b00,
             wNtaken = 2'b01,
             wTaken = 2'b10,
             sTaken = 2'b11;


  assign exIndex = exPc[BTB_INDEX_WIDTH+1:2];
  assign exTag  = exPc[31:BTB_INDEX_WIDTH];

  assign pcBitsGhr = fetchPc[GHR_WIDTH+1:2];
  assign phtIndex = pcBitsGhr^ghr;
  assign count = pht_mem[phtIndex].counter;


  assign fetchIndex = fetchPc[BTB_INDEX_WIDTH+1:2];
  assign fetchTag  = fetchPc[31:BTB_INDEX_WIDTH];
  assign fetchHit = (btb_mem[fetchIndex].valid && (btb_mem[fetchIndex].tag == fetchTag))&&pht_mem[phtIndex].counter[1];
  assign fetchTarget = btb_mem[fetchIndex].target;
  assign exHit = btb_mem[exIndex].valid && (btb_mem[exIndex].tag == exTag);


  always_ff@(posedge clk)
  begin
    if (!rst)
    begin
      if(exBranch)
      begin
        ghr<= {ghr[GHR_WIDTH-1:1],exTaken}; //Next ghr
        if (exHit)
        begin
          pht_mem[phtIndex].counter <= nextCount; //update PHT
        end
        else //New branch
        begin
          btb_mem[exIndex].valid <= 1;
          btb_mem[exIndex].tag <= exTag;
          btb_mem[exIndex].target <= exTarget;
          pht_mem[phtIndex].counter <= exTaken?wTaken:wNtaken; //First pht entry
        end
      end

    end
  end
  always_comb
  begin
    case (count)
      wTaken:
        nextCount = exTaken?sTaken:wNtaken;
      sTaken:
        nextCount = exTaken?count:wTaken;
      wNtaken:
        nextCount = exTaken?wTaken:sNtaken;
      sNtaken:
        nextCount = exTaken?wNtaken:count;
    endcase
  end

endmodule
