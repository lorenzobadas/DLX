.SUFFIXES:
.PHONY: t2-shifter-tb p4-adder-tb alu-tb cpu-tb clean clean_sim clean_syn clean_pnr clean_all

GIT_ROOT   := $(shell git rev-parse --show-toplevel)

# Other directory paths
SRC_DIR     := $(GIT_ROOT)/src
TB_DIR      := $(GIT_ROOT)/src/tb
ASM_DIR     := $(GIT_ROOT)/asm
SCRIPTS_DIR := $(GIT_ROOT)/scripts
SIM_DIR     := $(GIT_ROOT)/sim
SYN_DIR	    := $(GIT_ROOT)/syn
PNR_DIR     := $(GIT_ROOT)/pnr

# Find all relevant source files
PKG_FILES  := $(shell find $(SRC_DIR)/pkg/ -name '*pkg.vhd' -type f)
T2_SRC     := $(shell find $(SRC_DIR)/t2_shifter -type f)
T2_TB_SRC  := $(shell find $(TB_DIR) -name '*t2_shifter*.vhd' -type f)
P4_SRC     := $(shell find $(SRC_DIR)/p4_adder -type f)
P4_TB_SRC  := $(shell find $(TB_DIR) -name '*p4_adder*.vhd' -type f)
ALU_SRC    := $(shell find $(SRC_DIR)/alu -type f)
ALU_TB_SRC := $(shell find $(TB_DIR) -name '*alu*.vhd' -type f)
CPU_SRC    := $(shell find $(SRC_DIR) -type f)
CPU_TB_SRC := $(shell find $(TB_DIR) -name '*cpu*.vhd' -type f)

# Default assembly file if none specified
ASM_FILE     ?= $(shell find $(ASM_DIR) -type f -name 'add*.asm' | head -1)
ASM_FILENAME := $(basename $(notdir $(ASM_FILE)))

$(SRC_DIR)/pkg/instructions_pkg.vhd: 
	python3 $(SCRIPTS_DIR)/instructions_pkg_generator.py $(SCRIPTS_DIR)/instructions.json > $@

################################################
########### Simulation Targets #################
################################################

t2-shifter-tb: clean_sim | $(SIM_DIR)
	cp $(PKG_FILES) $(T2_SRC) $(T2_TB_SRC) $(SIM_DIR)
	
	cd $(SIM_DIR) && \
	vcom \
	$$(find $(SIM_DIR) -name '*pkg.vhd' -type f) \
	$$(find $(SIM_DIR) -name '*.vhd' -type f) \
	-autoorder \
	-autoorderquiet

	cd $(SIM_DIR) && \
	vsim \
		-do $(SCRIPTS_DIR)/tb_t2_shifter.do

p4-adder-tb: clean_sim | $(SIM_DIR)
	cp $(PKG_FILES) $(P4_SRC) $(P4_TB_SRC) $(SIM_DIR)

	cd $(SIM_DIR) && \
	vcom \
	$$(find $(SIM_DIR) -name '*pkg.vhd' -type f) \
	$$(find $(SIM_DIR) -name '*.vhd' -type f) \
	-autoorder \
	-autoorderquiet

	cd $(SIM_DIR) && \
	vsim \
		-do $(SCRIPTS_DIR)/tb_p4_adder.do

alu-tb: clean_sim | $(SIM_DIR)
	cp $(PKG_FILES) $(P4_SRC) $(T2_SRC) $(ALU_SRC) $(ALU_TB_SRC) $(SIM_DIR)

	cd $(SIM_DIR) && \
	vcom \
	$$(find $(SIM_DIR) -name '*pkg.vhd' -type f) \
	$$(find $(SIM_DIR) -name '*.vhd' -type f) \
	-autoorder \
	-autoorderquiet

	cd $(SIM_DIR) && \
	vsim \
		-do $(SCRIPTS_DIR)/tb_alu.do

$(SIM_DIR)/instr_memory.mem: clean_sim | $(SIM_DIR)
	perl $(SCRIPTS_DIR)/dlxasm.pl -o $(SIM_DIR)/$(ASM_FILENAME).bin -list $(SIM_DIR)/$(ASM_FILENAME).list $(ASM_FILE)
	rm -f $(SIM_DIR)/$(ASM_FILENAME).bin.hdr $(SIM_DIR)/$(ASM_FILENAME).list
	cat $(SIM_DIR)/$(ASM_FILENAME).bin | hexdump -v -e '/1 "%02X" /1 "%02X" /1 "%02X" /1 "%02X\n"' > $(SIM_DIR)/$(ASM_FILENAME)_dump.txt
	rm -f $(SIM_DIR)/$(ASM_FILENAME).bin
	mv $(SIM_DIR)/$(ASM_FILENAME)_dump.txt $@

