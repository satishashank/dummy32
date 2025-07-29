`timescale 1ns/1ps
module stageInstFetch (
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
    input logic [31:0] imemData,

    output logic [31:0] instr,
    output logic [31:0] pcPlus4,
    output logic [31:0] pc,
    output logic bPredictedTaken
  );

  logic [31:0] pc_;

  assign pcPlus4 = pc + 4;
  assign imemAddr = pc;
  assign instr = imemData; //imm data
  assign bPredictedTaken = usePredictor&bPredictTaken;

  always_comb
  begin
    if(usePredictor)
    begin
      case ({wrongBranchE,bPredictTaken})
        2'b10,2'b11:
          pc_ = pcTargetE;
        2'b01:
          pc_ = btbTarget;
        default:
          pc_ = pcPlus4;
      endcase
    end
    else
      pc_ = pcSelE?pcTargetE:pcPlus4;
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
        pc <= pc_;
      end
    end
  end
endmodule
