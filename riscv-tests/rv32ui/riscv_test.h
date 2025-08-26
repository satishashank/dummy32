#ifndef _ENV_PICORV32_TEST_H
#define _ENV_PICORV32_TEST_H

#ifndef TEST_FUNC_NAME
#  define TEST_FUNC_NAME mytest
#  define TEST_FUNC_TXT "mytest"
#  define TEST_FUNC_RET mytest_ret
#endif

#define RVTEST_RV32U
#define TESTNUM x28

#define RVTEST_CODE_BEGIN              \
	.text;                             \
	.global TEST_FUNC_NAME;            \
	.global TEST_FUNC_RET;             \
	.global uart_putchar;              \
	TEST_FUNC_NAME:                    \
	li sp, 0x10003FFC;                 \
	sw ra, (sp);                       \
	lui a3, % hi(.test_name);          \
	addi a3, a3, % lo(.test_name);     \
	.prname_next : lb a0, 0(a3);       \
	beq a0, zero, .prname_done;        \
	jal uart_putchar;                  \
	addi a3, a3, 1;                    \
	jal zero, .prname_next;            \
	.prname_done : addi a0, zero, '.'; \
	jal uart_putchar;                  \
	jal uart_putchar;                  \
	lw ra, (sp);

#define RVTEST_PASS      \
	li sp, 0x10003FFC;   \
	sw ra, (sp);         \
	addi a0, zero, 'o';  \
	jal uart_putchar;    \
	addi a0, zero, 'k';  \
	jal uart_putchar;    \
	addi a0, zero, '\n'; \
	jal uart_putchar;    \
	lw ra, (sp);         \
	jal zero, TEST_FUNC_RET;

#define RVTEST_FAIL      \
	li sp, 0x10003FFC;   \
	sw ra, (sp);         \
	addi a0, zero, 'e';  \
	jal uart_putchar;    \
	addi a0, zero, 'r';  \
	jal uart_putchar;    \
	addi a0, zero, 'r';  \
	jal uart_putchar;    \
	addi a0, zero, 'o';  \
	jal uart_putchar;    \
	addi a0, zero, 'r';  \
	jal uart_putchar;    \
	addi a0, zero, '\n'; \
	jal uart_putchar;    \
	addi a0, zero, '\n'; \
	jal uart_putchar;    \
	lw ra, (sp);         \
	jal zero, TEST_FUNC_RET;

#define RVTEST_CODE_END
#define RVTEST_DATA_BEGIN             \
	.data;                            \
	.test_name :.ascii TEST_FUNC_TXT; \
	.byte 0x00;                       \
	.balign 4, 0;

#define RVTEST_DATA_END

#endif