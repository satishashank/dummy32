XLEN ?= 32
src_dir := .

RISCV_PREFIX ?= riscv$(XLEN)-unknown-elf-
RISCV_GCC ?= $(RISCV_PREFIX)gcc
TESTS_PATH ?= $(src_dir)/rv32ui
TESTS = add addi xori xor
TEST_OBJS := $(addprefix $(TESTS_PATH)/, $(addsuffix .o, $(TESTS)))
all: rv32i_test.elf test.dump
rv32i_test.elf:start.S link.ld
	$(RISCV_GCC) -c -O0 -march=rv32i -mabi=ilp32  start.S -o start.o
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/add.o -DTEST_FUNC_NAME=add \
		-DTEST_FUNC_TXT='"add"' -DTEST_FUNC_RET=add_ret $(TESTS_PATH)/add.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/addi.o -DTEST_FUNC_NAME=addi \
		-DTEST_FUNC_TXT='"addi"' -DTEST_FUNC_RET=addi_ret $(TESTS_PATH)/addi.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/andi.o -DTEST_FUNC_NAME=andi \
		-DTEST_FUNC_TXT='"andi"' -DTEST_FUNC_RET=andi_ret $(TESTS_PATH)/andi.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/and.o -DTEST_FUNC_NAME=and \
		-DTEST_FUNC_TXT='"and"' -DTEST_FUNC_RET=and_ret $(TESTS_PATH)/and.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/xori.o -DTEST_FUNC_NAME=xori \
		-DTEST_FUNC_TXT='"xori"' -DTEST_FUNC_RET=xori_ret $(TESTS_PATH)/xori.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/xor.o -DTEST_FUNC_NAME=xor \
		-DTEST_FUNC_TXT='"xor"' -DTEST_FUNC_RET=xor_ret $(TESTS_PATH)/xor.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/auipc.o -DTEST_FUNC_NAME=auipc \
		-DTEST_FUNC_TXT='"auipc"' -DTEST_FUNC_RET=auipc_ret $(TESTS_PATH)/auipc.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/beq.o -DTEST_FUNC_NAME=beq \
		-DTEST_FUNC_TXT='"beq"' -DTEST_FUNC_RET=beq_ret $(TESTS_PATH)/beq.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/bge.o -DTEST_FUNC_NAME=bge \
		-DTEST_FUNC_TXT='"bge"' -DTEST_FUNC_RET=bge_ret $(TESTS_PATH)/bge.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/bgeu.o -DTEST_FUNC_NAME=bgeu \
		-DTEST_FUNC_TXT='"bgeu"' -DTEST_FUNC_RET=bgeu_ret $(TESTS_PATH)/bgeu.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/blt.o -DTEST_FUNC_NAME=blt \
		-DTEST_FUNC_TXT='"blt"' -DTEST_FUNC_RET=blt_ret $(TESTS_PATH)/blt.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/bltu.o -DTEST_FUNC_NAME=bltu \
		-DTEST_FUNC_TXT='"bltu"' -DTEST_FUNC_RET=bltu_ret $(TESTS_PATH)/bltu.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/bne.o -DTEST_FUNC_NAME=bne \
		-DTEST_FUNC_TXT='"bne"' -DTEST_FUNC_RET=bne_ret $(TESTS_PATH)/bne.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/jalr.o -DTEST_FUNC_NAME=jalr \
		-DTEST_FUNC_TXT='"jalr"' -DTEST_FUNC_RET=jalr_ret $(TESTS_PATH)/jalr.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/jal.o -DTEST_FUNC_NAME=jal \
		-DTEST_FUNC_TXT='"jal"' -DTEST_FUNC_RET=jal_ret $(TESTS_PATH)/jal.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/j.o -DTEST_FUNC_NAME=j \
		-DTEST_FUNC_TXT='"j"' -DTEST_FUNC_RET=j_ret $(TESTS_PATH)/j.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/lb.o -DTEST_FUNC_NAME=lb \
		-DTEST_FUNC_TXT='"lb"' -DTEST_FUNC_RET=lb_ret $(TESTS_PATH)/lb.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/lbu.o -DTEST_FUNC_NAME=lbu \
		-DTEST_FUNC_TXT='"lbu"' -DTEST_FUNC_RET=lbu_ret $(TESTS_PATH)/lbu.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/lh.o -DTEST_FUNC_NAME=lh \
		-DTEST_FUNC_TXT='"lh"' -DTEST_FUNC_RET=lh_ret $(TESTS_PATH)/lh.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/lhu.o -DTEST_FUNC_NAME=lhu \
		-DTEST_FUNC_TXT='"lhu"' -DTEST_FUNC_RET=lhu_ret $(TESTS_PATH)/lhu.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/lui.o -DTEST_FUNC_NAME=lui \
		-DTEST_FUNC_TXT='"lui"' -DTEST_FUNC_RET=lui_ret $(TESTS_PATH)/lui.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/lw.o -DTEST_FUNC_NAME=lw \
		-DTEST_FUNC_TXT='"lw"' -DTEST_FUNC_RET=lw_ret $(TESTS_PATH)/lw.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/ori.o -DTEST_FUNC_NAME=ori \
		-DTEST_FUNC_TXT='"ori"' -DTEST_FUNC_RET=ori_ret $(TESTS_PATH)/ori.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/or.o -DTEST_FUNC_NAME=or \
		-DTEST_FUNC_TXT='"or"' -DTEST_FUNC_RET=or_ret $(TESTS_PATH)/or.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/sb.o -DTEST_FUNC_NAME=sb \
		-DTEST_FUNC_TXT='"sb"' -DTEST_FUNC_RET=sb_ret $(TESTS_PATH)/sb.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/sh.o -DTEST_FUNC_NAME=sh \
		-DTEST_FUNC_TXT='"sh"' -DTEST_FUNC_RET=sh_ret $(TESTS_PATH)/sh.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/simple.o -DTEST_FUNC_NAME=simple \
		-DTEST_FUNC_TXT='"simple"' -DTEST_FUNC_RET=simple_ret $(TESTS_PATH)/simple.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/slli.o -DTEST_FUNC_NAME=slli \
		-DTEST_FUNC_TXT='"slli"' -DTEST_FUNC_RET=slli_ret $(TESTS_PATH)/slli.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/sll.o -DTEST_FUNC_NAME=sll \
		-DTEST_FUNC_TXT='"sll"' -DTEST_FUNC_RET=sll_ret $(TESTS_PATH)/sll.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/slti.o -DTEST_FUNC_NAME=slti \
		-DTEST_FUNC_TXT='"slti"' -DTEST_FUNC_RET=slti_ret $(TESTS_PATH)/slti.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/slt.o -DTEST_FUNC_NAME=slt \
		-DTEST_FUNC_TXT='"slt"' -DTEST_FUNC_RET=slt_ret $(TESTS_PATH)/slt.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/srai.o -DTEST_FUNC_NAME=srai \
		-DTEST_FUNC_TXT='"srai"' -DTEST_FUNC_RET=srai_ret $(TESTS_PATH)/srai.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/sra.o -DTEST_FUNC_NAME=sra \
		-DTEST_FUNC_TXT='"sra"' -DTEST_FUNC_RET=sra_ret $(TESTS_PATH)/sra.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/srli.o -DTEST_FUNC_NAME=srli \
		-DTEST_FUNC_TXT='"srli"' -DTEST_FUNC_RET=srli_ret $(TESTS_PATH)/srli.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/srl.o -DTEST_FUNC_NAME=srl \
		-DTEST_FUNC_TXT='"srl"' -DTEST_FUNC_RET=srl_ret $(TESTS_PATH)/srl.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/sub.o -DTEST_FUNC_NAME=sub \
		-DTEST_FUNC_TXT='"sub"' -DTEST_FUNC_RET=sub_ret $(TESTS_PATH)/sub.S
	$(RISCV_GCC) -c -march=rv32i -mabi=ilp32 -o $(TESTS_PATH)/sw.o -DTEST_FUNC_NAME=sw \
		-DTEST_FUNC_TXT='"sw"' -DTEST_FUNC_RET=sw_ret $(TESTS_PATH)/sw.S
	$(RISCV_GCC) -march=rv32i -mabi=ilp32 \
    -Os -ffreestanding -nostdlib -o ../rv32i_test.elf \
    -Wl,-Bstatic,-T,link.ld \
    start.o $(TESTS_PATH)/*.o


test.dump: rv32i_test.elf
		riscv32-unknown-elf-objdump -D ../rv32i_test.elf > ../rv32i_test.dump
	
clean:
	rm -rf $(TESTS_PATH)/*.o $(src_dir)/start.o ../rv32i_test.elf ../test.dump