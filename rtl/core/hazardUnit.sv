module hazardUnit(  output logic [1:0] fwdAE,
                      output logic [1:0] fwdBE,
                      output logic flushE,
                      output logic flushD,flushF2,
                      output logic stallD,
                      output logic stallF,
                      input logic [4:0] r1AddrE,
                      input logic [4:0] r2AddrE,
                      input logic [4:0] r1AddrD,
                      input logic [4:0] r2AddrD,
                      input logic [4:0] rdM1,rdM2,
                      input logic [4:0] rdE,
                      input logic [4:0] rdW,
                      input logic regWriteM1,regWriteM2,
                      input logic regWriteW,
                      input logic regSrcE0,
                      input logic wrongBranchE
                   );
  logic r1EqMem1,r1EqMem2,r2EqMem1,r2EqMem2,r1EqW,r2EqW;
  logic lwStall;
  logic bStall; //for testing
  localparam [1:0]
             NO_FWD = 2'b00,
             MEM1_FWD = 2'b10,
             MEM2_FWD = 2'b11,
             WB_FWD = 2'b01
             ;
  assign stallD = lwStall;
  assign bStall = wrongBranchE;
  assign flushE = lwStall|bStall;
  assign flushD = bStall;
  assign flushF2 = bStall;
  assign stallF = lwStall;
  assign lwStall = regSrcE0&((r1AddrD==rdE)|(r2AddrD==rdE))&&(rdE!=0);
  assign r1EqMem1 = (r1AddrE == rdM1)&&(rdM1 != 0);
  assign r2EqMem1 = (r2AddrE == rdM1)&&(rdM1 != 0);
  assign r1EqMem2 = (r1AddrE == rdM2)&&(rdM2 != 0);
  assign r2EqMem2 = (r2AddrE == rdM2)&&(rdM2 != 0);
  assign r1EqW = (r1AddrE == rdW)&&(rdW != 0);
  assign r2EqW = (r2AddrE == rdW)&&(rdW != 0);
  always_comb
  begin
    if (r1EqMem1&regWriteM1)
    begin
      fwdAE = MEM1_FWD;
    end
    else if (r1EqMem2&regWriteM2)
    begin
      fwdAE = MEM2_FWD;
    end
    else if (r1EqW&regWriteW)
    begin
      fwdAE = WB_FWD;
    end
    else
    begin
      fwdAE = NO_FWD;
    end
  end
  always_comb
  begin
    if (r2EqMem1&regWriteM1)
    begin
      fwdBE = MEM1_FWD;
    end
    else if (r2EqMem2&regWriteM2)
    begin
      fwdBE = MEM2_FWD;
    end
    else if (r2EqW&regWriteW)
    begin
      fwdBE = WB_FWD;
    end
    else
    begin
      fwdBE = NO_FWD;
    end
  end
endmodule
