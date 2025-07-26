`timescale 1ns/1ps
module core(
    input logic clk,
    input logic rst,
    input logic usePredict,
    input logic [31:0] imemRdata,
    output logic [31:0] imemAddr,
    input logic [31:0] dmemRdata,
    output logic [31:0] dmemWdata,
    output logic [2:0] dmemSize,
    output logic dmemWen,
    output logic [31:0] dmemAddr
  );

  //FETCH STAGE
  logic [31:0] pcF,pcFplus4,pcFsv,pcFplus4sv,instrFsv,pcF_;
  logic bPredictTakenF,bPredictTakenFsv;
  logic [31:0] btbTargetF;


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

  logic regWriteD,memWriteD,branchD,jumpD,aluSrcBD,invD,loadStoreD;
  logic regWriteDsv,memWriteDsv,branchDsv,jumpDsv,aluSrcBDsv,invDsv,loadStoreDsv;
  logic [1:0] aluSrcAD;
  logic [1:0] aluSrcADsv;
  logic pcTargetSrcD,pcTargetSrcDsv;
  logic [1:0] regSrcD;
  logic [1:0] regSrcDsv;
  logic [2:0] aluCntrlD,aluCntrlDsv;
  logic useF7D,useF7Dsv;
  logic [2:0] immCntrlD;
  logic bPredictTakenD,bPredictTakenDsv,isControlxfer;

  //EXECUTE STAGE
  logic [31:0] srcAE;
  logic [31:0] srcBE;
  logic [31:0] aluResultE;
  logic [31:0] aluResultEsv;
  logic [31:0] pcE,immExtE,pcTargetE,pcEplus4;
  logic [31:0] pcEplus4sv;
  logic branchFlagE,pcSelE;
  logic [31:0] pcPlusImm;

  logic regWriteE,memWriteE,branchE,jumpE,aluSrcBE,invE,loadStoreE;
  logic regWriteEsv,memWriteEsv;
  logic [31:0] rs1E,rs2E,rs1hzE,rs2hzE;
  logic [4:0] rdE,r1AddrE,r2AddrE;
  logic [31:0] rs2Esv;
  logic [4:0] rdEsv;
  logic [2:0] aluCntrlE;
  logic [2:0] loadStoreSizeE;
  logic [2:0] loadStoreSizeEsv;
  logic useF7E;
  logic [1:0] aluSrcAE;
  logic pcTargetSrcE;
  logic [1:0] regSrcE;
  logic [1:0] regSrcEsv;
  logic [1:0] fwdAE;
  logic [1:0] fwdBE;
  logic btbUpdateE;
  logic bPredictTakenE;
  logic [31:0] btbTargetE;
  logic wrongBranchE;

  localparam [1:0]
             RS1 = 2'b0,
             PC = 2'b1;

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

  //WRITEBACK STAGE
  localparam [1:0]
             ALU_SRC = 2'b00,
             MEM_SRC = 2'b01,
             PC_SRC = 2'b10;
  logic [4:0] rdW;
  logic [31:0] pcWplus4;
  logic [31:0] aluResultW;
  logic [31:0] dmemRdataW;
  logic [31:0] resultW;
  logic [1:0] regSrcW;
  logic regWriteW;

  //FETCH STAGE

  always_comb
  begin
    if (usePredict)
    begin
      case ({wrongBranchE,bPredictTakenF})
        2'b10,2'b11:
          pcF_ = pcTargetE;
        2'b01:
          pcF_ = btbTargetF;
        default:
          pcF_ = pcFplus4;
      endcase
    end
    else
      pcF_ = pcSelE?pcTargetE:pcFplus4;

  end
  assign pcFplus4 = pcF + 4;
  assign imemAddr = pcF;

  //DECODE STAGE
  assign instrD = instrFsv;
  assign pcD = pcFsv;
  assign pcDplus4 = pcFplus4sv;
  assign rdD = instrD[11:7];
  assign r1AddrD = instrD[19:15];
  assign r2AddrD = instrD[24:20];
  assign bPredictTakenD = bPredictTakenFsv;

  //EXECUTE STAGE
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
  assign loadStoreE = loadStoreDsv;
  assign loadStoreSizeE = aluCntrlE;
  assign memWriteE = memWriteDsv;
  assign aluSrcBE = aluSrcBDsv;
  assign aluSrcAE = aluSrcADsv;
  assign regSrcE = regSrcDsv;
  assign invE = invDsv;
  assign aluCntrlE = aluCntrlDsv;
  assign useF7E = useF7Dsv;
  assign pcTargetSrcE = pcTargetSrcDsv;
  assign bPredictTakenE = bPredictTakenDsv;


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
  always_comb
  begin
    case(aluSrcAE)
      RS1:
        srcAE = rs1hzE;
      PC:
        srcAE = pcE;
      default:
        srcAE = 0;
    endcase

  end
  assign srcBE = aluSrcBE?immExtE:rs2hzE;
  assign pcPlusImm = immExtE + pcE;
  assign btbTargetE = pcPlusImm;

  assign pcTargetE = (~pcSelE&bPredictTakenE&usePredict)?pcEplus4:(pcTargetSrcE ? aluResultE : (pcPlusImm));
  assign pcSelE = (branchE&branchFlagE)| jumpE;
  assign btbUpdateE = (~pcTargetSrcE)&(isControlxfer); //saving the branch without depending on rs1
  assign wrongBranchE = pcSelE^bPredictTakenE; //flush when pcSelE is there xor bPredictTakens
  assign isControlxfer = branchE|jumpE;


  //HAZARD SIGNALS
  logic stallF,stallD,flushE,flushD;

  //MEMORY STAGE
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
  assign dmemSize = loadStoreSizeEsv;

  //WRITEBACK STAGE
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
                .useF7(useF7D),
                .immCntrl(immCntrlD),
                .aluSrcB(aluSrcBD),
                .aluSrcA(aluSrcAD),
                .pcTargetSrc(pcTargetSrcD),
                .regSrc(regSrcD),
                .inv(invD),
                .loadStore(loadStoreD)
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
        .useF7(useF7E),
        .inv(invE),
        .loadStore(loadStoreE),
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
               .regWriteW(regWriteW),
               .stallD(stallD),
               .stallF(stallF),
               .flushE(flushE),
               .flushD(flushD),
               .r1AddrD(r1AddrD),
               .r2AddrD(r2AddrD),
               .rdE(rdE),
               .regSrcE0(regSrcE[0]),
               .wrongBranchE(wrongBranchE),
               .pcSelE(pcSelE),
               .usePredict(usePredict)
             );
  branchPredictorGshare bPredictor(
                          .clk(clk),
                          .rst(rst),
                          .fetchPc(pcF),
                          .fetchHit(bPredictTakenF),
                          .fetchTarget(btbTargetF),
                          .exPc(pcE),
                          .exTaken(pcSelE),
                          .exBranch(btbUpdateE),
                          .exTarget(btbTargetE)
                        );
  csr csr(.clk(clk),
          .rst(rst),
          .isControlxfer(isControlxfer),
          .wrongBranch(wrongBranchE)
         );
  always_ff@(posedge clk)
  begin
    if (rst)
    begin
      pcF <= 0;
      pcFsv         <= 0;
      pcFplus4sv    <= 0;
      instrFsv      <= 0;
      bPredictTakenFsv     <= 0;

      rs1Dsv        <= 0;
      rs2Dsv        <= 0;
      r1AddrDsv     <= 0;
      r2AddrDsv     <= 0;
      rdDsv         <= 0;
      pcDplus4sv    <= 0;
      pcDsv         <= 0;
      immExtDsv     <= 0;
      aluCntrlDsv   <= 0;
      useF7Dsv      <= 0;
      invDsv        <= 0;
      regWriteDsv   <= 0;
      loadStoreDsv  <= 0;
      memWriteDsv   <= 0;
      branchDsv     <= 0;
      jumpDsv       <= 0;
      aluSrcBDsv    <= 0;
      aluSrcADsv    <= 0;
      pcTargetSrcDsv<= 0;
      regSrcDsv     <= 0;
      bPredictTakenDsv     <= 0;

      aluResultEsv      <= 0;
      rs2Esv            <= 0;
      rdEsv             <= 0;
      pcEplus4sv        <= 0;
      regWriteEsv       <= 0;
      regSrcEsv         <= 0;
      memWriteEsv       <= 0;
      loadStoreSizeEsv <= 0;

      dmemRdataMsv  <= 0;
      rdMsv         <= 0;
      pcMplus4sv    <= 0;
      regWriteMsv   <= 0;
      aluResultMsv  <= 0;
      regSrcMsv     <= 0;
    end
    else
    begin
      if (!stallF)
      begin : PCreg
        pcF <= pcF_;
      end
      if (!stallD)
      begin : fetchReg
        pcFsv <= pcF;
        pcFplus4sv <= pcFplus4;
        instrFsv <= imemRdata;
        bPredictTakenFsv <= bPredictTakenF;
      end
      if (flushD)
      begin
        pcFsv <= 0;
        pcFplus4sv <= 0;
        instrFsv <= 0;
        bPredictTakenFsv <= 0;
      end
      if (flushE)
      begin : decodeReg
        rs1Dsv <= 0;
        rs2Dsv <= 0;
        r1AddrDsv <= 0;
        r2AddrDsv <= 0;
        rdDsv <= 0;
        pcDplus4sv <= 0;
        pcDsv <= 0;
        immExtDsv <= 0;

        aluCntrlDsv <= 0;
        useF7Dsv    <= 0;
        invDsv <= 0;
        regWriteDsv<= 0;
        memWriteDsv<= 0;
        branchDsv<= 0;
        jumpDsv <= 0;
        aluSrcBDsv <= 0;
        aluSrcADsv <= 0;
        pcTargetSrcDsv <= 0;
        loadStoreDsv <= 0;
        regSrcDsv <= 0;
        bPredictTakenDsv <= 0;
      end
      else
      begin
        rs1Dsv <= rs1D;
        rs2Dsv <= rs2D;
        r1AddrDsv <= r1AddrD;
        r2AddrDsv <= r2AddrD;
        rdDsv <= rdD;
        pcDplus4sv <= pcDplus4;
        pcDsv <= pcD;
        immExtDsv <= immExtD;

        aluCntrlDsv <= aluCntrlD;
        useF7Dsv <= useF7D;
        invDsv <=invD;
        regWriteDsv<= regWriteD;
        memWriteDsv<= memWriteD;
        branchDsv<= branchD;
        jumpDsv <= jumpD;
        aluSrcBDsv <= aluSrcBD;
        aluSrcADsv <= aluSrcAD;
        pcTargetSrcDsv <= pcTargetSrcD;
        loadStoreDsv <= loadStoreD;
        regSrcDsv <= regSrcD;
        bPredictTakenDsv <= bPredictTakenD;
      end
      begin : executeReg
        aluResultEsv <=aluResultE;
        rs2Esv <= rs2hzE;
        rdEsv <= rdE;
        pcEplus4sv <=pcEplus4;
        regWriteEsv <= regWriteE;
        regSrcEsv <= regSrcE;
        memWriteEsv <= memWriteE;
        loadStoreSizeEsv <=loadStoreSizeE;
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

  end
endmodule
