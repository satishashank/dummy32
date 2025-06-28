# test_my_design.py (simple)

import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock

program = [
    0x00408193, #addi x3, x1, 4
    0x00000033, #add x0, x0, x0
    0x00000033, #add x0, x0, x0
    0x0ff00213, #addi x4, x0, 255
    0x00000033, #add x0, x0, x0
    0x00000033, #add x0, x0, x0
    0x00000033, #add x0, x0, x0
    0x003212b3, #sll x5, x4, x3
    0x00000033, #add x0, x0, x0 
    0x00000033, #add x0, x0, x0


]


@cocotb.test()
async def isa_test(dut):
    """Try accessing the design."""
    clk = Clock(dut.clk, 1, "ns")
    cocotb.start_soon(clk.start())
    dut.dmemRdata.value = 0xFFAFFA
    c = True
    for i in program:
        await Timer(1, "ns")
        dut.imemRdata.value = i
    for i in range(10):
        await Timer(1,"ns")

    await Timer(10,"ns")