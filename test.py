# test_my_design.py (simple)

import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

@cocotb.test()
async def isa_test(dut):
    """Try accessing the design."""
    clk = Clock(dut.clk, 1, "ns")
    cocotb.start_soon(clk.start())
    writeData = []
    writeAddr = []
    writePc = []
    for i in range(1):
        dut.rst.value = 1
        await Timer(1, "ns")
    dut.rst.value = 0
    for i in range(20000):
        await Timer(1, "ns")
        if (dut.uut.regF.writeEn.value == 1):
            try:
                writeData.append(dut.uut.regF.writeData.value)
                writeAddr.append(dut.uut.regF.writeAddr.value)
                writePc.append(dut.uut.pcWplus4.value-4)
            except:
                pass
        if (dut.uut.regF.writeData.value == 0xDEADC0DE):
            break 
    # if log)
    # for pc,addr,data in zip(writePc,writeAddr,writeData):
    #         msg = f"{hex(pc)},{hex(addr)},{hex(data)}"
    #         cocotb.log.info(msg)
    

