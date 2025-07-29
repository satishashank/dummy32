module customCsr(
    input logic clk,
    input rst,
    input logic isControlxfer,
    input logic wrongBranch,
    output logic [31:0] csr,
    input logic [4:0] rAddr,
    input logic rEn
  );

  logic [31:0] nControlxfer;
  logic [31:0] nWrongBranches;

  always_ff@(posedge clk)
  begin
    if(!rst)
    begin
      if(isControlxfer)
        nControlxfer <= nControlxfer + 1;
      if(wrongBranch)
        nWrongBranches <= nWrongBranches + 1;
    end

  end


endmodule
