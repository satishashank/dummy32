module simUart (
    input logic clk,
    input logic rst,
    input logic wEn,
    input logic [7:0] data
  );

  always_ff@(posedge clk)
  begin
    if(!rst&wEn)
    begin
      $write("%c", data);
    end
  end
endmodule
