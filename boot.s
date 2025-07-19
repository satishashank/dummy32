.section .text
.global _start

_start:
    li sp, 0x10001000
    call main
halt:
    nop
    li x1,0xA5FFA5FF
    j halt
