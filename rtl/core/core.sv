`timescale 1ns/1ps
module core(
    input  logic         clk,
    input  logic         rst,
    input logic          usePredictor,
    input  logic [31:0]  imemRdata,
    output logic [31:0]  imemAddr,
    input  logic [31:0]  dmemRdata,
    output logic [31:0]  dmemWdata,
    output logic [2:0]   dmemSize,
    output logic         dmemWen,
    output logic [31:0]  dmemAddr
  );

  // predictor -> fetch
  logic         P_bPredictTaken;
  logic [31:0]  P_btbTarget;

  // execute -> fetch
  logic         E_wrongBranch;
  logic [31:0]  E_pcTarget;
  // fetch -> decode
  logic [31:0]  F_instr, F_pcPlus4, F_pc;
  logic         F_bPredictedTaken;
  // decode -> execute
  logic [4:0]   D_rdAddr, D_r1Addr, D_r2Addr;
  logic         D_bPredictedTaken;
  logic         D_regWrite, D_branch, D_jump,D_memWrite;
  logic         D_useF7, D_useRegAdd, D_funct7_6;
  logic [31:0]  D_pc, D_pcPlus4, D_a, D_b,D_immExt;
  logic [2:0]   D_funct3;
  logic [1:0]   D_aluSrcA, D_regSrc;
  logic D_csrOp,D_aluSrcB;
  logic [11:0] D_csrAddr;
  // execute -> Decode
  logic E_controlXfer,E_validInst;
  // execute -> memory
  logic [4:0]   E_rdAddr;
  logic [2:0]   E_loadStoreSize;
  logic [31:0]  E_aluResult, E_writeData, E_pcPlus4, E_pc,E_csrResult;
  logic         E_regWrite, E_memWrite,E_csrWrite;
  logic [11:0] E_csrAddr;
  logic [1:0]   E_regSrc;
  logic [4:0] E_r1Addr,E_r2Addr;
  // execute -> predictor
  logic         E_btbUpdate,E_pcSel,E_branch;
  logic [31:0]  E_btbTarget;
  // memory -> writeback
  logic [31:0]  M_pcPlus4, M_aluResult,M_readData,M_csrResult;
  logic [4:0]   M_rdAddr;
  logic         M_regWrite,M_csrWrite;
  logic [11:0]  M_csrAddr;
  logic [1:0]   M_regSrc;
  logic [2:0]   M_dmemSize;
  logic [31:0]  M_dmemWdata, M_dmemAddr,M_dmemRdata;
  logic         M_dmemWen;
  // writeback
  logic [31:0]  W_rd,W_csrResult;
  logic [4:0]   W_rdAddr;
  logic [11:0]  W_csrAddr;
  logic         W_regWrite,W_csrWrite;
  // forwarding & stall
  logic         H_stallF;
  logic [1:0]   H_fwdAE, H_fwdBE;
  logic         H_flushE, H_flushD, H_stallD;

  hazardUnit hazard (
               .fwdAE       (H_fwdAE),
               .fwdBE       (H_fwdBE),
               .flushE      (H_flushE),
               .flushD      (H_flushD),
               .stallD      (H_stallD),
               .stallF      (H_stallF),
               .r1AddrE     (E_r1Addr),
               .r2AddrE     (E_r2Addr),
               .r1AddrD     (D_r1Addr),
               .r2AddrD     (D_r2Addr),
               .rdM         (M_rdAddr),
               .rdE         (E_rdAddr),
               .rdW         (W_rdAddr),
               .regWriteM   (M_regWrite),
               .regWriteW   (W_regWrite),
               .regSrcE0    (E_regSrc[0]),
               .wrongBranchE(E_wrongBranch)
             );

  stageInstFetch fetch (
                   .clk             (clk),
                   .rst             (rst),
                   .bPredictTaken   (P_bPredictTaken),
                   .usePredictor    (usePredictor),
                   .pcSelE          (E_pcSel),
                   .btbTarget       (P_btbTarget),
                   .stall           (H_stallF),
                   .wrongBranchE    (E_wrongBranch),
                   .pcTargetE       (E_pcTarget),
                   .imemAddr        (imemAddr),
                   .imemData        (imemRdata),
                   .instr           (F_instr),
                   .pcPlus4         (F_pcPlus4),
                   .pc              (F_pc),
                   .bPredictedTaken (F_bPredictedTaken)
                 );

  stageDecode decode (
                .clk                (clk),
                .rst                (rst),
                .stall              (H_stallD),
                .flush              (H_flushD),
                .csrResultW         (W_csrResult),
                .csrAddrW           (W_csrAddr),
                .csrWriteW          (W_csrWrite),
                .instrF             (F_instr),
                .pcF                (F_pc),
                .pcPlus4F           (F_pcPlus4),
                .bPredictedTakenF   (F_bPredictedTaken),
                .rdAddrW            (W_rdAddr),
                .regWriteW          (W_regWrite),
                .rdW                (W_rd),
                .rdAddr             (D_rdAddr),
                .r1Addr             (D_r1Addr),
                .r2Addr             (D_r2Addr),
                .a                  (D_a),
                .b                  (D_b),
                .immExt             (D_immExt),
                .csrAddr            (D_csrAddr),
                .wrongBranch        (E_wrongBranch),
                .validInst          (E_validInst),
                .csrOp              (D_csrOp),
                .controlXfer        (E_controlXfer),
                .bPredictedTaken    (D_bPredictedTaken),
                .memWrite           (D_memWrite),
                .regWrite           (D_regWrite),
                .branch             (D_branch),
                .jump               (D_jump),
                .useF7              (D_useF7),
                .useRegAdd          (D_useRegAdd),
                .funct7_6           (D_funct7_6),
                .pc                 (D_pc),
                .pcPlus4            (D_pcPlus4),
                .funct3             (D_funct3),
                .aluSrcA            (D_aluSrcA),
                .aluSrcB            (D_aluSrcB),
                .regSrc             (D_regSrc)
              );

  stageExecute execute (
                 .clk             (clk),
                 .rst             (rst),
                 .flush           (H_flushE),
                 .fwdA            (H_fwdAE),
                 .fwdB            (H_fwdBE),
                 .aluResultM      (M_aluResult),
                 .resultW         (W_rd),
                 .pcD             (D_pc),
                 .pcPlus4D        (D_pcPlus4),
                 .aD              (D_a),
                 .bD              (D_b),
                 .immExtD         (D_immExt),
                 .bPredictedTakenD(D_bPredictedTaken),
                 .rdAddrD         (D_rdAddr),
                 .r1AddrD         (D_r1Addr),
                 .r2AddrD         (D_r2Addr),
                 .regWriteD       (D_regWrite),
                 .memWriteD       (D_memWrite),
                 .branchD         (D_branch),
                 .jumpD           (D_jump),
                 .useF7D          (D_useF7),
                 .useRegAddD      (D_useRegAdd),
                 .funct7_6D       (D_funct7_6),
                 .funct3D         (D_funct3),
                 .aluSrcAD        (D_aluSrcA),
                 .aluSrcBD        (D_aluSrcB),
                 .regSrcD         (D_regSrc),
                 .csrOpD          (D_csrOp),
                 .csrAddrD        (D_csrAddr),
                 .loadStoreSize   (E_loadStoreSize),
                 .r1Addr          (E_r1Addr),
                 .r2Addr          (E_r2Addr),
                 .rdAddr          (E_rdAddr),
                 .aluResult       (E_aluResult),
                 .writeData       (E_writeData),
                 .pcPlus4         (E_pcPlus4),
                 .pcTarget        (E_pcTarget),
                 .regWrite        (E_regWrite),
                 .memWrite        (E_memWrite),
                 .regSrc          (E_regSrc),
                 .btbUpdate       (E_btbUpdate),
                 .branch          (E_branch),
                 .wrongBranch     (E_wrongBranch),
                 .validInst       (E_validInst),
                 .controlXfer     (E_controlXfer),
                 .pc              (E_pc),
                 .btbTarget       (E_btbTarget),
                 .pcSel           (E_pcSel),
                 .csrAddr         (E_csrAddr),
                 .csrWrite        (E_csrWrite),
                 .csrResult       (E_csrResult)
               );

  stageMem mem (
             .clk            (clk),
             .rst            (rst),
             .regSrcE        (E_regSrc),
             .regWriteE      (E_regWrite),
             .csrWriteE      (E_csrWrite),
             .csrAddrE       (E_csrAddr),
             .csrResultE     (E_csrResult),
             .memWriteE      (E_memWrite),
             .aluResultE     (E_aluResult),
             .writeDataE     (E_writeData),
             .pcPlus4E       (E_pcPlus4),
             .rdAddrE        (E_rdAddr),
             .loadStoreSizeE (E_loadStoreSize),
             .pcPlus4        (M_pcPlus4),
             .readData       (M_readData),
             .rdAddr         (M_rdAddr),
             .regWrite       (M_regWrite),
             .regSrc         (M_regSrc),
             .aluResult      (M_aluResult),
             .dmemRdata      (M_dmemRdata),
             .dmemSize       (M_dmemSize),
             .dmemWdata      (M_dmemWdata),
             .dmemAddr       (M_dmemAddr),
             .dmemWen        (M_dmemWen),
             .csrWrite       (M_csrWrite),
             .csrResult      (M_csrResult),
             .csrAddr        (M_csrAddr)

           );

  stageWback wback (
               .clk        (clk),
               .rst        (rst),
               .regSrcM    (M_regSrc),
               .regWriteM  (M_regWrite),
               .rdAddrM    (M_rdAddr),
               .aluResultM (M_aluResult),
               .readDataM  (M_readData),
               .pcPlus4M   (M_pcPlus4),
               .csrResultM (M_csrResult),
               .csrAddrM   (M_csrAddr),
               .csrWriteM  (M_csrWrite),
               .regWrite   (W_regWrite),
               .rdAddr     (W_rdAddr),
               .regResult  (W_rd),
               .csrResult  (W_csrResult),
               .csrAddr    (W_csrAddr),
               .csrWrite   (W_csrWrite)
             );
  branchPredictor bPredict(
                    .clk         (clk),
                    .rst         (rst),
                    .fetchPc     (F_pc),
                    .fetchHit    (P_bPredictTaken),
                    .fetchTarget (P_btbTarget),
                    .exTaken     (E_btbUpdate),
                    .exTarget    (E_btbTarget),
                    .exBranch    (E_branch),
                    .exPc        (E_pc)
                  );

  assign dmemSize  = M_dmemSize;
  assign M_dmemRdata = dmemRdata;
  assign dmemWdata = M_dmemWdata;
  assign dmemAddr  = M_dmemAddr;
  assign dmemWen   = M_dmemWen;

endmodule
