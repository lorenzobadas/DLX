PKG_FILES := $(shell find ../src/pkg/ -name '*pkg.vhd' -type f)
T2_SRC    := $(shell find ../src/t2_shifter -type f)
T2_TB_SRC := $(shell find ../src/tb -name '*t2_shifter*.vhd' -type f)
P4_SRC    := $(shell find ../src/p4_adder -type f)
P4_TB_SRC := $(shell find ../src/tb -name '*p4_adder*.vhd' -type f)
ALU_SRC    := $(shell find ../src/alu -type f)
ALU_TB_SRC := $(shell find ../src/tb -name '*alu*.vhd' -type f)
CPU_SRC    := $(shell find ../src/ -type f)
CPU_TB_SRC := $(shell find ../src/tb -name '*cpu*.vhd' -type f)
ASM_SRC	:= $(shell find ../asm -type f)
ASM_FILENAME := $(basename $(notdir $(ASM_SRC)))

t2-shifter-tb: clean
	cp $(PKG_FILES) $(T2_SRC) $(T2_TB_SRC) .
	
	vcom $$(basename -a $(PKG_FILES) $(T2_SRC) $(T2_TB_SRC)) -autoorder -autoorderquiet

	vsim \
		-do ../scripts/tb_t2_shifter.do

p4-adder-tb: clean
	cp $(PKG_FILES) $(P4_SRC) $(P4_TB_SRC) .

	vcom $$(basename -a $(PKG_FILES) $(P4_SRC) $(P4_TB_SRC)) -autoorder -autoorderquiet

	vsim \
		-do ../scripts/tb_p4_adder.do

alu-tb: clean
	cp $(PKG_FILES) $(P4_SRC) $(T2_SRC) $(ALU_SRC) $(ALU_TB_SRC) .

	vcom $$(basename -a $(PKG_FILES) $(P4_SRC) $(T2_SRC) $(ALU_SRC) $(ALU_TB_SRC)) -autoorder -autoorderquiet

	vsim \
		-do ../scripts/tb_alu.do

cpu-tb: clean gen-bin
	cp $(PKG_FILES) $(CPU_SRC) $(CPU_TB_SRC) .

	vcom $$(basename -a $(PKG_FILES) $(CPU_SRC) $(CPU_TB_SRC)) -autoorder -autoorderquiet

	vsim \
		-do ../scripts/tb_cpu.do

gen-bin: clean
	perl ../scripts/dlxasm.pl -o $(ASM_FILENAME).bin -list $(ASM_FILENAME).list $(ASM_SRC)
	rm $(ASM_FILENAME).bin.hdr $(ASM_FILENAME).list
	cat $(ASM_FILENAME).bin | hexdump -v -e '/1 "%02X" /1 "%02X" /1 "%02X" /1 "%02X\n"' > $(ASM_FILENAME)\_dump.txt
	mv $(ASM_FILENAME)\_dump.txt ./instr_memory.mem

clean:
	rm -f ./*.vhd
	rm -rf ./work
	rm -f transcript
	rm -f vsim.wlf
	rm -f *.mem
	rm -f *.bin
	rm -f *.txt

