`timescale 1ns/1ps
module fifo #(parameter DEPTH=4, DWIDTH=8)

  (
    input  logic rst,               // Active high reset
    input  logic clk,                // Clock
    input  logic wr_en, 				// Write enable
    input  logic rd_en, 				// Read enable
    input  logic [DWIDTH-1:0] din, 				// Data written into FIFO
    output logic [DWIDTH-1:0] dout, 				// Data read from FIFO
    output logic empty, 				// FIFO is empty when high
    output logic full 				// FIFO is full when high
  );

  logic [DWIDTH-1:0] fifo_vector [DEPTH];
  logic [$clog2(DEPTH)-1:0] rd_ptr,wr_ptr,wr_ptr_plus1;
  assign wr_ptr_plus1 = wr_ptr + 1;

  always @(posedge clk)
  begin
    if (rst)
    begin
      wr_ptr <= 0;
      rd_ptr <= 0;
    end
    else
    begin
      // Write operation
      if (wr_en && !full)
      begin
        fifo_vector[wr_ptr] <= din;
        wr_ptr <= (wr_ptr_plus1);
      end
      // Read operation
      if(!empty)
      begin
        if (rd_en)
        begin
          dout <= fifo_vector[rd_ptr]; //read previous data
          rd_ptr <= (rd_ptr + 1); // point to next
        end
      end

    end
  end
  assign empty = rd_ptr == wr_ptr;
  assign full  = rd_ptr == (wr_ptr_plus1); //depth - 1 values
endmodule
