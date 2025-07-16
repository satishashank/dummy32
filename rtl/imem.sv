module imem (
    output logic [31:0] rData,
    input logic [31:0] rAddr,
    input logic clk
  );
  logic [31:0] mem [2047:0];
  assign rData = mem[rAddr[12:2]];
  initial
  begin
    $readmemh("code.mem",mem);
  end

endmodule
