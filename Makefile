SIM ?= verilator
TOPLEVEL_LANG ?= verilog
WAVES = 1
VERILOG_SOURCES += $(PWD)/rtl/*.sv
VERILOG_SOURCES += $(PWD)/rtl/core/*.sv
EXTRA_ARGS += --trace --trace-structs --trace-fst --timing -j 8
TOPLEVEL = TB
MODULE = test

XLEN ?= 32
src_dir := ./tests

RISCV_PREFIX ?= riscv$(XLEN)-unknown-elf-
RISCV_GCC ?= $(RISCV_PREFIX)gcc
TESTS_PATH ?= $(src_dir)/rv32ui
all: code.mem data.mem sim

rv32i_test.elf:link.ld boot.s test.c test.s
		riscv32-unknown-elf-gcc -nostdlib -nostartfiles -O3 -march=rv32i_zicsr -mabi=ilp32 -T link.ld test.s -o rv32i_test.elf
rv32i_test.dump: rv32i_test.elf
		riscv32-unknown-elf-objdump -D rv32i_test.elf > rv32i_test.dump
code.bin:rv32i_test.elf
		riscv32-unknown-elf-objcopy -O binary --only-section=.text rv32i_test.elf code.bin
sdata.bin:rv32i_test.elf
		riscv32-unknown-elf-objcopy -O binary --only-section=.sdata rv32i_test.elf sdata.bin
data.bin: sdata.bin rv32i_test.elf
		riscv32-unknown-elf-objcopy -O binary --only-section=.data rv32i_test.elf data1.bin
		cat data1.bin sdata.bin > data.bin
code.mem: code.bin rv32i_test.dump
		hexdump -v -e '1/4 "%08x\n"' code.bin > code.mem
data.mem: data.bin
		hexdump -v -e '1/1 "%02x\n"' data.bin > data.mem

sim: code.mem data.mem
include $(shell cocotb-config --makefiles)/Makefile.sim

clean_build:
	rm -rf *.mem *.bin *.elf *dump* 

