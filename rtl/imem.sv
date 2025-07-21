module imem #(
    parameter DEPTH = 16383  // Number of 32-bit words 64kb for now
  )(
    output logic [31:0] rData,
    input logic [31:0] rAddr,
    input logic clk
  );
  localparam ADDR_WIDTH = $clog2(DEPTH);
  logic [31:0] mem [0:DEPTH-1];
  assign rData = mem[rAddr[ADDR_WIDTH+1:2]];

  initial
  begin
    $readmemh("code.mem",mem);
  end

endmodule
