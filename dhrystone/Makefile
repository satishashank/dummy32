DHRY-LFLAGS =

DHRY-CFLAGS := -O1 -DNOENUM -Wno-implicit
DHRY-CFLAGS += -fno-builtin-printf -fno-common -falign-functions=4 -nostartfiles 
GCC-FLAGS = -march=rv32i_zicsr -mabi=ilp32

#Uncomment below for FPGA run, default DHRY_ITERS is 2000 for RTL
#DHRY-CFLAGS += -DDHRY_ITERS=20000000

SRC = boot.s dhry_1.c dhry_2.c strcmp.S malloc.c  div.c
HDR = dhry.h
RISCV-GCC = riscv32-unknown-elf-gcc

override CFLAGS += $(DHRY-CFLAGS) $(XCFLAGS) -Xlinker --defsym=__stack_size=0x800 -Xlinker --defsym=__heap_size=0x1000
rv32i_test.elf: $(SRC) $(HDR) link.ld
	$(RISCV-GCC) $(GCC-FLAGS) $(CFLAGS) $(SRC) -T link.ld -o ../rv32i_test.elf
	 riscv32-unknown-elf-objdump -D ../rv32i_test.elf > ../rv32i_test.dump
clean:
	rm -f *.i *.o 

