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
  logic dmemWen;
  logic [31:0] dmemAddr;



  // Instantiate the core module
  core uut (
         .clk(clk),
         .rst(rst),
         .imemRdata(imemRdata),
         .imemAddr(imemAddr),
         .dmemRdata(dmemRdata),
         .dmemWdata(dmemWdata),
         .dmemWen(dmemWen),
         .dmemAddr(dmemAddr)
       );
  imem instr (
         .rAddr(imemAddr),
         .rData(imemRdata)
       );

  initial
  begin
    $dumpfile("");
    $dumpvars(0, TB);

  end

endmodule
