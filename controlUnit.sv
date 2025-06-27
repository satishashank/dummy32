`timescale 1ns/1ps
module controlUnit (
    input logic [4:0] op,
    input logic [2:0] funct3,
    input logic funct7_6,
    output logic regWrite,
    output logic memWrite,
    output logic branch,
    output logic jump,
    output logic [3:0] aluCntrl,
    output logic [2:0] immCntrl,
    output logic [1:0] aluSrcA,
    output logic aluSrcB,
    output logic inv,
    output logic [1:0] regSrc
  );

  localparam [4:0]
             OPCODE_RTYPE  = 5'b01100,
             OPCODE_IARTHTYPE  = 5'b00100,
             OPCODE_ILOADTYPE  = 5'b00000,
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
             PC_SRC = 2'b11,
             DC = 2'b10;
  localparam [1:0]
             RS1 = 0,
             ZERO = 2'b01,
             PC = 2'b11;

  assign aluSrcB = |immCntrl;

  always_comb
  begin
    case (op)
      OPCODE_RTYPE,OPCODE_IARTHTYPE :
      begin // R-type/I-type arith
        aluCntrl = {funct7_6,funct3};
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
        aluCntrl = 4'b0000;
        inv = 0;
        regWrite = 0;
        memWrite = 1;
        branch = 0;
        jump = 0;
        immCntrl = IMM_TYPE_S;
        regSrc = DC;
        aluSrcA = RS1;
      end
      OPCODE_BTYPE :
      begin // B-type
        aluCntrl = {2'b10,funct3[2:1]};
        regWrite = 0;
        memWrite = 0;
        branch = 1;
        jump = 0;
        immCntrl = IMM_TYPE_B;
        inv = funct3[0];
        regSrc = DC;
        aluSrcA = RS1;
      end
      OPCODE_ILOADTYPE,OPCODE_AUIPC,OPCODE_LUI :
      begin // (I)L-type/U-type
        aluCntrl = 4'b0000;
        regWrite = 1;
        memWrite = 0;
        branch = 0;
        jump = 0;
        immCntrl = op[0]?IMM_TYPE_U:IMM_TYPE_I;
        inv = 0;
        regSrc = op[2]?ALU_SRC:MEM_SRC;
        aluSrcA = op[3]?ZERO:PC;
      end
      OPCODE_JAL,OPCODE_JALR :
      begin
        aluCntrl = 4'b0000;
        regWrite = 1;
        memWrite = 0;
        branch = 0;
        jump = 1;
        immCntrl = op[1]?IMM_TYPE_J:IMM_TYPE_I;
        inv = 0;
        regSrc = PC_SRC;
        aluSrcA = RS1;
      end
      default:
      begin
        aluCntrl = 4'b0000;
        regWrite = 0;
        memWrite = 0;
        branch = 0;
        jump = 0;
        immCntrl = 0;
        inv = 0;
        regSrc = DC;
        aluSrcA = RS1;
      end
    endcase
  end

endmodule
