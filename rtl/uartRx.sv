`timescale 1ns / 1ps
module uartRx #(
  parameter     DIV    = 8,
  parameter int DWIDTH = 8,
  parameter int FDEPTH = 4
) (
  input  logic              clk      ,
  input  logic              rst      ,
  output logic              fifoEmpty,
  output logic [DWIDTH-1:0] data     ,
  input  logic              sIn      ,
  input  logic              rEn
);

  logic              fifoRden, fifoFull, fifoWen;
  logic [DWIDTH-1:0] fifoDout;

  logic [$clog2(DIV)-1:0] baud_cnt;
  logic                   baud_en, baud_start;


  always_ff @(posedge clk) begin
    if (rst) begin
      baud_cnt <= 0;
      baud_en  <= 0;
    end else if (baud_start) begin
      if (baud_cnt == DIV - 1) begin
        baud_cnt <= 0;
        baud_en  <= 1;
      end else begin
        baud_cnt <= baud_cnt + 1;
        baud_en  <= 0;
      end
    end
  end

  typedef enum logic [1:0] {
    START,
    DATA,
    STOP
  } state_t;
  state_t state;


  logic [      DWIDTH-1:0] shiftReg;
  logic [$clog2(DWIDTH):0] bitCnt  ;
  logic                    uartBusy;
  assign data     = fifoDout;
  assign fifoRden = rEn | fifoFull;


  always_ff @(posedge clk) begin
    if (rst) begin
      state      <= START;
      bitCnt     <= 0;
      shiftReg   <= 0;
      uartBusy   <= 0;
      baud_start <= 0;
    end else if (rEn) begin
      fifoWen <= 0;
      case (state)
        START : begin
          bitCnt <= 0;
          if (!sIn) begin
            uartBusy   <= 1;
            state      <= DATA;
            baud_start <= 1;
          end
        end
        DATA : begin
          if (baud_en) begin
            shiftReg <= {sIn, shiftReg[7:1]};
            if (bitCnt == DWIDTH - 1) begin
              bitCnt <= 0;
              state  <= STOP;
            end else bitCnt <= bitCnt + 1;
          end
        end

        STOP :
          if (baud_en & sIn) begin
            uartBusy   <= 0;
            state      <= START;
            baud_start <= 0;
            baud_cnt   <= 0;
            fifoWen    <= 1;
          end
        default : state <= START;
      endcase
    end
  end

  fifo #(
    .DWIDTH(DWIDTH),
    .DEPTH (FDEPTH)
  ) fifo_inst (
    .rst  (rst      ),
    .clk  (clk      ),
    .wr_en(fifoWen  ),
    .rd_en(fifoRden ),
    .din  (shiftReg ),
    .dout (fifoDout ),
    .empty(fifoEmpty),
    .full (fifoFull )
  );
endmodule
