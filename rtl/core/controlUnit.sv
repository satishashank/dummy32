`timescale 1ns/1ps
module controlUnit (
    input logic [4:0] op,
    input logic [2:0] funct3,
    output logic regWrite,memWrite,
    output logic branch,
    output logic jump,
    output logic [2:0] immCntrl,
    output logic [1:0] aluSrcA,
    output logic useF7,
    output logic [1:0] regSrc,
    output logic useRegAdd,
    output logic aluSrcB
  );

  logic shift;
  logic wrongOpcode;
  assign shift = (!funct3[1])&(funct3[0]);
  assign aluSrcB = (~branch)&(|immCntrl);
  localparam [4:
              0]
             OPCODE_RTYPE  = 5'b01100,
             OPCODE_IARTHTYPE  = 5'b00100,
             OPCODE_LOADTYPE  = 5'b00000,
             OPCODE_STYPE  = 5'b01000,
             OPCODE_BTYPE = 5'b11000,
             OPCODE_AUIPC =  5'b00101,
             OPCODE_LUI =  5'b01101,
             OPCODE_JAL    = 5'b11011,
             OPCODE_JALR   = 5'b11001,
             OPCODE_CSR = 5'b11100;
  localparam [2:
              0]
             IMM_TYPE_DEFAULT = 3'b000, //No imm val
             IMM_TYPE_SHAMT   = 3'b001,
             IMM_TYPE_I    = 3'b010,
             IMM_TYPE_S    = 3'b011,
             IMM_TYPE_B    = 3'b100,
             IMM_TYPE_U    = 3'b101,
             IMM_TYPE_J    = 3'b110;
  localparam [1:
              0]
             ALU_SRC = 2'b00,
             MEM_SRC = 2'b01,
             PC_SRC = 2'b10,
             CSR = 2'b11;

  localparam [1:
              0]
             RS1 = 2'b0,
             ZERO = 2'b11,
             PC = 2'b1;


  always_comb
  begin
    aluSrcA = RS1;
    wrongOpcode = 0;
    immCntrl = IMM_TYPE_DEFAULT;
    useF7 = 0;
    branch = 0;
    jump = 0;
    useRegAdd = 0;
    regWrite = 1;
    memWrite = 0;
    regSrc = ALU_SRC;

    case (op)
      OPCODE_RTYPE:
      begin
        useF7 = 1;
      end
      OPCODE_IARTHTYPE:
      begin
        immCntrl = shift?IMM_TYPE_SHAMT:IMM_TYPE_I;
        useF7 = shift;
      end
      OPCODE_LOADTYPE:
      begin
        regSrc = MEM_SRC;
        immCntrl = IMM_TYPE_I;
        useRegAdd = 1;
      end
      OPCODE_STYPE:
      begin
        memWrite = 1;
        regWrite = 0;
        immCntrl = IMM_TYPE_S;
        useRegAdd = 1;
      end
      OPCODE_BTYPE:
      begin
        branch = 1;
        regWrite = 0;
        immCntrl = IMM_TYPE_B;
      end
      OPCODE_JAL,OPCODE_JALR:
      begin
        regSrc = PC_SRC;
        jump = 1;
        immCntrl = op[1]?IMM_TYPE_J:IMM_TYPE_I;
        useRegAdd = !op[1];
      end
      OPCODE_AUIPC,OPCODE_LUI:
      begin
        regSrc = ALU_SRC;
        immCntrl = IMM_TYPE_U;
        useRegAdd = 1;
        aluSrcA = op[3]?ZERO:PC;
      end
      default:
      begin
        wrongOpcode = 1;
        aluSrcA = RS1;
        immCntrl = IMM_TYPE_DEFAULT;
        useF7 = 0;
        branch = 0;
        jump = 0;
        useRegAdd = 0;
        regWrite = 1;
        regSrc = ALU_SRC;
      end
    endcase
  end
endmodule
