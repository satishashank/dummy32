module imem #(
    parameter DEPTH = 16383  //16K for now
  )(
    input logic rEn,oEn,
    output logic [31:0] rData,
    input logic [31:0] rAddr,
    input logic clk
  );
  localparam ADDR_WIDTH = $clog2(DEPTH);
  logic [31:0] mem [0:DEPTH-1];

  always_ff@(posedge clk)
  begin
    if(rEn)
    begin
      rData <= oEn?mem[rAddr[ADDR_WIDTH+1:2]]:0;
    end
  end

  initial
  begin
    $readmemh("code.mem",mem);
  end

endmodule
