module soc (
    input logic clk,
    input logic rst,
    input usePredictor,
    output uartSout
  );
  logic [31:0] imemRdata;
  logic [31:0] imemAddr;
  logic imemRen,imemOen;
  logic [31:0] dmemRdata;
  logic [31:0] dmemWdata;
  logic [2:0] dmemSize;
  logic dmemWen,dmemRen;
  logic dmemWenFinal;
  logic [31:0] dmemAddr;
  logic uartWen,uartFifoFull;
  logic [7:0] uartData;
  logic clk_cpu;
  logic locked;
    
clk_wiz_0 clk_gen (
   .clk_in1(clk),   // input clock from FPGA pin
   .reset(rst),
   .clk_out1(clk_cpu),   // say 50 MHz
   .locked(locked)       // indicates stable clocks
);

  assign uartData = dmemWdata[7:0];
  assign uartWen = dmemWen&(dmemAddr == 32'hFFFF_FFFC);
  assign dmemWenFinal = dmemWen&&(!uartWen);




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
         .clk(clk_cpu),
         .rAddr(imemAddr),
         .rData(imemRdata),
         .rEn(imemRen),
         .oEn(imemOen)
       );
  uartTx uartTx(
           .clk(clk_cpu),
           .rst(rst),
           .data(uartData),
           .dataWen(uartWen),
           .fifoFull(uartFifoFull),
           .sOut(uartSout)
         );
  dmem data(
         .clk(clk_cpu),
         .wData(dmemWdata),
         .addr(dmemAddr),
         .rData(dmemRdata),
         .size(dmemSize),
         .wEn(dmemWenFinal),
         .rEn(dmemRen),
         .uartFifoFull(uartFifoFull)

       );
endmodule
