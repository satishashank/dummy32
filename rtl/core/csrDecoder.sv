module csrDecoder (
    input logic [2:0] funct3,
    input logic [4:0] rs1Uimm,
    input logic [4:0] rd,
    output logic csrWrite,
    output logic csrRead,
    output logic invRs1,
    output logic useImm,
    output logic [31:0] csrImm
  );
  logic rdIs0,rsIs0;
  localparam [1:0]
             CSRRW = 2'b01,
             CSRRS = 2'b10,
             CSRRC = 2'b11;

  assign  rdIs0 = |rd;
  assign  rsIs0 = |rs1Uimm;
  assign useImm = funct3[2];
  assign csrImm = {27'b0,rs1Uimm};

  always_comb
  begin
    invRs1 = 0;
    case (funct3[1:0])
      CSRRW:
      begin
        csrRead = !rdIs0;
        csrWrite = 1;
      end
      CSRRS,CSRRC:
      begin
        csrRead = 1;
        csrWrite = !rsIs0;
        invRs1 = funct3[0];
      end
      default:
      begin
        csrRead=0;
        csrWrite = 0;
      end
    endcase
  end


endmodule
