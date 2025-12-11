`timescale 1ns / 1ps
module soc (
    input logic clk,
    input logic rst,
    input usePredictor,
    output uartSout,
    input uartSin
);
  logic [31:0] imemRdata;
  logic [31:0] imemAddr;
  logic imemRen, imemOen;
  logic [31:0] dmemRdata;
  logic [31:0] dmemWdata;
  logic [ 2:0] dmemSize;
  logic dmemWen, dmemRen;
  logic dmemWenFinal;
  logic [31:0] dmemAddr;
  logic uartWen, uartFifoFull;
  logic [7:0] uartData;
  logic clk_cpu;
  // logic locked;

  // clk_wiz_0 clk_gen (
  //    .clk_in1(clk),   // input clock from FPGA pin
  //    .reset(rst),
  //    .clk_out1(clk_cpu),   // say 50 MHz
  //    .locked(locked)       // indicates stable clocks
  // );

  assign clk_cpu = clk;




  core uut (
      .clk(clk_cpu),
      .rst(rst),
      .usePredictor(usePredictor),
      .imemRdata(imemRdata),
      .imemRen(imemRen),
      .imemOen(imemOen),
      .imemAddr(imemAddr),
      .dmemRdata(dmemRdata),
      .dmemRen(dmemRen),
      .dmemWdata(dmemWdata),
      .dmemSize(dmemSize),
      .dmemWen(dmemWen),
      .dmemAddr(dmemAddr)
  );
  imem instr (
      .clk  (clk_cpu),
      .rAddr(imemAddr),
      .rData(imemRdata),
      .rEn  (imemRen),
      .oEn  (imemOen)
  );
  memIo memIo (
      .clk  (clk_cpu),
      .rst  (rst),
      .sIn  (uartSin),
      .sOut (uartSout),
      .wData(dmemWdata),
      .addr (dmemAddr),
      .rEn  (dmemRen),
      .wEn  (dmemWen),
      .size (dmemSize),
      .rData(dmemRdata)

  );


endmodule
