module btb (
    input  logic         clk,
    input  logic         rst,

    // Fetch stage inputs
    input  logic [31:0]  fetch_pc,
    output logic         fetch_btb_hit,
    output logic [31:0]  fetch_btb_target,

    // EX stage update inputs
    input  logic         ex_update,
    input  logic [31:0]  ex_pc,
    input  logic [31:0]  ex_target
  );

  logic [4:0] fetch_index = fetch_pc[6:2];
  logic [24:0]   fetch_tag   = fetch_pc[31:7];
  logic [4:0] ex_index = ex_pc[6:2];
  logic [24:0]   ex_tag   = ex_pc[31:7];

  typedef struct packed {
            logic valid;
            logic [24:0] tag;
            logic [31:0] target;
          } btb_entry_t;

  btb_entry_t btb_mem[31:0];
  assign fetch_btb_hit = btb_mem[fetch_index].valid && (btb_mem[fetch_index].tag == fetch_tag);
  assign fetch_btb_target = btb_mem[fetch_index].target;
  always_ff@(posedge clk)
  begin
    if (ex_update&&(!rst))
    begin
      btb_mem[ex_index].valid <= 1;
      btb_mem[ex_index].tag <= ex_tag;
      btb_mem[ex_index].target <= ex_target;
    end
  end

endmodule
