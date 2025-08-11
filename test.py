# test_my_design.py (simple)

import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

@cocotb.test()
async def isa_test(dut):
    """Try accessing the design."""
    clk = Clock(dut.clk, 1, "ns")
    dut.usePredictor.value = 1;
    cocotb.start_soon(clk.start())
    writeData = []
    writeAddr = []
    writePc = []
    for i in range(1):
        dut.rst.value = 1
        await Timer(1, "ns")
    dut.rst.value = 0
    memWriteAddr = []
    while(True):
        await Timer(1, "ns")
        if (dut.uut.decode.regF.writeEn.value == 1):
            try:
                writeData.append(dut.uut.decode.regF.writeData.value)
                writeAddr.append(dut.uut.decode.regF.writeAddr.value)
                writePc.append(dut.uut.decode.pcPlus4.value-4)
            except:
                pass

        goodAddr = not((dut.dmemAddr.value == 0xFFFFFFFC) or (dut.dmemAddr.value == 0x0))
        load = bool(dut.dmemWen.value)
        store = dut.uut.M_regSrc.value == 1;


        if (goodAddr&(load or store)):
            memWriteAddr.append((hex(dut.dmemAddr.value),hex(dut.uut.M_pcPlus4.value-4),hex(dut.dmemWdata.value),hex(dut.dmemRdata.value),load))
        if (dut.uut.decode.regF.writeData.value == 0xDEADC0DE)|(dut.dmemWdata.value == 0x1000ef):
            break 
    # for pc,addr,data in zip(writePc,writeAddr,writeData):
    #         msg = f"{hex(pc)},{hex(addr)},{hex(data)}"
    #         cocotb.log.info(msg)
    # print("loadstore Addr,pc,dmemWdata,dmemRdata,store?:\n")
    # for i in memWriteAddr:
    #     print(i)