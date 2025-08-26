import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotbext.uart import UartSink


@cocotb.test()
async def isa_test(dut):
    baud = 20000
    freq = 1 #in Mhz
    # cocotb.log.setLevel("ERROR")
    """Try accessing the design."""
    clk = Clock(dut.clk, freq, "us")
    uart_sink = UartSink(dut.sOut, baud=baud, bits=8)
    cocotb.start_soon(clk.start())
    dut.rst.value = 1

    await Timer(2,"ns")
    dut.rst.value = 0
    await Timer(10,"ns")
    await RisingEdge(dut.clk)
    dut.data.value = 0x68
    dut.dataWen.value = 1
    await RisingEdge(dut.clk)
    dut.dataWen.value = 0
    dut.data.value = 0x65
    dut.dataWen.value = 1
    await RisingEdge(dut.clk)
    dut.dataWen.value = 0
    await RisingEdge(dut.clk)
    dut.data.value = 0x6c
    dut.dataWen.value = 1
    await RisingEdge(dut.clk)
    dut.dataWen.value = 0
    dut.data.value = 0x6c
    dut.dataWen.value = 1
    await RisingEdge(dut.clk)
    dut.dataWen.value = 0
    dut.data.value = 0x6f
    dut.dataWen.value = 1
    await RisingEdge(dut.clk)
    dut.dataWen.value = 0
    text = bytearray()
    for i in range(5):
        data = await uart_sink.read()
        text = text + data
    print(text.decode("ascii"))

    await Timer(1000,"ns")

