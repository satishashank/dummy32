`timescale 1ns/1ps
module stageMem (
    input logic clk,
    input logic rst,
    input [1:0] regSrcE,
    input regWriteE,memWriteE,csrWriteE,
    input logic [11:0] csrAddrE,
    input logic [31:0] aluResultE,writeDataE,pcPlus4E,dmemRdata,csrResultE,
    input logic [4:0] rdAddrE,
    input logic [2:0] loadStoreSizeE,
    output logic [31:0] pcPlus4,readData,
    output logic [4:0] rdAddr,
    output logic regWrite,csrWrite,
    output logic [1:0] regSrc,
    output logic [31:0] aluResult,csrResult,
    output logic [11:0] csrAddr,
    output logic [2:0] dmemSize,
    output logic [31:0] dmemWdata,
    output logic [31:0] dmemAddr,
    output logic dmemWen
  );

  //Pipeline Regs
  logic [31:0] aluResultSv;
  logic [31:0] writeDataSv,csrResultSv;
  logic [11:0] csrAddrSv;
  logic [4:0] rdAddrSv;
  logic [31:0] pcPlus4Sv;
  logic [2:0] loadStoreSizeSv;
  logic regWriteSv,csrWriteSv;
  logic memWriteSv;
  logic [1:0] regSrcSv;

  //Internal signals
  logic [31:0] writeData;
  logic memWrite;

  assign memWrite = memWriteSv;
  assign aluResult = aluResultSv;
  assign rdAddr = rdAddrSv;
  assign writeData = writeDataSv;
  assign regWrite = regWriteSv;
  assign pcPlus4 = pcPlus4Sv;
  assign dmemAddr = aluResult;
  assign dmemWdata = writeData;
  assign dmemWen = memWrite;
  assign regSrc = regSrcSv;
  assign dmemSize = loadStoreSizeSv;
  assign csrResult = csrResultSv;
  assign csrWrite = csrWriteSv;
  assign readData = dmemRdata;
  assign csrAddr = csrAddrSv;

  always_ff@(posedge clk)
  begin
    if (rst)
    begin
      aluResultSv      <= 0;
      writeDataSv      <= 0;
      rdAddrSv         <= 0;
      pcPlus4Sv        <= 0;
      regWriteSv       <= 0;
      regSrcSv         <= 0;
      memWriteSv       <= 0;
      loadStoreSizeSv  <= 0;
      csrResultSv            <= 0;
      csrWriteSv       <= 0;
      csrAddrSv        <= 0;
    end
    else
    begin
      aluResultSv <=aluResultE;
      writeDataSv <= writeDataE;
      csrResultSv <= csrResultE;
      csrWriteSv <= csrWriteE;
      rdAddrSv <= rdAddrE;
      pcPlus4Sv <=pcPlus4E;
      regWriteSv <= regWriteE;
      regSrcSv <= regSrcE;
      memWriteSv <= memWriteE;
      loadStoreSizeSv <=loadStoreSizeE;
      csrAddrSv <= csrAddrE;
    end

  end
endmodule
