`timescale 1ns/1ps
module stageExecute (
    input logic clk,
    input logic rst,
    input logic flush,
    input logic csrOpD,
    input logic [1:0] fwdA,fwdB,
    input logic [31:0] aluResultM,
    input logic [31:0] resultW,
    input logic [31:0] pcD,pcPlus4D,
    input logic [31:0] aD,bD,immExtD,
    input logic bPredictedTakenD,
    input logic [4:0] rdAddrD,r1AddrD,r2AddrD,
    input logic [11:0] csrAddrD,
    input logic regWriteD,memWriteD,branchD,jumpD,useF7D,useRegAddD,funct7_6D,
    input logic [2:0] funct3D,
    input logic [1:0] aluSrcAD,regSrcD,
    input logic aluSrcBD,
    output logic [2:0] loadStoreSize,
    output logic [4:0] r1Addr,r2Addr,rdAddr,
    output logic [31:0] aluResult,writeData,pcPlus4,pcTarget,csrResult,
    output logic regWrite,memWrite,csrWrite,
    output logic [11:0] csrAddr,
    output logic [1:0] regSrc,
    output logic btbUpdate,wrongBranch,pcSel,branch,controlXfer,
    output logic [31:0] pc,btbTarget
  );

  //Pipeline regs
  logic bPredictedTakenSv;
  logic [4:0] rdAddrSv,r1AddrSv,r2AddrSv;
  logic [31:0] pcSv,pcPlus4Sv;
  logic regWriteSv,memWriteSv,branchSv,jumpSv,useF7Sv,useRegAddSv,funct7_6Sv,csrOpSv;
  logic [11:0] csrAddrSv;
  logic [31:0] aSv,bSv,immExtSv;
  logic [2:0] funct3Sv;
  logic [1:0] aluSrcASv,regSrcSv;
  logic aluSrcBSv;

  //Internal signals
  logic [31:0] a,b,r1Hz,r2Hz,srcA,srcB,pcPlusImm,immExt;
  logic [2:0] funct3;
  logic [1:0] aluSrcA;
  logic jump,funct7_6,branchFlag,isJalr,useRegAdd,bPredictedTaken,useF7,csrRead,aluSrcB;


  assign a = aSv;
  assign b = bSv;
  assign pc = pcSv;
  assign immExt = immExtSv;
  assign pcPlus4 = pcPlus4Sv;
  assign rdAddr = rdAddrSv;
  assign r1Addr = r1AddrSv;
  assign r2Addr = r2AddrSv;

  assign branch = branchSv;
  assign jump = jumpSv;
  assign regWrite = regWriteSv&((!csrOpSv&!csrRead)|csrRead);
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
  assign csrAddr = csrAddrSv;



  //HAZARD MUX
  always_comb
  begin
    case (fwdA)
      2'b00:
        r1Hz = a; //No fwd
      2'b10:
        r1Hz = aluResultM; //Mem fwd
      2'b01:
        r1Hz = resultW; //Write Back fwd
      default:
        r1Hz = a; //No fwd
    endcase
  end
  always_comb
  begin
    case (fwdB)
      2'b00:
        r2Hz = b; //No fwd
      2'b10:
        r2Hz = aluResultM; //Mem fwd
      2'b01:
        r2Hz = resultW; //Write Back fwd
      default:
        r2Hz = b; //No fwd
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
  assign pcSel = (branch&branchFlag) | jump;
  assign wrongBranch = pcSel^bPredictedTaken; //flush when pcSelE is there xor bPredictTaken
  assign controlXfer = pcSel; //use something else?

  alu alu (
        .funct3(funct3),
        .useF7(useF7),
        .funct7_6(funct7_6),
        .csrOp(csrOpSv),
        .useRegAdd(useRegAdd),
        .srcA(srcA),
        .srcB(srcB),
        .aluResult(aluResult),
        .branchFlag(branchFlag),
        .branch(branch)
      );
  csrUnit csrU (
            .r1Addr(r1Addr),
            .rdAddr(rdAddr),
            .funct3(funct3[1:0]),
            .csr(r2Hz),
            .rs1Uimm(r1Hz),
            .csrResult(csrResult),
            .csrRead(csrRead),
            .csrWrite(csrWrite),
            .csrOp(csrOpSv)
          );
  always_ff@(posedge clk)
  begin
    if(rst|flush)
    begin
      aSv <= 0;
      bSv <= 0;
      r1AddrSv <= 0;
      r2AddrSv <= 0;
      rdAddrSv <= 0;
      pcPlus4Sv <= 0;
      pcSv <= 0;

      funct3Sv <= 0;
      useF7Sv    <= 0;
      funct7_6Sv <= 0;
      regWriteSv <= 0;
      memWriteSv <= 0;
      branchSv <=   0;
      jumpSv <=     0;
      csrOpSv <=     0;
      aluSrcASv <=  0;
      aluSrcBSv  <= 0;
      useRegAddSv <= 0;
      regSrcSv <=      0;
      bPredictedTakenSv <= 0;
      csrAddrSv <= 0;


    end
    else
    begin
      aSv <= aD;
      bSv <= bD;
      immExtSv <= immExtD;
      r1AddrSv <= r1AddrD;
      r2AddrSv <= r2AddrD;
      rdAddrSv <= rdAddrD;
      pcPlus4Sv <= pcPlus4D;
      pcSv <= pcD;
      funct3Sv <= funct3D;
      useF7Sv    <= useF7D;
      funct7_6Sv <= funct7_6D;
      regWriteSv <= regWriteD;
      memWriteSv <= memWriteD;
      branchSv <=   branchD;
      jumpSv <=     jumpD;
      csrOpSv <= csrOpD;
      aluSrcASv <=  aluSrcAD;
      aluSrcBSv <= aluSrcBD;
      useRegAddSv <=      useRegAddD;
      regSrcSv <=      regSrcD;
      bPredictedTakenSv <= bPredictedTakenD;
      csrAddrSv <= csrAddrD;
    end
  end


endmodule
