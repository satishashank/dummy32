.section .text
.global _start

_start:
    li   t0, 0          # sum = 0   (use t0 for sum)
    li   t1, 0          # i = 0     (use t1 for i)
    li   t2, 3          # upper bound (3)

loop:
    bge  t1, t2, halt    # if (i >= 3) exit loop

    add  t0, t0, t1     # sum = sum + i
    addi t1, t1, 1      # i++

    j    loop           # repeat
halt:   
        li x4,0xDEADC0DE
        addi x3,x3,-1
        bne x3,x0,halt