cpu-tb: clean_sim $(SIM_DIR)/instr_memory.mem | $(SIM_DIR)
	cp $(PKG_FILES) $(CPU_SRC) $(CPU_TB_SRC) $(SIM_DIR)

	cd $(SIM_DIR) && \
	vcom \
	 	$(SIM_DIR)/instructions_pkg.vhd \
		$(SIM_DIR)/alu_instr_pkg.vhd    \
		$(SIM_DIR)/ctrl_signals_pkg.vhd \
		$(SIM_DIR)/utils_pkg.vhd        \
		$(SIM_DIR)/mem_pkg.vhd          \
	 	$$(find $(SIM_DIR) -name '*.vhd' -type f) \
		-autoorder \
		-autoorderquiet

	cd $(SIM_DIR) && \
	vsim \
		-do $(SCRIPTS_DIR)/tb_cpu.do

post-syn-cpu-tb: clean_sim $(SIM_DIR)/instr_memory.mem | $(SIM_DIR) $(SYN_DIR)/results/cpu.v
	cp $(SYN_DIR)/results/cpu.v $(SIM_DIR)
	cp $(PKG_FILES) $(CPU_SRC) $(CPU_TB_SRC) $(SIM_DIR)
	cp $(SRC_DIR)/tb/tb_cpu.v $(SIM_DIR)

	rm -f $(SIM_DIR)/cpu.vhd
	rm -f $(SIM_DIR)/tb_cpu.vhd

	cd $(SIM_DIR) && \
	vcom \
	 	$(SIM_DIR)/instructions_pkg.vhd \
		$(SIM_DIR)/alu_instr_pkg.vhd    \
		$(SIM_DIR)/ctrl_signals_pkg.vhd \
		$(SIM_DIR)/utils_pkg.vhd        \
		$(SIM_DIR)/mem_pkg.vhd          \
	 	$$(find $(SIM_DIR) -name '*.vhd' -type f) \
		-autoorder \
		-autoorderquiet \
		-mixedsvvh


	cd $(SIM_DIR) && \
	vlog \
	  $(SIM_DIR)/tb_cpu.v \
		$(SIM_DIR)/cpu.v \
		-mixedsvvh

	cd $(SIM_DIR) && \
	vsim \
		-do $(SCRIPTS_DIR)/tb_cpu_postsyn.do

$(SIM_DIR):
	mkdir -p $(SIM_DIR)

####################################################
################ Synthesis Targets #################
####################################################

synthesis: clean_syn $(SYN_DIR)/results/cpu.v

$(SYN_DIR)/results/cpu.v: | $(SYN_DIR)

	cp .synopsys_dc.setup $(SYN_DIR)

	cd $(SYN_DIR) && \
	dc_shell-xg-t \
		-x "set rootdir {$(GIT_ROOT)}; set outdir {$(SYN_DIR)/results}; source $(SCRIPTS_DIR)/synthesis.tcl" \
		| tee $(SYN_DIR)/dc_shell.log

$(SYN_DIR):
	mkdir -p $(SYN_DIR)

##############################################
################ PnR Targets #################
##############################################

pnr: clean_pnr $(PNR_DIR)/cpu.v

pnr_gui: $(PNR_DIR)/cpu_pnr.enc
# execute inside the innovus terminal "source $(PNR_DIR)/cpu_pnr.enc"

$(PNR_DIR)/cpu.v $(PNR_DIR)/cpu_pnr.enc: $(SYN_DIR)/results/cpu.v | $(PNR_DIR) $(PNR_DIR)/netlist
	cp $(SYN_DIR)/results/cpu.v $(SYN_DIR)/results/cpu.sdc $(PNR_DIR)/netlist
	cp design.globals place_and_route.tcl mmm_design.tcl $(PNR_DIR)

	cd $(PNR_DIR) && \
	innovus -no_gui -batch -file place_and_route.tcl

$(PNR_DIR):
	mkdir -p $(PNR_DIR)

$(PNR_DIR)/netlist:
	mkdir -p $(PNR_DIR)/netlist
	

################################################
################ Clean Targets #################
################################################

clean_sim:
	rm -rf  $(SIM_DIR)/*

clean_syn:
	rm -rf  $(SYN_DIR)/*

clean_pnr:
	rm -rf  $(PNR_DIR)/*
	
clean: clean_sim clean_syn clean_pnr