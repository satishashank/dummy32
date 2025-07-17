module branchPredictor (
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
            logic [24:0] tag;
            logic [31:0] target;
            logic [1:0] counter;
          } btb_entry_t;

  btb_entry_t btb_mem [31:0];
  logic [4:0] fetchIndex;
  logic [24:0]   fetchTag;
  logic [4:0] exIndex;
  logic [24:0]   exTag;
  logic exHit;

  logic [1:0] nextCount,count;
  localparam [1:0]
             sNtaken = 2'b00,
             wNtaken = 2'b01,
             wTaken = 2'b10,
             sTaken = 2'b11;


  assign exIndex = exPc[6:2];
  assign exTag  = exPc[31:7];
  assign fetchIndex = fetchPc[6:2];
  assign fetchTag  = fetchPc[31:7];

  assign fetchHit = (btb_mem[fetchIndex].valid && (btb_mem[fetchIndex].tag == fetchTag))&&btb_mem[fetchIndex].counter[1];
  assign fetchTarget = btb_mem[fetchIndex].target;
  assign exHit = btb_mem[exIndex].valid && (btb_mem[exIndex].tag == exTag);
  assign count = btb_mem[exIndex].counter;

  always_ff@(posedge clk)
  begin
    if ((!rst))
      if(exHit)
      begin
        btb_mem[exIndex].counter <= nextCount;
      end
      else //update mem on the first take/not taken

      begin
        if (exBranch) //only store intentional jumps and branches jal,bne etc
        begin
          btb_mem[exIndex].valid <= 1;
          btb_mem[exIndex].tag <= exTag;
          btb_mem[exIndex].target <= exTarget;
          btb_mem[exIndex].counter <= exTaken?wTaken:wNtaken;
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
