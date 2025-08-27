.section .text
.global _start

_start:
    nop
    nop
    nop
    li sp, 0x10003FFC
    call main
HALT:
    li t0,0xDEADC0DE
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j HALT
