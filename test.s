.section .text
.global _start

_start:
        li x1,0xffffAAAA
        li x3, 0x41
        sw x3,0(x1)
        nop
        lw x4,0(x1)
        addi x4,x4,3
loop:   
        li x4,0xDEADC0DE
        addi x3,x3,-1
        bne x3,x0,loop
