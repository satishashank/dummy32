`timescale 1ns / 1ps
module stageDecode (
    input logic clk,
    input logic rst,
    input logic stall,
    flush,
    input logic csrWriteW,
    input logic [11:0] csrAddrW,
    input logic [31:0] csrResultW,
    input logic wrongBranch,
    controlXfer,
    validInst,
    fwdAD,
    fwdBD,
    input logic [31:0] instrF,
    pcF,
    pcPlus4F,
    input logic bPredictedTakenF,
    input logic [4:0] rdAddrW,
    input logic regWriteW,
    input logic [31:0] rdW,
    output logic [4:0] rdAddr,
    r1Addr,
    r2Addr,
    output logic bPredictedTaken,
    output logic regWrite,
    memWrite,
    branch,
    jump,
    useF7,
    useRegAdd,
    funct7_6,
    output logic [11:0] csrAddr,
    output logic [31:0] pc,
    pcPlus4,
    a,
    b,
    immExt,
    output logic [2:0] funct3,
    output logic [1:0] aluSrcA,
    regSrc,
    output logic csrOp,
    aluSrcB
);
  //Pipeline regs
  logic [31:0] instrSv;
  logic [31:0] pcSv;
  logic [31:0] pcPlus4Sv;
  logic bPredictedTakenSv;

  //Signals
  logic [4:0] op;
  logic [2:0] immCntrl;
  logic [24:0] immSrc;
  logic [31:0] zimm, r2, r1, csr, r1Hz, r2Hz;

  assign a = (csrOp & funct3[2]) ? zimm : r1Hz;
  assign b = csrOp ? csr : r2Hz;
  assign zimm = {27'b0, r1Addr};

  assign r1Hz = fwdAD ? rdW : r1;
  assign r2Hz = fwdBD ? rdW : r2;


  assign rdAddr = instrSv[11:7];
  assign csrAddr = instrSv[31:20];
  assign r1Addr = instrSv[19:15];
  assign r2Addr = instrSv[24:20];
  assign op = instrSv[6:2];
  assign funct3 = instrSv[14:12];
  assign funct7_6 = instrSv[30];
  assign immSrc = instrSv[31:7];

  assign bPredictedTaken = bPredictedTakenSv;


  assign pc = pcSv;
  assign pcPlus4 = pcPlus4Sv;
  controlUnit cntrlU (
      .op(op),
      .rst(rst),
      .funct3(funct3[1:0]),
      .regWrite(regWrite),
      .memWrite(memWrite),
      .branch(branch),
      .jump(jump),
      .useF7(useF7),
      .immCntrl(immCntrl),
      .aluSrcA(aluSrcA),
      .aluSrcB(aluSrcB),
      .regSrc(regSrc),
      .useRegAdd(useRegAdd),
      .csrOp(csrOp)
  );
  extend extImm (
      .immSrc  (immSrc),
      .immCntrl(immCntrl),
      .immExt  (immExt)
  );
  registerFile regF (
      .writeData(rdW),  //edit
      .addr1(r1Addr),
      .addr2(r2Addr),
      .writeAddr(rdAddrW),
      .writeEn(regWriteW),
      .clk(clk),
      .reg1(r1),
      .reg2(r2)
  );
  csrFile csrF (
      .clk(clk),
      .csr(csr),
      .readAddr(csrAddr[3:0]),
      .controlXfer(controlXfer),
      .wrongBranch(wrongBranch),
      .validInst(validInst),
      .wEn(csrWriteW),
      .wAddr(csrAddrW),
      .wData(csrResultW)
  );

  always_ff @(posedge clk) begin
    if (rst | flush) begin
      instrSv           <= 0;
      pcSv              <= 0;
      pcPlus4Sv         <= 0;
      bPredictedTakenSv <= 0;
    end else if (!stall) begin
      instrSv           <= instrF;
      pcSv              <= pcF;
      pcPlus4Sv         <= pcPlus4F;
      bPredictedTakenSv <= bPredictedTakenF;
    end
  end

endmodule
