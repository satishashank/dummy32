`timescale 1ns/1ps
module core(
    input logic clk,
    input logic [31:0] imemRdata,
    output logic [31:0] imemAddr,
    input logic [31:0] dmemRdata,
    output logic [31:0] dmemWdata,
    output logic dmemWen,
    output logic [31:0] dmemAddr
  );

  //FETCH STAGE
  logic [31:0] pcF,pcFplus4,pcFsv,pcFplus4sv,instrFsv,pcF_;

  assign pcF_ = pcSelE?pcTargetE:pcFplus4;
  assign pcFplus4 = pcF + 4;
  assign imemAddr = pcF; //edit

  //DECODE STAGE
  logic [31:0] instrD;
  logic [31:0] rs1D,rs2D;
  logic [4:0] rdD,r1AddrD,r2AddrD;
  logic [4:0] rdDsv,r1AddrDsv,r2AddrDsv;
  logic [31:0] rs1Dsv,rs2Dsv;
  logic [31:0] pcD,pcDplus4;
  logic [31:0] pcDsv,pcDplus4sv;
  logic [31:0] immExtD;
  logic [31:0] immExtDsv;

  logic regWriteD,memWriteD,branchD,jumpD,aluSrcBD,invD;
  logic regWriteDsv,memWriteDsv,branchDsv,jumpDsv,aluSrcBDsv,invDsv;
  logic aluSrcAD;
  logic aluSrcADsv;
  logic [1:0] regSrcD;
  logic [1:0] regSrcDsv;
  logic [3:0] aluCntrlD,aluCntrlDsv;
  logic [2:0] immCntrlD;

  assign instrD = instrFsv;
  assign pcD = pcFsv;
  assign pcDplus4 = pcFplus4sv;
  assign rdD = instrD[11:7];
  assign r1AddrD = instrD[19:15];
  assign r2AddrD = instrD[24:20];


  //EXECUTE STAGE
  logic [31:0] srcAE;
  logic [31:0] srcBE;
  logic [31:0] aluResultE;
  logic [31:0] aluResultEsv;
  logic [31:0] pcE,immExtE,pcTargetE,pcEplus4;
  logic [31:0] pcEplus4sv;
  logic branchFlagE,pcSelE;

  logic regWriteE,memWriteE,branchE,jumpE,aluSrcBE,invE;
  logic regWriteEsv,memWriteEsv;
  logic [31:0] rs1E,rs2E,rs1hzE,rs2hzE;
  logic [4:0] rdE,r1AddrE,r2AddrE;
  logic [31:0] rs2Esv;
  logic [4:0] rdEsv;
  logic [3:0] aluCntrlE;
  logic aluSrcAE;
  logic [1:0] regSrcE;
  logic [1:0] regSrcEsv;
  logic [1:0] fwdAE;
  logic [1:0] fwdBE;

  assign rs1E = rs1Dsv;
  assign rs2E = rs2Dsv;
  assign pcE = pcDsv;
  assign pcEplus4 = pcDplus4sv;
  assign rdE = rdDsv;
  assign r1AddrE = r1AddrDsv;
  assign r2AddrE = r2AddrDsv;

  assign immExtE = immExtDsv;
  assign branchE = branchDsv;
  assign jumpE = jumpDsv;
  assign regWriteE = regWriteDsv;
  assign memWriteE = memWriteDsv;
  assign aluSrcBE = aluSrcBDsv;
  assign aluSrcAE = aluSrcADsv;
  assign regSrcE = regSrcDsv;
  assign invE = invDsv;
  assign aluCntrlE = aluCntrlDsv;


  //HAZARD MUX
  always_comb
  begin
    case (fwdAE)
      2'b00:
        rs1hzE = rs1E; //No fwd
      2'b10:
        rs1hzE = aluResultM; //Mem fwd
      2'b01:
        rs1hzE = resultW; //Write Back fwd

      default:
        rs1hzE = rs1E; //No fwd
    endcase
  end
  always_comb
  begin
    case (fwdBE)
      2'b00:
        rs2hzE = rs2E; //No fwd
      2'b10:
        rs2hzE = aluResultM; //Mem fwd
      2'b01:
        rs2hzE = resultW; //Write Back fwd
      default:
        rs2hzE = rs2E; //No fwd
    endcase
  end
  assign srcAE = aluSrcAE?pcE:rs1hzE;
  assign srcBE = aluSrcBE?immExtE:rs2hzE;


  assign pcTargetE = immExtE + pcE;
  assign pcSelE = (branchE&branchFlagE) ^ jumpE;

  //MEMORY STAGE
  logic [31:0] aluResultM,aluResultMsv;
  logic [31:0] writeDataM;
  logic [4:0] rdM;
  logic [4:0] rdMsv;
  logic [31:0] pcMplus4;
  logic [31:0] pcMplus4sv;
  logic [31:0] dmemRdataMsv;
  logic regWriteM;
  logic regWriteMsv;
  logic memWriteM;
  logic [1:0] regSrcM,regSrcMsv;

  assign memWriteM = memWriteEsv;
  assign aluResultM = aluResultEsv;
  assign rdM = rdEsv;
  assign writeDataM = rs2Esv;
  assign regWriteM = regWriteEsv;
  assign dmemWen = memWriteM;
  assign pcMplus4 = pcEplus4sv;
  assign dmemAddr = aluResultM;
  assign dmemWdata = writeDataM;
  assign regSrcM = regSrcEsv;

  //WRITEBACK STAGE
  localparam [1:0]
             ALU_SRC = 2'b00,
             MEM_SRC = 2'b01,
             PC_SRC = 2'b11;
  logic [4:0] rdW;
  logic [31:0] pcWplus4;
  logic [31:0] aluResultW;
  logic [31:0] dmemRdataW;
  logic [31:0] resultW;
  logic [1:0] regSrcW;
  logic regWriteW;

  assign rdW = rdMsv;
  assign regSrcW = regSrcMsv;
  assign pcWplus4 = pcMplus4sv;
  assign dmemRdataW = dmemRdataMsv;
  assign aluResultW = aluResultMsv;
  assign regWriteW = regWriteMsv;
  always_comb
  begin
    case (regSrcW)
      ALU_SRC:
        resultW = aluResultW;
      MEM_SRC:
        resultW = dmemRdataW;
      PC_SRC:
        resultW = pcWplus4;
      default:
        resultW = 0;
    endcase
  end

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
                .aluSrcB(aluSrcBD),
                .aluSrcA(aluSrcAD),
                .regSrc(regSrcD),
                .inv(invD)
              );
  extend extImm(
           .immSrc(instrD[31:7]),
           .immCntrl(immCntrlD),
           .immExt(immExtD)
         );
  registerFile regF(
                 .writeData(resultW), //edit
                 .addr1(instrD[19:15]),
                 .addr2(instrD[24:20]),
                 .writeAddr(rdW),
                 .writeEn(regWriteW),
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
  hazardUnit hzrdUnit (
               .fwdAE(fwdAE),
               .fwdBE(fwdBE),
               .r1AddrE(r1AddrE),
               .r2AddrE(r2AddrE),
               .rdM(rdM),
               .rdW(rdW),
               .regWriteM(regWriteM),
               .regWriteW(regWriteW)
             );
  always_ff@(posedge clk)
  begin
    pcF <= pcF_;
    begin : fetchReg
      pcFsv <= pcF;
      pcFplus4sv <= pcFplus4;
      instrFsv <= imemRdata;
    end
    begin : decodeReg
      rs1Dsv <= rs1D;
      rs2Dsv <= rs2D;
      r1AddrDsv <= r1AddrD;
      r2AddrDsv <= r2AddrD;
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
      aluSrcBDsv <= aluSrcBD;
      aluSrcADsv <= aluSrcAD;
      regSrcDsv <= regSrcD;
    end
    begin : executeReg
      aluResultEsv <=aluResultE;
      rs2Esv <= rs2E;
      rdEsv <= rdE;
      pcEplus4sv <=pcEplus4;
      regWriteEsv <= regWriteE;
      regSrcEsv <= regSrcE;
      memWriteEsv <= memWriteE;
    end
    begin : memoryReg
      dmemRdataMsv <= dmemRdata;
      rdMsv <= rdM;
      pcMplus4sv<=pcMplus4;
      regWriteMsv <= regWriteM;
      aluResultMsv <= aluResultM;
      regSrcMsv <= regSrcM;
    end

  end
endmodule
