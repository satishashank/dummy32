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

  // predictor → fetch
  logic         P_bPredictTaken;
  logic [31:0]  P_btbTarget;

  // execute → fetch
  logic         E_wrongBranch;
  logic [31:0]  E_pcTarget;
  // fetch → decode
  logic [31:0]  F_instr, F_pcPlus4, F_pc;
  logic         F_bPredictedTaken;
  // decode → execute
  logic [4:0]   D_rdAddr, D_r1Addr, D_r2Addr;
  logic         D_bPredictedTaken;
  logic         D_regWrite, D_branch, D_jump,D_memWrite;
  logic         D_useF7, D_useRegAdd, D_funct7_6;
  logic [31:0]  D_pc, D_pcPlus4, D_r1, D_r2, D_immExt;
  logic [2:0]   D_funct3;
  logic [1:0]   D_aluSrcA, D_regSrc;
  logic         D_aluSrcB;
  // execute → memory
  logic [4:0]   E_rdAddr;
  logic [2:0]   E_loadStoreSize;
  logic [31:0]  E_aluResult, E_writeData, E_pcPlus4, E_pc;
  logic         E_regWrite, E_memWrite;
  logic [1:0]   E_regSrc;
  logic         E_btbUpdate,E_pcSel;
  logic [31:0]  E_btbTarget;
  logic [4:0] E_r1Addr,E_r2Addr;
  // memory → writeback
  logic [31:0]  M_pcPlus4, M_aluResult,M_readData;
  logic [4:0]   M_rdAddr;
  logic         M_regWrite;
  logic [1:0]   M_regSrc;
  logic [2:0]   M_dmemSize;
  logic [31:0]  M_dmemWdata, M_dmemAddr,M_dmemRdata;
  logic         M_dmemWen;
  // writeback
  logic [31:0]  W_rd;
  logic [4:0]   W_rdAddr;
  logic         W_regWrite;
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
                .r1                 (D_r1),
                .r2                 (D_r2),
                .immExt             (D_immExt),
                .funct3             (D_funct3),
                .aluSrcA            (D_aluSrcA),
                .regSrc             (D_regSrc),
                .aluSrcB            (D_aluSrcB)
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
                 .r1D             (D_r1),
                 .r2D             (D_r2),
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
                 .regSrcD         (D_regSrc),
                 .aluSrcBD        (D_aluSrcB),
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
                 .wrongBranch     (E_wrongBranch),
                 .pc              (E_pc),
                 .btbTarget       (E_btbTarget),
                 .pcSel           (E_pcSel)
               );

  stageMem mem (
             .clk            (clk),
             .rst            (rst),
             .regSrcE        (E_regSrc),
             .regWriteE      (E_regWrite),
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
             .dmemWen        (M_dmemWen)
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
               .regWrite   (W_regWrite),
               .rdAddr     (W_rdAddr),
               .result     (W_rd)
             );
  branchPredictor bPredict(
                    .clk        (clk),
                    .rst        (rst),
                    .fetchPc (F_pc),
                    .fetchHit(P_bPredictTaken),
                    .fetchTarget(P_btbTarget),
                    .exTaken(E_btbUpdate),
                    .exTarget(E_btbTarget),
                    .exPc    (E_pc)
                  );

  assign dmemSize  = M_dmemSize;
  assign M_dmemRdata = dmemRdata;
  assign dmemWdata = M_dmemWdata;
  assign dmemAddr  = M_dmemAddr;
  assign dmemWen   = M_dmemWen;

endmodule
