module dmem (
    input logic [31:0] wData,
    output logic [31:0] rData,
    input logic [31:0] addr,
    input logic [2:0] size,
    input logic clk,
    input logic wEn
  );
  logic [7:0] mem [4095:0];
  logic [31:0] addrplus1;
  logic [31:0] addrplus2;
  logic [31:0] addrplus3;
  assign addrplus1 = addr + 1;
  assign addrplus2 = addr + 2;
  assign addrplus3 = addr + 3;

  always_ff@(posedge clk)
  begin
    if(wEn)
    begin
      case (size)
        3'b000:
          mem[addr] <= wData[7:0];
        3'b001:
        begin
          mem[addr] <= wData[7:0];
          mem[addrplus1] <= wData[15:8];
        end
        3'b010:
        begin
          mem[addr] <= wData[7:0];
          mem[addrplus1] <= wData[15:8];
          mem[addrplus2] <= wData[23:16];
          mem[addrplus3] <= wData[31:24];
        end
        default:
          mem[addr] <= mem[addr];
      endcase
    end
  end

  always_comb
  begin
    case (size)
      3'b000:
        rData = {24'b0,mem[addr]};
      3'b001:
        rData = {16'b0,mem[addrplus1],mem[addr]};
      3'b010:
        rData = {mem[addrplus3],mem[addrplus2],mem[addrplus1],mem[addr]};
      3'b100:
        rData = {{24{mem[addr][7]}},mem[addr]};
      3'b101:
        rData = {{16{mem[addr][7]}},mem[addrplus1],mem[addr]};
      default :
        rData =32'hDEADC0DE;
    endcase
  end
endmodule
