SIM ?= verilator
TOPLEVEL_LANG ?= verilog
WAVES = 1
VERILOG_SOURCES += $(PWD)/rtl/*.sv
EXTRA_ARGS += --trace --trace-structs --timing -j 0

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = TB

# MODULE is the basename of the Python test file
MODULE = test
all: compile sim

compile:
		riscv32-unknown-elf-gcc -nostdlib -nostartfiles -O0 -march=rv32i -mabi=ilp32 -T link.ld boot.s test.c -o code.elf
		riscv32-unknown-elf-objdump -D code.elf > code.dump
		riscv32-unknown-elf-elf2hex --bit-width 32 --input code.elf >code.mem
sim:
include $(shell cocotb-config --makefiles)/Makefile.sim


