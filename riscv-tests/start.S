.section .text
.globl _start
.globl uart_putchar

_start:
	/* zero-initialize all registers */
	addi x1, zero, 0
    addi x2, zero, 0
    addi x3, zero, 0
    addi x4, zero, 0
    addi x5, zero, 0
    addi x6, zero, 0
    addi x7, zero, 0
    addi x8, zero, 0
    addi x9, zero, 0
    addi x10, zero, 0
    addi x11, zero, 0
    addi x12, zero, 0
    addi x13, zero, 0
    addi x14, zero, 0
    addi x15, zero, 0
    addi x16, zero, 0
    addi x17, zero, 0
    addi x18, zero, 0
    addi x19, zero, 0
    addi x20, zero, 0
    addi x21, zero, 0
    addi x22, zero, 0
    addi x23, zero, 0
    addi x24, zero, 0
    addi x25, zero, 0
    addi x26, zero, 0
    addi x27, zero, 0
    addi x28, zero, 0
    addi x29, zero, 0
    addi x30, zero, 0
	addi x31, zero, 0
#	j _start

#  define TEST(n) \
	.global n; \
	addi x1, zero, 1000; \
	jal zero,n; \
	.global n ## _ret; \
	n ## _ret:
	#picorv32_timer_insn(zero, x1); \

	TEST(add)
    TEST(addi)
    TEST(xori)
    TEST(xor)
    TEST(andi)
    TEST(and)
    TEST(auipc)
    TEST(beq)
    TEST(bge)
    TEST(bgeu)
    TEST(blt)
    TEST(bltu)
    TEST(bne)
    TEST(jalr)
    TEST(jal)
    TEST(j)
    TEST(lb)
    TEST(lbu)
    TEST(lh)
    TEST(lhu)
    TEST(lui)
    TEST(lw)
    TEST(ori)
    TEST(or)
    TEST(sb)
    TEST(sh)
    TEST(slli)
    TEST(sll)
    TEST(slti)
    TEST(slt)
    TEST(srai)
    TEST(sra)
    TEST(srli)
    TEST(srl)
    TEST(sub)
    TEST(sw)
    TEST(simple)
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



# void uart_putchar(char c)
.balign 4
uart_putchar:
	la t2, 0xFFFFFFFC
    sw a0, 0(t2) # do the real work
	ret
.balign 4