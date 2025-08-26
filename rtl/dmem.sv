module dmem #(
    parameter DEPTH = 32 //32K
  )(
    input logic [31:0] wData,
    output logic [31:0] rData,
    input logic [31:0] addr,
    input logic [2:0] size,
    input logic clk,
    input logic wEn,rEn,uartFifoFull
  );
  logic [7:0] mem [(1024*DEPTH)-1:0];
  logic isUartAddr;
  logic [31:0] addrplus1;
  logic [31:0] addrplus2;
  logic [31:0] addrplus3;
  logic [31:0] addrMinusOff;
  logic [31:0] rDataSv,uartStatus;

  assign isUartAddr = addr == 32'hFFFFFFF8;

  assign addrMinusOff = {4'b0,addr[27:0]};
  assign addrplus1 = addrMinusOff + 1;
  assign addrplus2 = addrMinusOff + 2;
  assign addrplus3 = addrMinusOff + 3;
  assign rData = rDataSv;
  assign uartStatus = {31'b0, uartFifoFull};

  always_ff@(posedge clk)
  begin
    if(wEn)
    begin
      case (size)
        3'b000:
          mem[addrMinusOff] <= wData[7:0];
        3'b001:
        begin
          mem[addrMinusOff] <= wData[7:0];
          mem[addrplus1] <= wData[15:8];
        end
        3'b010:
        begin
          mem[addrMinusOff] <= wData[7:0];
          mem[addrplus1] <= wData[15:8];
          mem[addrplus2] <= wData[23:16];
          mem[addrplus3] <= wData[31:24];
        end
        default:
          mem[addrMinusOff] <= mem[addrMinusOff];
      endcase
    end
    if(rEn)
    begin
      if(isUartAddr)
      begin
        rDataSv <= uartStatus;
      end
      else
      begin
        case (size)
          3'b000:
            rDataSv <= {{24{mem[addr][7]}},mem[addrMinusOff]};
          3'b001:
            rDataSv <= {{16{mem[addrplus1][7]}},mem[addrplus1],mem[addrMinusOff]};
          3'b010:
            rDataSv <= {mem[addrplus3],mem[addrplus2],mem[addrplus1],mem[addrMinusOff]};
          3'b100:
            rDataSv <= {24'b0,mem[addrMinusOff]};
          3'b101:
            rDataSv <= {16'b0,mem[addrplus1],mem[addrMinusOff]};
          default :
            rDataSv <= 32'hDEADC0DE;
        endcase
      end

    end
  end
  initial
  begin
    $readmemh("data.mem",mem);
  end
endmodule
