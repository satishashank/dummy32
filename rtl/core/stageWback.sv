`timescale 1ns/1ps
module stageWback (
    input logic clk,
    input logic rst,
    input logic [1:0] regSrcM,
    input logic [11:0] csrAddrM,
    input regWriteM,csrWriteM,
    input logic [4:0] rdAddrM,
    input logic [31:0] aluResultM,readDataM,pcPlus4M,csrResultM,
    output logic regWrite,csrWrite,
    output logic [11:0] csrAddr,
    output logic [4:0] rdAddr,
    output logic [31:0] regResult,csrResult
  );
  // Pipeline regs
  logic [31:0] readDataSv,pcPlus4Sv,aluResultSv,csrResultSv;
  logic [4:0] rdAddrSv;
  logic  regWriteSv,csrWriteSv;
  logic [1:0] regSrcSv;
  logic [11:0] csrAddrSv;

  //Internal signal
  logic [1:0] regSrc;



  assign regWrite = regWriteSv;
  assign regSrc = regSrcSv;
  assign rdAddr = rdAddrSv;
  assign csrResult = csrResultSv;
  assign csrWrite = csrWriteSv;
  assign csrAddr = csrAddrSv;

  localparam [1:0]
             ALU_SRC = 2'b00,
             MEM_SRC = 2'b01,
             PC_SRC = 2'b10;
  always_comb
  begin
    case (regSrc)
      ALU_SRC:
        regResult = aluResultSv;
      MEM_SRC:
        regResult = readDataSv;
      PC_SRC:
        regResult = pcPlus4Sv;
      default:
        regResult = 0;
    endcase
  end

  always_ff@(posedge clk)
  begin
    if (rst)
    begin
      readDataSv   <= 0;
      rdAddrSv     <= 0;
      pcPlus4Sv    <= 0;
      regWriteSv   <= 0;
      aluResultSv  <= 0;
      regSrcSv     <= 0;
      csrResultSv  <= 0;
      csrWriteSv   <= 0;
      csrAddrSv    <= 0;
    end
    else
    begin
      readDataSv <= readDataM;
      rdAddrSv <= rdAddrM;
      pcPlus4Sv <= pcPlus4M;
      regWriteSv <= regWriteM;
      aluResultSv <= aluResultM;
      regSrcSv <= regSrcM;
      csrResultSv  <= csrResultM;
      csrWriteSv   <= csrWriteM;
      csrAddrSv    <= csrAddrM;
    end

  end
endmodule
