`timescale 1ns/1ps
module stageExecute (
    input logic clk,
    input logic rst,
    input logic flush,
    input logic [1:0] fwdA,fwdB,
    input logic [31:0] aluResultM,
    input logic [31:0] resultW,
    input logic [31:0] pcD,pcPlus4D,
    input logic [31:0] r1D,r2D,immExtD,
    input logic bPredictedTakenD,
    input logic [4:0] rdAddrD,r1AddrD,r2AddrD,
    input logic regWriteD,memWriteD,branchD,jumpD,useF7D,useRegAddD,funct7_6D,
    input logic [2:0] funct3D,
    input logic [1:0] aluSrcAD,regSrcD,
    input logic aluSrcBD,
    output logic [2:0] loadStoreSize,
    output logic [4:0] r1Addr,r2Addr,rdAddr,
    output logic [31:0] aluResult,writeData,pcPlus4,pcTarget,
    output logic regWrite,memWrite,
    output logic [1:0] regSrc,
    output logic btbUpdate,wrongBranch,pcSel,
    output logic [31:0] pc,btbTarget
  );

  //Pipeline regs
  logic bPredictedTakenSv;
  logic [4:0] rdAddrSv,r1AddrSv,r2AddrSv;
  logic [31:0] pcSv,pcPlus4Sv;
  logic regWriteSv,memWriteSv,branchSv,jumpSv,useF7Sv,useRegAddSv,funct7_6Sv;
  logic [31:0] r1Sv,r2Sv,immExtSv;
  logic [2:0] funct3Sv;
  logic [1:0] aluSrcASv,regSrcSv;
  logic aluSrcBSv;

  //Internal signals
  logic [31:0] r1,r2,immExt,r1Hz,r2Hz,srcA,srcB,pcPlusImm;
  logic [2:0] funct3;
  logic [1:0] aluSrcA;
  logic branch,jump,funct7_6,branchFlag,isJalr,useRegAdd,bPredictedTaken,useF7;
  logic aluSrcB;


  assign r1 = r1Sv;
  assign r2 = r2Sv;
  assign pc = pcSv;
  assign pcPlus4 = pcPlus4Sv;
  assign rdAddr = rdAddrSv;
  assign r1Addr = r1AddrSv;
  assign r2Addr = r2AddrSv;

  assign immExt = immExtSv;
  assign branch = branchSv;
  assign jump = jumpSv;
  assign regWrite = regWriteSv;
  assign memWrite = memWriteSv;
  assign useRegAdd = useRegAddSv;
  assign aluSrcA = aluSrcASv;
  assign aluSrcB = aluSrcBSv;
  assign regSrc = regSrcSv;
  assign funct3 = funct3Sv;
  assign funct7_6 = funct7_6Sv;
  assign useF7 = useF7Sv;
  assign bPredictedTaken = bPredictedTakenSv;

  assign loadStoreSize = funct3Sv;
  assign writeData = r2Hz;



  //HAZARD MUX
  always_comb
  begin
    case (fwdA)
      2'b00:
        r1Hz = r1; //No fwd
      2'b10:
        r1Hz = aluResultM; //Mem fwd
      2'b01:
        r1Hz = resultW; //Write Back fwd
      default:
        r1Hz = r1; //No fwd
    endcase
  end
  always_comb
  begin
    case (fwdB)
      2'b00:
        r2Hz = r2; //No fwd
      2'b10:
        r2Hz = aluResultM; //Mem fwd
      2'b01:
        r2Hz = resultW; //Write Back fwd
      default:
        r2Hz = r2; //No fwd
    endcase
  end
  localparam [1:0]
             RS1 = 2'b0,
             PC = 2'b1;
  always_comb
  begin
    case(aluSrcA)
      RS1:
        srcA = r1Hz;
      PC:
        srcA = pc;
      default:
        srcA = 0;
    endcase
  end
  assign srcB = aluSrcB?immExt:r2Hz;

  //Handle Branches
  assign pcPlusImm = immExt + pc;
  assign btbTarget = pcPlusImm;
  assign isJalr = jump&useRegAdd;

  assign btbUpdate = (~isJalr)&(pcSel); //saving the taken branch without depending on rs1
  assign pcTarget = (!pcSel&bPredictedTaken)?pcPlus4:(isJalr?aluResult:pcPlusImm); // took the wrong branch
  assign pcSel = (branch&branchFlag)| jump;
  assign wrongBranch = pcSel^bPredictedTaken; //flush when pcSelE is there xor bPredictTaken

  alu alu (
        .funct3(funct3),
        .useF7(useF7),
        .funct7_6(funct7_6),
        .useRegAdd(useRegAdd),
        .srcA(srcA),
        .srcB(srcB),
        .aluResult(aluResult),
        .branchFlag(branchFlag),
        .branch(branch)
      );
  always_ff@(posedge clk)
  begin
    if(rst|flush)
    begin
      r1Sv <= 0;
      r2Sv <= 0;
      r1AddrSv <= 0;
      r2AddrSv <= 0;
      rdAddrSv <= 0;
      pcPlus4Sv <= 0;
      pcSv <= 0;
      immExtSv <= 0;

      funct3Sv <= 0;
      useF7Sv    <= 0;
      funct7_6Sv <= 0;
      regWriteSv <= 0;
      memWriteSv <= memWriteD;
      branchSv <=   0;
      jumpSv <=     0;
      aluSrcASv <=  0;
      aluSrcBSv <= 0;
      useRegAddSv <=      0;
      regSrcSv <=      0;
      bPredictedTakenSv <= 0;
    end
    else
    begin
      r1Sv <= r1D;
      r2Sv <= r2D;
      r1AddrSv <= r1AddrD;
      r2AddrSv <= r2AddrD;
      rdAddrSv <= rdAddrD;
      pcPlus4Sv <= pcPlus4D;
      pcSv <= pcD;
      immExtSv <= immExtD;
      funct3Sv <= funct3D;
      useF7Sv    <= useF7D;
      funct7_6Sv <= funct7_6D;
      regWriteSv <= regWriteD;
      memWriteSv <= memWriteD;
      branchSv <=   branchD;
      jumpSv <=     jumpD;
      aluSrcASv <=  aluSrcAD;
      aluSrcBSv <= aluSrcBD;
      useRegAddSv <=      useRegAddD;
      regSrcSv <=      regSrcD;
      bPredictedTakenSv <= bPredictedTakenD;
    end
  end


endmodule
