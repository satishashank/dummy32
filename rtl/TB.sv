`timescale 1ns/1ps
module TB;

  // Clock and Reset
  logic clk;
  logic rst;

  //testing
  logic usePredictor;

  // Signals for imem and dmem
  logic [31:0] imemRdata;
  logic [31:0] imemAddr;
  logic [31:0] dmemRdata;
  logic [31:0] dmemRdataFinal;
  logic [31:0] dmemWdata;
  logic [2:0] dmemSize;
  logic dmemWen;
  logic dmemWenFinal;
  logic [31:0] dmemAddr;
  logic uartWen;
  logic [7:0] uartData;
  logic counterCntrl;
  logic counterRegAccess;
  logic counterTurnOn;
  logic counterTurnOff;
  logic [31:0]counterCount;


  assign uartData = dmemWdata[7:0];
  assign uartWen = dmemWen&(dmemAddr == 32'hFFFF_FFFC);

  assign counterCntrl = (dmemAddr == 32'hFFFFFFF4);
  assign counterRegAccess = (dmemAddr == 32'hFFFFFFF8);

  assign counterTurnOn = counterCntrl&(dmemWdata == 32'hAFA51A91);
  assign counterTurnOff = counterCntrl&(dmemWdata == 32'hAFA5109);

  assign dmemWenFinal = dmemWen&&(!uartWen&!counterCntrl);
  assign dmemRdataFinal = counterRegAccess?counterCount:dmemRdata;




  // Instantiate the core module
  core uut (
         .clk(clk),
         .rst(rst),
         .usePredictor(usePredictor),
         .imemRdata(imemRdata),
         .imemAddr(imemAddr),
         .dmemRdata(dmemRdataFinal),
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
         .wEn(dmemWenFinal),
         .addr(dmemAddr),
         .size(dmemSize)
       );
  simUart uart(
            .clk(clk),
            .rst(rst),
            .data(uartData),
            .wEn(uartWen)
          );
  cycleCounter cCounter(.clk(clk),
                        .rst(rst),
                        .turnOn(counterTurnOn),
                        .turnOff(counterTurnOff),
                        .count(counterCount)
                       );

  initial
  begin
    $dumpfile("");
    $dumpvars(0, TB);

  end

endmodule
