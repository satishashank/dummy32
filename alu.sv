`timescale 1ns/1ps
module alu(input logic [3:0] aluCntrl,
             input logic inv,
             input logic [31:0] srcA,
             input logic [31:0] srcB,
             output logic [31:0] aluResult,
             output logic branchFlag
            );
  logic zero;
  logic [4:0] srcBlwr;
  assign srcBlwr = srcB[4:0];

  always_comb
  begin
    branchFlag = 0;
    zero = 0;
    case (aluCntrl)
      4'b0000:
        aluResult =  (srcA + srcB);
      4'b1000:
      begin
        aluResult = (srcA - srcB);
        zero = ~(|aluResult);
        branchFlag = inv?~zero:zero;
      end
      4'b0001:
        aluResult = srcA << srcBlwr;
      4'b0010:
      begin
        aluResult = ($signed(srcA) < $signed(srcB))? {31'b0,1'b1} : 0;
        branchFlag = inv?~aluResult[0]:aluResult[0];
      end
      4'b0011:
      begin
        aluResult = ((srcA) < (srcB))? {31'b0,1'b1} : 0;
        branchFlag = inv?~aluResult[0]:aluResult[0];
      end
      4'b0100:
        aluResult = srcA ^ srcB;
      4'b0101:
        aluResult = srcA >> srcBlwr;
      4'b1101:
        aluResult = $signed(srcA) >>> srcBlwr;
      4'b0110:
        aluResult = srcA | srcB;
      4'b0111:
        aluResult = srcA & srcB;
      default:
      begin
        aluResult = 0;
        branchFlag = 0;
      end
    endcase
  end
endmodule
