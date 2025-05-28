PKG_FILES := $(shell find ../src -maxdepth 1 -name '*pkg.vhd' -type f)
T2_SRC    := $(shell find ../src/t2_shifter -type f)
T2_TB_SRC := $(shell find ../src/tb -name '*t2_shifter*.vhd' -type f)
P4_SRC    := $(shell find ../src/p4_adder -type f)
P4_TB_SRC := $(shell find ../src/tb -name '*p4_adder*.vhd' -type f)
BOOTHMUL_SRC    := $(shell find ../src/multiplier -type f)
BOOTHMUL_TB_SRC := $(shell find ../src/tb -name '*boothmul*.vhd' -type f)
REORDER_BUFFER_SRC    := $(shell find ../src/reorder_buffer -type f)
REORDER_BUFFER_TB_SRC := $(shell find ../src/tb -name '*reorder_buffer*.vhd' -type f)
EXE_RESERVATION_STATION_SRC    := $(shell find ../src/exe_reservation_station -type f)
EXE_RESERVATION_STATION_TB_SRC := $(shell find ../src/tb -name '*exe_reservation_station*.vhd' -type f)
LS_RESERVATION_STATION_SRC    := $(shell find ../src/load_store_unit -type f)
LS_RESERVATION_STATION_TB_SRC := $(shell find ../src/tb -name '*ls_reservation_station*.vhd' -type f)
ALU_SRC    := $(shell find ../src/alu -type f)
ALU_TB_SRC := $(shell find ../src/tb -name '*alu*.vhd' -type f)

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

boothmul-tb: clean
	cp $(PKG_FILES) $(P4_SRC) $(BOOTHMUL_SRC) $(BOOTHMUL_TB_SRC) .

	vcom $$(basename -a $(PKG_FILES) $(P4_SRC) $(BOOTHMUL_SRC) $(BOOTHMUL_TB_SRC)) -autoorder -autoorderquiet

	vsim \
		-do ../scripts/tb_boothmul.do

boothmul-pipelined-tb: clean
	cp $(PKG_FILES) $(P4_SRC) $(BOOTHMUL_SRC) $(BOOTHMUL_TB_SRC) .

	vcom $$(basename -a $(PKG_FILES) $(P4_SRC) $(BOOTHMUL_SRC) $(BOOTHMUL_TB_SRC)) -autoorder -autoorderquiet

	vsim \
		-do ../scripts/tb_boothmul_pipelined.do

boothmul-ctrl-tb: clean
	cp $(PKG_FILES) $(P4_SRC) $(BOOTHMUL_SRC) $(BOOTHMUL_TB_SRC) .

	vcom $$(basename -a $(PKG_FILES) $(P4_SRC) $(BOOTHMUL_SRC) $(BOOTHMUL_TB_SRC)) -autoorder -autoorderquiet

	vsim \
		-do ../scripts/tb_boothmul_ctrl.do

boothmul-wrapper-tb: clean
	cp $(PKG_FILES) $(P4_SRC) $(BOOTHMUL_SRC) $(BOOTHMUL_TB_SRC) .

	vcom $$(basename -a $(PKG_FILES) $(P4_SRC) $(BOOTHMUL_SRC) $(BOOTHMUL_TB_SRC)) -autoorder -autoorderquiet

	vsim \
		-do ../scripts/tb_boothmul_wrapper.do

reorder-buffer-tb: clean
	cp $(PKG_FILES) $(REORDER_BUFFER_SRC) $(REORDER_BUFFER_TB_SRC) .

	vcom $$(basename -a $(PKG_FILES) $(REORDER_BUFFER_SRC) $(REORDER_BUFFER_TB_SRC)) -autoorder -autoorderquiet

	vsim \
		-do ../scripts/tb_reorder_buffer.do

exe-reservation-station-tb: clean
	cp $(PKG_FILES) $(EXE_RESERVATION_STATION_SRC) $(EXE_RESERVATION_STATION_TB_SRC) .

	vcom $$(basename -a $(PKG_FILES) $(EXE_RESERVATION_STATION_SRC) $(EXE_RESERVATION_STATION_TB_SRC)) -autoorder -autoorderquiet

	vsim \
		-do ../scripts/tb_exe_reservation_station.do

ls-reservation-station-tb: clean
	cp $(PKG_FILES) $(LS_RESERVATION_STATION_SRC) $(LS_RESERVATION_STATION_TB_SRC) .

	vcom $$(basename -a $(PKG_FILES) $(LS_RESERVATION_STATION_SRC) $(LS_RESERVATION_STATION_TB_SRC)) -autoorder -autoorderquiet

	vsim \
		-do ../scripts/tb_ls_reservation_station.do

alu-tb: clean
	cp $(PKG_FILES) $(P4_SRC) $(ALU_SRC) $(ALU_TB_SRC) .

	vcom $$(basename -a $(PKG_FILES) $(P4_SRC) $(ALU_SRC) $(ALU_TB_SRC)) -autoorder -autoorderquiet

	vsim \
		-do ../scripts/tb_alu.do

clean:
	rm -f ./*.vhd
	rm -rf ./work
	rm -f transcript
	rm -f vsim.wlf
