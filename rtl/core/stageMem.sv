`timescale 1ns/1ps
module stageMem (
    input logic clk,
    input logic rst,
    input logic [1:0] regSrcE,
    input logic regWriteE,memWriteE,csrWriteE,
    input logic [11:0] csrAddrE,
    input logic [31:0] aluResultE,writeDataE,pcPlus4E,dmemRdata,csrResultE,
    input logic [4:0] rdAddrE,
    input logic [2:0] loadStoreSizeE,
    output logic [31:0] pcPlus41,pcPlus42,readData,
    output logic [4:0] rdAddr1,rdAddr2,
    output logic regWrite1,csrWrite,regWrite2,
    output logic [1:0] regSrc1,regSrc2,
    output logic [31:0] aluResult1,aluResult2,csrResult,
    output logic [11:0] csrAddr,
    output logic [2:0] dmemSize,
    output logic [31:0] dmemWdata,
    output logic [31:0] dmemAddr,
    output logic dmemWen,
    output logic dmemRen
  );

  //Pipeline Regs2
  logic [31:0] aluResultSv2;
  logic [31:0] csrResultSv2;
  logic [11:0] csrAddrSv2;
  logic [4:0] rdAddrSv2;
  logic [31:0] pcPlus4Sv2;
  logic regWriteSv2,csrWriteSv2;
  logic [1:0] regSrcSv2;

  //Pipeline Regs1
  logic [31:0] aluResultSv1;
  logic [31:0] writeDataSv1,csrResultSv1;
  logic [11:0] csrAddrSv1;
  logic [4:0] rdAddrSv1;
  logic [31:0] pcPlus4Sv1;
  logic [2:0] loadStoreSizeSv1;
  logic regWriteSv1,csrWriteSv1;
  logic memWriteSv1;
  logic [1:0] regSrcSv1;

  //Internal signals
  logic [31:0] writeData;
  logic memWrite;

  assign memWrite = memWriteSv1;
  assign aluResult2 = aluResultSv2; //final result
  assign aluResult1 = aluResultSv1;
  assign rdAddr1 = rdAddrSv1;
  assign rdAddr2 = rdAddrSv2;
  assign writeData = writeDataSv1;
  assign regWrite1 = regWriteSv1;
  assign regWrite2 = regWriteSv2;
  assign pcPlus41 = pcPlus4Sv1;
  assign pcPlus42 = pcPlus4Sv2;
  assign dmemAddr = aluResultSv1;
  assign dmemRen = regSrcSv1[0]&regWriteSv1; //Ren before data
  assign dmemWdata = writeData;
  assign dmemWen = memWrite;
  assign regSrc2 = regSrcSv2;
  assign regSrc1 = regSrcSv1;
  assign dmemSize = loadStoreSizeSv1;
  assign csrResult = csrResultSv2;
  assign csrWrite = csrWriteSv2;
  assign readData = dmemRdata;
  assign csrAddr = csrAddrSv2;

  always_ff@(posedge clk)
  begin
    if (rst)
    begin
      aluResultSv2      <= 0;
      rdAddrSv2         <= 0;
      pcPlus4Sv2        <= 0;
      regWriteSv2       <= 0;
      regSrcSv2         <= 0;
      csrResultSv2      <= 0;
      csrWriteSv2       <= 0;
      csrAddrSv2        <= 0;

      aluResultSv1      <= 0;
      writeDataSv1      <= 0;
      rdAddrSv1         <= 0;
      pcPlus4Sv1        <= 0;
      regWriteSv1       <= 0;
      regSrcSv1         <= 0;
      memWriteSv1       <= 0;
      loadStoreSizeSv1  <= 0;
      csrResultSv1      <= 0;
      csrWriteSv1       <= 0;
      csrAddrSv1        <= 0;
    end
    else
    begin
      aluResultSv1 <= aluResultE;
      writeDataSv1 <= writeDataE;
      csrResultSv1 <= csrResultE;
      csrWriteSv1 <= csrWriteE;
      rdAddrSv1 <= rdAddrE;
      pcPlus4Sv1 <=pcPlus4E;
      regWriteSv1 <= regWriteE;
      regSrcSv1 <= regSrcE;
      memWriteSv1 <= memWriteE;
      loadStoreSizeSv1 <=loadStoreSizeE;
      csrAddrSv1 <= csrAddrE;
    end

  end
  always_ff@(posedge clk)
  begin
    if(!rst)
    begin
      aluResultSv2 <=aluResultSv1;
      csrResultSv2 <= csrResultSv1;
      csrWriteSv2 <= csrWriteSv1;
      rdAddrSv2 <= rdAddrSv1;
      pcPlus4Sv2 <=pcPlus4Sv1;
      regWriteSv2 <= regWriteSv1;
      regSrcSv2 <= regSrcSv1;
      csrAddrSv2 <= csrAddrSv1;
    end
  end

endmodule
