set_property PACKAGE_PIN E3 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -name sys_clk -period 10.000 [get_ports clk]

## UART TX pin to USB-UART bridge
set_property PACKAGE_PIN W17 [get_ports uartSout]
set_property IOSTANDARD LVCMOS33 [get_ports uartSout]

## Reset mapped to BTN0
set_property PACKAGE_PIN N17 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]