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

  assign uartData = dmemWdata[7:0];
  assign uartWen = dmemWen&(dmemAddr == 32'hFFFF_FFFC);
  assign dmemWenFinal = dmemWen&&(!uartWen);




  core uut (
         .clk(clk),
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
         .clk(clk),
         .rAddr(imemAddr),
         .rData(imemRdata),
         .rEn(imemRen),
         .oEn(imemOen)
       );
  uartTx uartTx(
           .clk(clk),
           .rst(rst),
           .data(uartData),
           .dataWen(uartWen),
           .fifoFull(uartFifoFull),
           .sOut(uartSout)
         );
  dmem data(
         .clk(clk),
         .wData(dmemWdata),
         .addr(dmemAddr),
         .rData(dmemRdata),
         .size(dmemSize),
         .wEn(dmemWenFinal),
         .rEn(dmemRen),
         .uartFifoFull(uartFifoFull)

       );
endmodule
