module csrFile#(
    parameter int regSize = 16
  )(
    output logic [31:0] csr,
    input logic wEn,
    input logic [31:0] wData,
    input logic [11:0] wAddr,
    input logic  wrongBranch,
    input logic  controlXfer,
    input logic [3:0] readAddr,
    input logic clk
  );

  //Read-only csrs for branch prediction
  logic [31:0] csRegisters [regSize-1:0];
  assign csr = csRegisters[readAddr];

  always_ff@(posedge clk)
  begin
    if(wEn)
    begin
      csRegisters[wAddr[3:0]] <= wData;
    end
    csRegisters[0] <= csRegisters[0] + {30'b0,wrongBranch};
    csRegisters[1] <= csRegisters[1] + {30'b0,controlXfer};
  end



endmodule
