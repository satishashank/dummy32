`timescale 1ns / 1ps
module TB;

  // Clock and Reset
  logic clk;
  logic rst;
  //testing
  logic usePredictor;
  logic uartSout, uartSin;

  soc dummy32 (
      .clk(clk),
      .rst(rst),
      .usePredictor(usePredictor),
      .uartSout(uartSout),
      .uartSin(uartSin)
  );
  initial begin
    $dumpfile("");
    $dumpvars(0, TB);

  end

endmodule
