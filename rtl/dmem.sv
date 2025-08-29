module dmem #(
    parameter DEPTH = 32  // depth in KB
) (
    input  logic [31:0] wData,
    output logic [31:0] rData,
    input  logic [31:0] addr,
    input  logic [ 2:0] size,
    input  logic        clk,
    input  logic        wEn,
    input  logic        rEn,
    input  logic        uartFifoFull
);

  // derived params
  localparam BYTES = (1024 * DEPTH);  // total bytes
  localparam WORDS = BYTES / 4;  // number of 32-bit words
  localparam ADDR_WIDTH_WORDS = $clog2(WORDS);

  (* ram_style = "block" *) logic [31:0] mem[WORDS-1:0];

  logic isUartAddr;
  logic misaligned;
  logic [31:0] rDataSv;
  logic [31:0] uartStatus;
  logic [31:0] mask32;
  logic [7:0] b;
  logic [15:0] h;

  assign h = mem[wordAddr][16*addr[1]+:16];
  assign b = mem[wordAddr][8*addr[1:0]+:8];

  logic [ADDR_WIDTH_WORDS-1:0] wordAddr;

  assign isUartAddr = (addr == 32'hFFFFFFF8);
  assign rData      = rDataSv;
  assign uartStatus = {31'b0, uartFifoFull};

  assign wordAddr   = addr[ADDR_WIDTH_WORDS+1:2];


  always_comb begin
    misaligned = 1'b0;
    case (size)
      3'b000, 3'b100: misaligned = 1'b0;
      3'b001, 3'b101:  // LHU
      misaligned = (addr[0] != 1'b0);
      3'b010: misaligned = (addr[1:0] != 2'b00);
      default: misaligned = 1'b1;
    endcase
  end

  always_comb begin
    mask32 = 32'h0;
    case (size)
      3'b000:  mask32 = 32'hFF << (8 * addr[1:0]);
      3'b001:  mask32 = 32'hFFFF << (16 * addr[1]);
      3'b010:  mask32 = 32'hFFFF_FFFF;
      default: mask32 = 32'h0;
    endcase
  end

  // synchronous read/write
  always_ff @(posedge clk) begin
    // STORE (synchronous writes)
    if (wEn) begin
      if (!misaligned) begin
        unique case (size)
          3'b000:  // SB
          mem[wordAddr] <= (mem[wordAddr] & ~mask32) | ((wData & 32'hFF) << (8 * addr[1:0]));
          3'b001:  // SH
          mem[wordAddr] <= (mem[wordAddr] & ~mask32) | ((wData & 32'hFFFF) << (16 * addr[1]));
          3'b010:  // SW
          mem[wordAddr] <= wData;
          default: ;  // ignore invalid store sizes
        endcase
      end
      // if misaligned -> write ignored (could be changed to trap/flag externally)
    end

    // LOAD (synchronous readback)
    if (rEn) begin
      if (isUartAddr) begin
        rDataSv <= uartStatus;
      end else if (misaligned) begin
        rDataSv <= 32'hDEADC0DE;  // sentinel for misaligned/invalid access
      end else begin
        unique case (size)
          3'b000: begin
            rDataSv <= {{24{b[7]}}, b};
          end
          3'b100: begin
            rDataSv <= {24'b0, b};
          end
          3'b001: begin
            rDataSv <= {{16{h[15]}}, h};
          end
          3'b101: begin  // LHU (unsigned halfword)
            rDataSv <= {16'b0, h};
          end
          3'b010: begin  // LW
            rDataSv <= mem[wordAddr];
          end
          default: rDataSv <= 32'hDEADC0DE;
        endcase
      end
    end
  end

  initial begin
    $readmemh("data.mem", mem);
  end
endmodule
