module csr(
    input logic clk,
    input rst,
    input logic isControlxfer,
    input logic wrongBranch
  );
  logic [15:0] nControlxfer;
  logic [15:0] nWrongBranches;

  always_ff@(posedge clk)
  begin
    if(!rst)
    begin
      nControlxfer[14:0] <= isControlxfer?(nControlxfer[14:0] + 1):nControlxfer[14:0];
      nWrongBranches[14:0] <= wrongBranch?(nWrongBranches[14:0] + 1):nWrongBranches[14:0];
      nControlxfer[15] <= &nControlxfer[14:0]&(!nControlxfer[15]) ? 1:0; //full
      nWrongBranches[15] <= &nWrongBranches[14:0]&(!nWrongBranches[15]) ?1:0; //full
    end

  end


endmodule
