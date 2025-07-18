`timescale 1ns/1ps
module TB;

  // Clock and Reset
  logic clk;
  logic rst;

  // Signals for imem and dmem
  logic [31:0] imemRdata;
  logic [31:0] imemAddr;
  logic [31:0] dmemRdata;
  logic [31:0] dmemWdata;
  logic [2:0] dmemSize;
  logic dmemWen;
  logic [31:0] dmemAddr;
  logic uartWen;
  logic [7:0] uartData;

  assign uartData = dmemWdata[7:0];
  assign uartWen = dmemWen&(dmemAddr == 32'hFFFF_FFFC);





  // Instantiate the core module
  core uut (
         .clk(clk),
         .rst(rst),
         .imemRdata(imemRdata),
         .imemAddr(imemAddr),
         .dmemRdata(dmemRdata),
         .dmemWdata(dmemWdata),
         .dmemSize(dmemSize),
         .dmemWen(dmemWen),
         .dmemAddr(dmemAddr)
       );
  imem instr (
         .clk(clk),
         .rAddr(imemAddr),
         .rData(imemRdata)
       );
  dmem data(
         .wData(dmemWdata),
         .rData(dmemRdata),
         .clk(clk),
         .wEn(dmemWen),
         .addr(dmemAddr),
         .size(dmemSize)
       );
  simUart uart(
            .clk(clk),
            .rst(rst),
            .data(uartData),
            .wEn(uartWen)
          );

  initial
  begin
    $dumpfile("");
    $dumpvars(0, TB);

  end

endmodule
