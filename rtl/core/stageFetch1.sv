module stageFetch1 (

    input logic [31:0] pcF0,pcPlus4F0,
    input logic clk,rst,
    input logic flush,stall,bPredictedTakenF,
    input logic [31:0] imemRdata,
    output logic imemOen,bPredictedTaken,
    output logic [31:0] pc,pcPlus4,
    output logic [31:0] instr
  );
  assign imemOen = !flush;
  assign instr = imemRdata;

  always_ff@(posedge clk)
    if(rst|flush)
    begin
      pc <= 0;
      pcPlus4<=0;
      bPredictedTaken <= 0;
    end
    else if (!stall)
    begin
      pc <= pcF0;
      pcPlus4 <= pcPlus4F0;
      bPredictedTaken <= bPredictedTakenF;
    end


endmodule
