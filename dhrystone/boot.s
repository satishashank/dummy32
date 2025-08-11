.section .text
.global _start

_start:
    li sp, 0x1000FFFC
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
