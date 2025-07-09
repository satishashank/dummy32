`timescale 1ns/1ps
module alu(input logic [2:0] aluCntrl,
             input logic useF7,
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
    zero = 0;
    branchFlag = 0;
    case (aluCntrl)
      3'b000:
      begin
        if (useF7)
        begin
          aluResult = ($signed(srcA) - $signed(srcB));
          zero = ~(|aluResult);
          branchFlag = inv?~zero:zero;
        end
        else
        begin
          aluResult =  ($signed(srcA) + $signed(srcB));
        end
      end
      3'b001:
        aluResult = srcA << srcBlwr;
      3'b010:
      begin
        aluResult = ($signed(srcA) < $signed(srcB))? {31'b0,1'b1} : 0;
        branchFlag = inv?~aluResult[0]:aluResult[0];
      end
      3'b011:
      begin
        aluResult = ((srcA) < (srcB))? {31'b0,1'b1} : 0;
        branchFlag = inv?~aluResult[0]:aluResult[0];
      end
      3'b100:
        aluResult = srcA ^ srcB;
      3'b101:
        if (useF7)
        begin
          aluResult = $signed(srcA) >>> srcBlwr;
        end
        else
        begin
          aluResult = srcA >> srcBlwr;
        end
      3'b110:
        aluResult = srcA | srcB;
      3'b111:
        aluResult = srcA & srcB;
      default:
      begin
        aluResult = 0;
        branchFlag = 0;
      end
    endcase
  end
endmodule
