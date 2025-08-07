module branchPredictorGshare#(
    parameter int BTB_ENTRIES = 128,
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


  btb_entry btb_mem [BTB_ENTRIES-1:0];
  logic [1:0] pht_mem [PHT_ENTRIES-1:0];

  logic [GHR_WIDTH-1:0] ghr,pcBitsGhrFetch,pcBitsGhrEx,phtIndexEx,phtIndexFetch;
  logic [BTB_INDEX_WIDTH-1:0] fetchIndex;
  logic [BTB_TAG_WIDTH-1:0]   fetchTag;
  logic [BTB_INDEX_WIDTH-1:0] exIndex;
  logic [BTB_TAG_WIDTH-1:0]   exTag;
  logic exHit;

  logic [1:0] nextCount,count,countF;
  localparam [1:0]
             sNtaken = 2'b10,
             wNtaken = 2'b00, //default not taken
             wTaken = 2'b01,
             sTaken = 2'b11;


  assign exIndex = exPc[BTB_INDEX_WIDTH+1:2];
  assign exTag  = exPc[31:BTB_INDEX_WIDTH];

  assign pcBitsGhrFetch = fetchPc[GHR_WIDTH+1:2];
  assign pcBitsGhrEx = exPc[GHR_WIDTH+1:2];

  assign phtIndexFetch = pcBitsGhrFetch^ghr;
  assign phtIndexEx = pcBitsGhrEx^ghr;
  assign count = pht_mem[phtIndexEx];
  assign countF = pht_mem[phtIndexFetch];


  assign fetchIndex = fetchPc[BTB_INDEX_WIDTH+1:2];
  assign fetchTag  = fetchPc[31:BTB_INDEX_WIDTH];
  assign fetchHit = (btb_mem[fetchIndex].valid && (btb_mem[fetchIndex].tag == fetchTag))&&(countF[0]);
  assign fetchTarget = btb_mem[fetchIndex].target;
  assign exHit = btb_mem[exIndex].valid && (btb_mem[exIndex].tag == exTag);


  always_ff@(posedge clk)
  begin
    if (!rst)
    begin
      if(exBranch)
      begin
        ghr <= {ghr[GHR_WIDTH-1:1],exTaken}; //Next ghr
        if (exHit)
        begin
          pht_mem[phtIndexEx] <= nextCount; //update PHT
        end
        else //New branch
        begin
          btb_mem[exIndex].valid <= 1;
          btb_mem[exIndex].tag <= exTag;
          btb_mem[exIndex].target <= exTarget;
          pht_mem[phtIndexEx] <= exTaken?wTaken:wNtaken; //First pht entry
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
