`timescale 1ns/1ps
module controlUnit (
    input logic [4:0] op,
    input logic [2:0] funct3,
    input logic funct7_6,
    output logic regWrite,
    output logic memWrite,
    output logic branch,
    output logic jump,
    output logic [2:0] aluCntrl,
    output logic [2:0] immCntrl,
    output logic [1:0]aluSrcA,
    output logic aluSrcB,
    output logic inv,
    output logic useF7,
    output logic [1:0] regSrc,
    output logic pcTargetSrc,
    output logic loadStore
  );

  localparam [4:0]
             OPCODE_RTYPE  = 5'b01100,
             OPCODE_IARTHTYPE  = 5'b00100,
             OPCODE_LOADTYPE  = 5'b00000,
             OPCODE_STYPE  = 5'b01000,
             OPCODE_BTYPE = 5'b11000,
             OPCODE_AUIPC =  5'b00101,
             OPCODE_LUI =  5'b01101,
             OPCODE_JAL    = 5'b11011,
             OPCODE_JALR   = 5'b11001;
  localparam [2:0]
             IMM_TYPE_DEFAULT = 3'b000, //No imm val
             IMM_TYPE_SHAMT   = 3'b001,
             IMM_TYPE_I    = 3'b010,
             IMM_TYPE_S    = 3'b011,
             IMM_TYPE_B    = 3'b100,
             IMM_TYPE_U    = 3'b101,
             IMM_TYPE_J    = 3'b110;
  localparam [1:0]
             ALU_SRC = 2'b00,
             MEM_SRC = 2'b01,
             PC_SRC = 2'b10;

  localparam [1:0]
             RS1 = 2'b0,
             ZERO = 2'b11,
             PC = 2'b1;


  assign aluSrcB = (~branch)&(|immCntrl);
  assign pcTargetSrc = ((jump)&(!op[1]))&(~branch); //use Imm+rs1 instead

  always_comb
  begin
    regSrc = ALU_SRC;
    useF7 = 0;
    loadStore = 0;
    case (op)
      OPCODE_RTYPE,OPCODE_IARTHTYPE :
      begin // R-type/I-type arith
        aluCntrl = funct3;
        useF7 = op[3]&funct7_6;
        inv = 0;
        regWrite = 1;
        memWrite = 0;
        branch = 0;
        jump = 0;
        immCntrl = op[3] ? IMM_TYPE_DEFAULT : ((~funct3[1]&funct3[0]) ? IMM_TYPE_SHAMT:IMM_TYPE_I); //shamt vs imm
        regSrc = ALU_SRC;
        aluSrcA = RS1;
      end
      OPCODE_STYPE :
      begin // S-type
        aluCntrl = funct3;
        loadStore = 1;
        inv = 0;
        useF7 = 0;
        regWrite = 0;
        memWrite = 1;
        branch = 0;
        jump = 0;
        immCntrl = IMM_TYPE_S;
        aluSrcA = RS1;
      end
      OPCODE_BTYPE :
      begin // B-type
        aluCntrl = {1'b0,funct3[2:1]};
        useF7 = ~(|funct3[2:1]); //use for neq and eq
        regWrite = 0;
        memWrite = 0;
        branch = 1;
        jump = 0;
        immCntrl = IMM_TYPE_B;
        inv = funct3[0];
        aluSrcA = RS1;
      end
      OPCODE_LOADTYPE:
      begin // (I)L-type
        aluCntrl = funct3;
        loadStore = 1;
        regWrite = 1;
        memWrite = 0;
        branch = 0;
        jump = 0;
        immCntrl = IMM_TYPE_I;
        inv = 0;
        regSrc = MEM_SRC;
        aluSrcA = RS1;
      end
      OPCODE_LUI:
      begin
        aluCntrl = 3'b0;
        regWrite = 1;
        memWrite = 0;
        branch = 0;
        jump = 0;
        immCntrl = IMM_TYPE_U;
        inv = 0;
        regSrc = ALU_SRC;
        aluSrcA = ZERO;
      end
      OPCODE_AUIPC:
      begin
        aluCntrl = 3'b0;
        regWrite = 1;
        memWrite = 0;
        branch = 0;
        jump = 0;
        immCntrl = IMM_TYPE_U;
        inv = 0;
        regSrc = ALU_SRC;
        aluSrcA = PC;
      end
      OPCODE_JAL,OPCODE_JALR:
      begin
        aluCntrl = 3'b0;
        regWrite = 1;
        memWrite = 0;
        branch = 0;
        jump = 1;
        immCntrl = IMM_TYPE_J;
        inv = 0;
        regSrc = PC_SRC;
        aluSrcA = RS1;
      end
      default:
      begin
        aluCntrl = 3'b0;
        useF7 = 0;
        regWrite = 0;
        memWrite = 0;
        branch = 0;
        jump = 0;
        immCntrl = 0;
        inv = 0;
        aluSrcA = RS1;
        loadStore = 0;
      end
    endcase
  end
endmodule
