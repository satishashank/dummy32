module csrUnit (
    input [4:0] r1Addr,rdAddr,
    input logic csrOp,
    input logic [1:0]  funct3,
    input logic [31:0] csr,
    input logic [31:0] rs1Uimm,
    output logic[31:0] csrResult,
    output logic csrRead,csrWrite
  );
  logic csrReadIn,csrWriteIn;
  logic nrdIs0,nrIs0;

  assign  nrdIs0 = (|rdAddr);
  assign  nrIs0 = (|r1Addr);
  assign csrRead = csrReadIn&csrOp;
  assign csrWrite = csrWriteIn&csrOp;

  localparam [1:0]
             CSRRW = 2'b01,
             CSRRS = 2'b10,
             CSRRC = 2'b11;

  always_comb
  begin
    case (funct3)
      CSRRW:
      begin
        csrReadIn = nrdIs0;
        csrWriteIn = 1;
        csrResult = rs1Uimm;
      end
      CSRRC:
      begin
        csrReadIn = 1;
        csrWriteIn = nrIs0;
        csrResult = csr&(~rs1Uimm);
      end
      CSRRS:
      begin
        csrReadIn = 1;
        csrWriteIn = nrIs0;
        csrResult = csr|(rs1Uimm);
      end
      default:
      begin
        csrReadIn=0;
        csrWriteIn = 0;
      end
    endcase
  end
endmodule
