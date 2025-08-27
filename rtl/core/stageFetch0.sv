`timescale 1ns/1ps
module stageFetch0 (
    input logic clk,
    input logic rst,

    input logic bPredictTaken,
    input logic usePredictor,
    input logic pcSelE,
    input logic wrongBranchE,
    input logic stall,
    input logic [31:0] btbTarget,
    input logic [31:0] pcTargetE,

    output logic [31:0] imemAddr,
    output logic imemRen,

    output logic [31:0] pcPlus4,
    output logic [31:0] pc,
    output logic bPredictedTaken
  );

  logic [31:0] pcIp;

  assign pcPlus4 = pc + 4;
  assign imemAddr = pc;
  assign imemRen = !(rst|stall);
  assign bPredictedTaken = usePredictor&bPredictTaken;

  always_comb
  begin
    if(usePredictor)
    begin
      case ({wrongBranchE,bPredictTaken})
        2'b10,2'b11:
          pcIp = pcTargetE;
        2'b01:
          pcIp = btbTarget;
        default:
          pcIp = pcPlus4;
      endcase
    end
    else
      pcIp = pcSelE?pcTargetE:pcPlus4;
  end



  always_ff@(posedge clk)
  begin
    if (rst)
    begin
      pc <= 0;
    end
    else
    begin
      if (!stall)
      begin : PCreg
        pc <= pcIp;
      end
    end
  end
endmodule
