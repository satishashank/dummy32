SIM ?= verilator
TOPLEVEL_LANG ?= verilog
WAVES = 1
VERILOG_SOURCES += $(PWD)/rtl/*.sv
EXTRA_ARGS += --trace --trace-structs --trace-fst --timing -j 8
TOPLEVEL = TB
MODULE = test

XLEN ?= 32
src_dir := ./tests

RISCV_PREFIX ?= riscv$(XLEN)-unknown-elf-
RISCV_GCC ?= $(RISCV_PREFIX)gcc
TESTS_PATH ?= $(src_dir)/rv32ui
all: code.mem data.mem sim

rv32i_test.elf:link.ld boot.s test.c
		riscv32-unknown-elf-gcc -nostdlib -nostartfiles -O0 -march=rv32i -mabi=ilp32 -T link.ld boot.s test.c -o rv32i_test.elf
code.bin: rv32i_test.elf
		riscv32-unknown-elf-objcopy -O binary --only-section=.text rv32i_test.elf code.bin
data.bin: rv32i_test.elf
		riscv32-unknown-elf-objcopy -O binary --only-section=.data rv32i_test.elf data.bin
code.mem: code.bin
		hexdump -v -e '1/4 "%08x\n"' code.bin > code.mem
data.mem: data.bin
		hexdump -v -e '1/1 "%02x\n"' data.bin > data.mem

sim: code.mem data.mem
include $(shell cocotb-config --makefiles)/Makefile.sim

clean_build:
	rm -rf code.mem data.mem code.bin data.bin rv32i_test.elf test.dump

