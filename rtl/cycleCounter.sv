module cycleCounter (
    input logic turnOn,
    input logic turnOff,
    input logic clk,
    input logic rst,
    output logic [31:0] count
  );
  logic timerOn;
  logic [31:0] counter;
  assign count = counter;
  always_ff@(posedge clk)
  begin

    if(!rst)
    begin
      if(timerOn)
      begin
        counter <= counter +1;
      end
      if(turnOn)
      begin
        timerOn <= 1;
      end
      else if (turnOff)
      begin
        timerOn <= 0;
      end
    end
    else
      timerOn <= 0;

  end



endmodule
