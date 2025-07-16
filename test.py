# test_my_design.py (simple)

import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock

program = [
    0x00400093,  # addi x1, x0, 4          ; x1 = 4
    0x0ff00113,  # addi x2, x0, 255        ; x2 = 255

    0x002081b3,  # add x3, x1, x2          ; x3 = x1 + x2 = 259
    0x40118233,  # sub x4, x3, x1          ; x4 = x3 - x1 = 255
    0x00120293,  # addi x5, x4, 1          ; x5 = x4 + 1 = 256

    0x0021f333,  # and x6, x3, x2          ; x6 = x3 & x2
    0x0021e3b3,  # or x7, x3, x2           ; x7 = x3 | x2
    0x0021c433,  # xor x8, x3, x2          ; x8 = x3 ^ x2

    0x00f1f493,  # andi x9, x3, 15         ; x9 = x3 & 0xF
    0x0f01e513,  # ori x10, x3, 0xF0       ; x10 = x3 | 0xF0
    0x0ff1c593,  # xori x11, x3, 0xFF      ; x11 = x3 ^ 0xFF

    0x00129633,  # sll x12, x5, x1         ; x12 = x5 << x1 = 4096
    0x0012d6b3,  # srl x13, x5, x1         ; x13 = x5 >> x1 = 16
    0x4012d733,  # sra x14, x5, x1         ; x14 = x5 >> x1 = 16 (arith)

    0x00329793,  # slli x15, x5, 3         ; x15 = x5 << 3 = 2048
    0x0032d813,  # srli x16, x5, 3         ; x16 = x5 >> 3 = 32
    0x4032d893,  # srai x17, x5, 3         ; x17 = x5 >> 3 = 32 (arith)
    0x0fe0096f,  #jal x18, 254
    0x0050a993,  # slti x19, x1, 5         ; x19 = (x1 < 5) = 1
    0x00313a33,  # sltu x20, x2, x3        ; x20 = (x2 < x3) = 1
    0x00a0ba93,  # sltiu x21, x1, 10       ; x21 = (x1 < 10) = 1

    0x0032a423,  # sw x3, 8(x5)            ; MEM[x5 + 8] = x3
]


@cocotb.test()
async def isa_test(dut):
    """Try accessing the design."""
    clk = Clock(dut.clk, 1, "ns")
    cocotb.start_soon(clk.start())
    writeData = []
    writeAddr = []
    for i in range(1):
        dut.rst.value = 1
        await Timer(1, "ns")
    dut.rst.value = 0
    for i in range(200):
        await Timer(1, "ns")
        if (dut.uut.regF.writeEn.value == 1):
            try:
                writeData.append(dut.uut.regF.writeData.value)
                writeAddr.append(dut.uut.regF.writeAddr.value)
            except:
                pass
    for addr,data in zip(writeAddr,writeData):
        try:
            msg = f"{hex(addr)},{hex(data)}"
            cocotb.log.info(msg)
        except:pass
    
    await Timer(5,"ns")