`timescale 1ns/1ps
module uartTx #(
    parameter DIV = 8,
    parameter int DWIDTH  = 8,
    parameter int FDEPTH = 16
  )(
    input  logic              clk,
    input  logic              rst,
    input  logic [DWIDTH-1:0] data,
    input  logic              dataWen,
    output logic              fifoFull,
    output logic              sOut
  );

  logic fifoRden, fifoEmpty, fifoWen;
  logic [DWIDTH-1:0] fifoDout;
  assign fifoWen = dataWen;

  logic [$clog2(DIV)-1:0] baud_cnt;
  logic baud_en;

  always_ff @(posedge clk)
  begin
    if (rst)
    begin
      baud_cnt <= 0;
      baud_en  <= 0;
    end
    else if (baud_cnt == DIV-1)
    begin
      baud_cnt <= 0;
      baud_en  <= 1;
    end
    else
    begin
      baud_cnt <= baud_cnt + 1;
      baud_en  <= 0;
    end
  end

  typedef enum logic [2:0] {IDLE, RD, START, DATA, STOP} state_t;
  state_t state;

  logic [DWIDTH-1:0] shiftReg;
  logic [$clog2(DWIDTH):0] bitCnt;
  logic uartBusy;

  always_ff @(posedge clk)
  begin
    if (rst)
    begin
      state    <= IDLE;
      sOut     <= 1'b1;
      bitCnt   <= 0;
      shiftReg <= 0;
      uartBusy <= 0;
      fifoRden <= 0;
    end
    else
    begin
      fifoRden <= 0;
      case (state)
        IDLE:
        begin
          sOut <= 1'b1;
          bitCnt <= 0;
          if (!fifoEmpty)
          begin
            uartBusy <= 1;
            state    <= RD;
            fifoRden <= 1; //ptr incremented,dout has data
          end
        end
        RD:
        begin
          state <= START;
          //one cycle delay
        end
        START:
          if (baud_en)
          begin
            sOut     <= 1'b0;
            state    <= DATA;
            shiftReg <= fifoDout; //prev data stored
          end
        DATA:
        begin
          if (baud_en)
          begin
            sOut     <= shiftReg[0];
            shiftReg <= shiftReg >> 1;
            if (bitCnt == DWIDTH-1)
            begin
              bitCnt <= 0;
              state  <= STOP;
            end
            else
              bitCnt <= bitCnt + 1;
          end
        end

        STOP:
          if (baud_en)
          begin
            sOut     <= 1'b1;
            uartBusy <= 0;
            state    <= IDLE;
          end
        default:
          state <= IDLE;
      endcase
    end
  end

  fifo #(.DWIDTH(DWIDTH),.DEPTH(FDEPTH)) fifo_inst (
         .rst   (rst),
         .clk   (clk),
         .wr_en (fifoWen),
         .rd_en (fifoRden),
         .din   (data),
         .dout  (fifoDout),
         .empty (fifoEmpty),
         .full  (fifoFull)
       );

endmodule
