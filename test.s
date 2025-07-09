.section .text
.global _start

_start:
    addi x1, x0, -4          
    addi x2, x1, -10          
    sub x3,x0,x
    
ad: 
    addi x7, x1, 7
    addi x8, x1, 7
func:
    addi x9, x1, 7
nun:
    nop
    nop
    nop
    nop
