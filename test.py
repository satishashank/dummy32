import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock

instr = [
    0x9FBB9FB3,
    0x58A0A6B3,
    0x3305F133,
    0xF46CDAB3,
    0xCA8EA7B3,
    0x438B5D33,
    0x45C3A033,
    0xE08C8B33,
    0xF3FC9BB3,
    0x05767AB3,
    0x58839A33,
    0x0A3904B3,
    0x504A5533,
    0x0E3AF1B3,
    0xBBDA3D33,
    0xA0CC83B3,
    0x5DBABA33,
    0xA7B7EDB3,
    0x947E3033,
    0xA3830E33,
]


@cocotb.test()
async def test(dut):
    clk = Clock(dut.clk, 1, "ns")
    cocotb.start_soon(clk.start())
    dut.rst_n.value = 1
    await Timer(10, "ns")
    dut.mem_busy = 1

    dut.rst_n.value = 0
    await Timer(10, "ns")
    dut.rst_n.value = 1

    await Timer(10, "ns")
    dut.mem_busy = 0
    for i in instr:
        await Timer(10, "ns")
        dut.mem_read = i
    await Timer(100, "ns")
