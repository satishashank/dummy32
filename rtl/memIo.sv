`timescale 1ns / 1ps
module memIo (
  input  logic        clk  ,
  rst,
  input  logic        sIn  ,
  input  logic [31:0] wData,
  input  logic [31:0] addr ,
  input  logic [ 2:0] size ,
  input  logic        wEn  ,
  input  logic        rEn  ,
  output logic [31:0] rData,
  output logic        sOut
);

  localparam DEPTH            = 32            ; // depth in KB
  localparam BYTES            = (1024 * DEPTH); // total bytes
  localparam WORDS            = BYTES / 4     ; // number of 32-bit words
  localparam ADDR_WIDTH_WORDS = $clog2(WORDS) ;
  localparam UARTDWIDTH       = 8             ;

  (* ram_style = "block" *)logic [31:0] mem[WORDS-1:0];

  logic                  isUartTxStatus, isUartRxStatus, uartWen, uartTxWrite, uartRxRead, uartRen;
  logic [UARTDWIDTH-1:0] uartRxData    ;
  logic                  misaligned    ;
  logic [          31:0] rDataSv       ;
  logic [          31:0] uartTxStatus, uartRxStatus;
  logic [          31:0] mask32        ;
  logic [           7:0] uartWdata     ;
  logic                  rxFifoEmpty   ;
  logic                  txFifoFull    ;
  logic                  dmemWenFinal  ;




  logic [ADDR_WIDTH_WORDS-1:0] wordAddr;

  assign isUartTxStatus = (addr == 32'hFFFFFFF8);  // status reg
  assign isUartRxStatus = (addr == 32'hFFFFFFF0);
  assign uartTxWrite    = (addr == 32'hFFFFFFFC);
  assign uartRxRead     = (addr == 32'hFFFFFFF4);

  assign uartWdata = wData[7:0];

  assign uartWen      = uartTxWrite & wEn;
  assign dmemWenFinal = !uartTxWrite & wEn;
  assign uartRen      = uartRxRead & rEn;


  assign uartTxStatus = {31'b0, txFifoFull};
  assign uartRxStatus = {31'b0, rxFifoEmpty};
  assign wordAddr     = addr[ADDR_WIDTH_WORDS+1:2];
  assign rData        = rDataSv;


  always_comb begin
    misaligned = 1'b0;
    case (size)
      3'b000, 3'b100: misaligned = 1'b0;
      3'b001, 3'b101:  // LHU
        misaligned = (addr[0] != 1'b0);
      3'b010  : misaligned = (addr[1:0] != 2'b00);
      default : misaligned = 1'b1;
    endcase
  end

  always_comb begin
    mask32 = 32'h0;
    case (size)
      3'b000  : mask32 = 32'hFF << (8 * addr[1:0]);
      3'b001  : mask32 = 32'hFFFF << (16 * addr[1]);
      3'b010  : mask32 = 32'hFFFF_FFFF;
      default : mask32 = 32'h0;
    endcase
  end

  // synchronous read/write
  always_ff @(posedge clk) begin
    // STORE (synchronous writes)
    if (dmemWenFinal) begin
      if (!misaligned) begin
        unique case (size)
          3'b000 : // SB
            mem[wordAddr] <= (mem[wordAddr] & ~mask32) | ((wData & 32'hFF) << (8 * addr[1:0]));
          3'b001 : // SH
            mem[wordAddr] <= (mem[wordAddr] & ~mask32) | ((wData & 32'hFFFF) << (16 * addr[1]));
          3'b010 : // SW
            mem[wordAddr] <= wData;
          default : ;  // ignore invalid store sizes
        endcase
      end
      // if misaligned -> write ignored (could be changed to trap/flag externally)
    end

    // LOAD (synchronous readback)
    if (rEn) begin
      if(misaligned)begin
        rDataSv <= 32'hDEADC0DE;  // sentinel for misaligned/invalid access
      end
      else begin
        if (isUartTxStatus) begin
          rDataSv <= uartTxStatus;
        end
        else if (isUartRxStatus) begin
          rDataSv <= uartRxStatus;
        end
        else if (uartRxRead) begin
          rDataSv <= {24'b0,uartRxData};
        end
        else begin

          unique case (size)
            3'b000 : begin
              rDataSv <= {{24{mem[wordAddr][8*addr[1:0]+:8][7]}}, mem[wordAddr][8*addr[1:0]+:8]};
            end
            3'b100 : begin
              rDataSv <= {24'b0, mem[wordAddr][8*addr[1:0]+:8]};
            end
            3'b001 : begin
              rDataSv <= {{16{mem[wordAddr][16*addr[1]+:16][15]}}, mem[wordAddr][16*addr[1]+:16]};
            end
            3'b101 : begin  // LHU (unsigned halfword)
              rDataSv <= {16'b0, mem[wordAddr][16*addr[1]+:16]};
            end
            3'b010 : begin  // LW
              rDataSv <= mem[wordAddr];
            end
            default : rDataSv <= 32'hDEADC0DE;
          endcase
        end
      end

    end
  end

  initial begin
    $readmemh("data.mem", mem);
  end

  uartTx uartTx (
    .clk(clk),
    .rst(rst),
    .data(uartWdata),
    .dataWen(uartWen),
    .fifoFull(txFifoFull),
    .sOut(sOut)
  );

  uartRx uartRx (
    .clk      (clk        ),
    .rst      (rst        ),
    .data     (uartRxData ),
    .rEn      (uartRen    ),
    .fifoEmpty(rxFifoEmpty),
    .sIn      (sIn        )
  );
endmodule
