# test_my_design.py (simple)

import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotbext.uart import UartSink

async def uart_printer(sink:UartSink,clock):
    while(True):
        await RisingEdge(clock)
        data = await sink.read()
        print(data.decode("ascii"),end="")
@cocotb.test()
async def isa_test(dut):
    """Try accessing the design."""
    freq = 1e9
    div = 2
    baud = freq/div
    clk = Clock(dut.clk, 1, "ns")
    dut.usePredictor.value = 1;
    uart_sink = UartSink(dut.uartSout, baud=baud, bits=8)
    uart_sink.log.setLevel("ERROR")

    cocotb.start_soon(clk.start())
    cocotb.start_soon(uart_printer(uart_sink,dut.clk))
    writeData = []
    writeAddr = []
    writePc = []
    dut.rst.value = 1
    await Timer(10, "ns")
    dut.rst.value = 0
    await Timer(10, "ns")
    memWriteAddr = []
    while(True):
        await Timer(1,"ns")
        if (dut.dummy32.uut.decode.regF.writeData.value == 0xDEADC0DE):
            break
       
    await Timer(2000,"ns")
    
