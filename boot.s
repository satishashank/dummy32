.section .text
.global _start

_start:
    li sp, 0x200
    call main
halt:
    j halt