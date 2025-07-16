module hazardUnit(output logic [1:0] fwdAE,
                    output logic [1:0] fwdBE,
                    output logic flushE,
                    output logic flushD,
                    output logic stallD,
                    output logic stallF,
                    input logic [4:0] r1AddrE,
                    input logic [4:0] r2AddrE,
                    input logic [4:0] r1AddrD,
                    input logic [4:0] r2AddrD,
                    input logic [4:0] rdM,
                    input logic [4:0] rdE,
                    input logic [4:0] rdW,
                    input logic regWriteM,
                    input logic regWriteW,
                    input logic regSrcE0,
                    input logic pcSelE
                   );
  logic r1EqMem,r2EqMem,r1EqW,r2EqW;
  logic lwStall;

  assign stallD = lwStall;
  assign flushE = lwStall|pcSelE;
  assign flushD = pcSelE;
  assign stallF = lwStall;
  assign lwStall = regSrcE0&((r1AddrD==rdE)|(r2AddrD==rdE))&&(rdE!=0);
  assign r1EqMem = (r1AddrE == rdM)&&(rdM != 0);
  assign r2EqMem = (r2AddrE == rdM)&&(rdM != 0);
  assign r1EqW = (r1AddrE == rdW)&&(rdW != 0);
  assign r2EqW = (r2AddrE == rdW)&&(rdW != 0);
  always_comb
  begin
    if (r1EqMem&regWriteM)
    begin
      fwdAE = 2'b10;
    end
    else if (r1EqW&regWriteW)
    begin
      fwdAE = 2'b01;
    end
    else
    begin
      fwdAE = 2'b00;
    end
  end
  always_comb
  begin
    if (r2EqMem&regWriteM)
    begin
      fwdBE = 2'b10;
    end
    else if (r2EqW&regWriteM)
    begin
      fwdBE = 2'b01;
    end
    else
    begin
      fwdBE = 2'b00;
    end
  end
endmodule
