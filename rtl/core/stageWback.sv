`timescale 1ns/1ps
module stageWback (
    input logic clk,
    input logic rst,
    input logic [1:0] regSrcM,
    input regWriteM,
    input logic [4:0] rdAddrM,
    input logic [31:0] aluResultM,readDataM,pcPlus4M,
    output logic regWrite,
    output logic [4:0] rdAddr,
    output logic [31:0] result
  );
  // Pipeline regs
  logic [31:0] readDataSv,pcPlus4Sv,aluResultSv;
  logic [4:0] rdAddrSv;
  logic  regWriteSv;
  logic [1:0] regSrcSv;

  //Internal signal
  logic [1:0] regSrc;



  assign regWrite = regWriteSv;
  assign regSrc = regSrcSv;
  assign rdAddr = rdAddrSv;

  localparam [1:0]
             ALU_SRC = 2'b00,
             MEM_SRC = 2'b01,
             PC_SRC = 2'b10;
  always_comb
  begin
    case (regSrc)
      ALU_SRC:
        result = aluResultSv;
      MEM_SRC:
        result = readDataSv;
      PC_SRC:
        result = pcPlus4Sv;
      default:
        result = 0;
    endcase
  end

  always_ff@(posedge clk)
  begin
    if (rst)
    begin
      readDataSv   <= 0;
      rdAddrSv         <= 0;
      pcPlus4Sv    <= 0;
      regWriteSv   <= 0;
      aluResultSv  <= 0;
      regSrcSv     <= 0;
    end
    else
    begin
      readDataSv <= readDataM;
      rdAddrSv <= rdAddrM;
      pcPlus4Sv <= pcPlus4M;
      regWriteSv <= regWriteM;
      aluResultSv <= aluResultM;
      regSrcSv <= regSrcM;
    end

  end
endmodule
