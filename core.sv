`timescale 1ns/1ps
module core(
    input logic clk,
    input logic [31:0] readData,
    output logic [31:0] writeData,
    output logic writeEn,
    output logic [31:0] memAddr
  );

  //FETCH STAGE
  logic [31:0] pcF,pcFplus4,pcFsv,pcFplus4sv,instrFsv,pcF_;

  assign pcF_ = pcSelE?pcTargetE:pcFplus4;
  assign pcFplus4 = pcF + 4;
  assign memAddr = pcF; //edit

  //DECODE STAGE
  logic [31:0] instrD;
  logic [31:0] rs1D,rs2D;
  logic [4:0] rdD;
  logic [4:0] rdDsv;
  logic [31:0] rs1Dsv,rs2Dsv;
  logic [31:0] pcD,pcDplus4;
  logic [31:0] pcDsv,pcDplus4sv;
  logic [31:0] immExtD;
  logic [31:0] immExtDsv;

  logic regWriteD,memWriteD,branchD,jumpD,aluSrcD,invD;
  logic regWriteDsv,memWriteDsv,branchDsv,jumpDsv,aluSrcDsv,invDsv;

  logic [3:0] aluCntrlD,aluCntrlDsv;
  logic [2:0] immCntrlD;

  assign instrD = instrFsv;
  assign pcD = pcFsv;
  assign pcDplus4 = pcFplus4sv;
  assign writeEn = memWriteD; //edit
  assign rdD = instrD[11:7];


  //EXECUTE STAGE
  logic [31:0] srcAE;
  logic [31:0] srcBE;
  logic [31:0] aluResultE;
  logic [31:0] aluResultEsv;
  logic [31:0] pcE,immExtE,pcTargetE,pcEplus4;
  logic [31:0] pcEplus4sv;
  logic branchFlagE,pcSelE;

  logic regWriteE,memWriteE,branchE,jumpE,aluSrcE,invE;
  logic regWriteEsv,memWriteEsv;
  logic [31:0] rs1E,rs2E;
  logic [4:0] rdE;
  logic [31:0] rs2Esv;
  logic [4:0] rdEsv;
  logic [3:0] aluCntrlE;

  assign rs1E = rs1Dsv;
  assign rs2E = rs2Dsv;
  assign pcE = pcDsv;
  assign pcEplus4 = pcDplus4sv;
  assign rdE = rdDsv;
  assign immExtE = immExtDsv;
  assign branchE = branchDsv;
  assign jumpE = jumpDsv;
  assign regWriteE = regWriteDsv;
  assign memWriteE = memWriteDsv;
  assign aluSrcE = aluSrcDsv;
  assign invE = invDsv;
  assign aluCntrlE = aluCntrlDsv;

  assign srcAE = rs1E; //edit hazard
  assign srcBE = aluSrcE?immExtE:rs2E;
  assign pcTargetE = immExtE + pcE;
  assign pcSelE = (branchE&branchFlagE) ^ jumpE;

  //MEMORY STAGE
  

  controlUnit cntrlU(
                .op(instrD[6:2]),
                .funct3(instrD[14:12]),
                .funct7_6(instrD[30]),
                .regWrite(regWriteD),
                .memWrite(memWriteD),
                .branch(branchD),
                .jump(jumpD),
                .aluCntrl(aluCntrlD),
                .immCntrl(immCntrlD),
                .aluSrc(aluSrcD),
                .inv(invD)
              );
  extend extImm(
           .immSrc(instrD[31:7]),
           .immCntrl(immCntrlD),
           .immExt(immExtD)
         );
  registerFile regF(
                 .writeData(aluResultE), //edit
                 .addr1(instrD[19:15]),
                 .addr2(instrD[24:20]),
                 .writeAddr(rdD),
                 .writeEn(regWriteD),
                 .clk(clk),
                 .reg1(rs1D),
                 .reg2(rs2D)
               );
  alu alu (
        .aluCntrl(aluCntrlE),
        .inv(invE),
        .srcA(srcAE),
        .srcB(srcBE),
        .aluResult(aluResultE),
        .branchFlag(branchFlagE)
      );

  always_ff@(posedge clk)
  begin
    pcF <= pcF_;
    begin : fetchReg
      pcFsv <= pcF;
      pcFplus4sv <= pcFplus4;
      instrFsv <= readData;
    end
    begin : decodeReg
      rs1Dsv <= rs1D;
      rs2Dsv <= rs2D;
      rdDsv <= rdD;
      pcDplus4sv <= pcDplus4;
      pcDsv <= pcD;
      immExtDsv <= immExtD;

      aluCntrlDsv <= aluCntrlD;
      invDsv <=invD;
      regWriteDsv<= regWriteD;
      memWriteDsv<= memWriteD;
      branchDsv<= branchD;
      jumpDsv <= jumpD;
      aluSrcDsv <= aluSrcD;
    end
    begin : executeReg
      aluResultEsv <=aluResultE;
      rs2Esv <= rs2E;
      rdEsv <= rdE;
      pcEplus4sv<=pcEplus4;

      regWriteEsv <= regWriteE;
      memWriteEsv <= memWriteE;
    end
  end
endmodule
