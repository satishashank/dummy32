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
                    input logic usePredict,
                    input logic pcSelE,// for testing
                    input logic wrongBranchE
                   );
  logic r1EqMem,r2EqMem,r1EqW,r2EqW;
  logic lwStall;
  logic bStall; //for testing
  localparam [1:0]
             NO_FWD = 2'b00,
             MEM_FWD = 2'b10,
             WB_FWD = 2'b01
             ;
  assign stallD = lwStall;
  assign bStall = usePredict?wrongBranchE:pcSelE;
  assign flushE = lwStall|bStall;
  assign flushD = bStall;
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
      fwdAE = MEM_FWD;
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
    if (r2EqMem&regWriteM)
    begin
      fwdBE = MEM_FWD;
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
