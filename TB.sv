`timescale 1ns/1ps

module TB;

  // Clock and Reset
  logic clk;

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
         .imemRdata(imemRdata),
         .imemAddr(imemAddr),
         .dmemRdata(dmemRdata),
         .dmemWdata(dmemWdata),
         .dmemWen(dmemWen),
         .dmemAddr(dmemAddr)
       );

  // Testbench logic
  initial
  begin
    // Initialize inputs
    imemRdata = 32'h00000000;
    dmemRdata = 32'h00000000;

    // Start waveform dump
    $dumpfile("");
    $dumpvars(0, TB);

    // Run for some time
  end

endmodule
