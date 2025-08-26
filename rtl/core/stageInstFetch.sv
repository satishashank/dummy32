`timescale 1ns/1ps
module stageInstFetch (
    input logic clk,
    input logic rst,

    input logic bPredictTaken,
    input logic usePredictor,
    input logic pcSelE,
    input logic flushF2, //took a wrong branch from exec
    input logic stall,
    input logic [31:0] btbTarget,
    input logic [31:0] pcTargetE,

    output logic [31:0] imemAddr,
    input logic [31:0] imemData,
    output logic imemRen,

    output logic [31:0] instr,
    output logic [31:0] pcPlus4,
    output logic [31:0] pc,
    output logic bPredictedTaken
  );

  logic [31:0] pcSv1,pcSv2,pcPlus4Sv1,pcPlus4Sv2,pcIp;

  assign pcPlus4Sv1 = pcSv1 + 4;
  assign imemAddr = pcSv1;
  assign imemRen = !rst;
  assign instr = !flushF2?imemData:0; //imm data 1 cylce delay
  assign bPredictedTaken = usePredictor&bPredictTaken;
  assign pc = pcSv2;
  assign pcPlus4 = pcPlus4Sv2;

  always_comb
  begin
    if(usePredictor)
    begin
      case ({flushF2,bPredictTaken}) //check branches
        2'b10,2'b11:
          pcIp = pcTargetE;
        2'b01:
          pcIp = btbTarget;
        default:
          pcIp = pcPlus4Sv1;
      endcase
    end
    else
      pcIp = pcSelE?pcTargetE:pcPlus4Sv1;
  end



  always_ff@(posedge clk)
  begin
    if (rst)
    begin
      pcSv2 <= 0;
      pcPlus4Sv2 <= 0;
      pcSv1 <= 0;
    end
    else
    begin
      if (!stall)
      begin : PCreg
        pcSv1 <= pcIp;
        if (flushF2)
        begin
          pcSv2 <= 0;
          pcPlus4Sv2 <= 0;
        end
        else
        begin
          pcSv2 <= pcSv1;
          pcPlus4Sv2 <= pcPlus4Sv1;
        end
      end
    end
  end
endmodule
