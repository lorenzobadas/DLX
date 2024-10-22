PKG_FILES := ../src/utils_pkg.vhd ../src/o3_pkg.vhd
T2_SRC := ../src/t2_shifter/t2_shifter_levels_1_2.vhd ../src/t2_shifter/t2_shifter_level_3.vhd ../src/t2_shifter/t2_shifter.vhd
T2_TB_SRC := ../src/tb/tb_t2_shifter.vhd
P4_SRC := ../src/p4_adder/g_p.vhd ../src/p4_adder/g_g.vhd ../src/p4_adder/g_pg.vhd ../src/p4_adder/carry_generator.vhd ../src/p4_adder/rca.vhd ../src/p4_adder/carry_select_adder.vhd ../src/p4_adder/sum_generator.vhd ../src/p4_adder/xor_layer.vhd ../src/p4_adder/p4_adder.vhd
P4_TB_SRC := ../src/tb/tb_p4_adder.vhd
BOOTHMUL_SRC := ../src/multiplier/shifter_left.vhd ../src/multiplier/mux_mul.vhd ../src/multiplier/boothmul.vhd
BOOTHMUL_TB_SRC := ../src/tb/tb_boothmul.vhd
REORDER_BUFFER_SRC := ../src/reorder_buffer/reorder_buffer.vhd
REORDER_BUFFER_TB_SRC := ../src/tb/tb_reorder_buffer.vhd
EXE_RESERVATION_STATION_SRC := ../src/exe_reservation_station/exe_reservation_station.vhd
EXE_RESERVATION_STATION_TB_SRC := ../src/tb/tb_exe_reservation_station_pkg.vhd ../src/tb/tb_exe_reservation_station.vhd
LS_RESERVATION_STATION_SRC := ../src/load_store_unit/ls_reservation_station.vhd
LS_RESERVATION_STATION_TB_SRC := ../src/tb/tb_ls_reservation_station_pkg.vhd ../src/tb/tb_ls_reservation_station.vhd
ALU_SRC := ../src/alu/comparator.vhd ../src/alu/logic_ops.vhd ../src/alu/alu.vhd
ALU_TB_SRC := ../src/tb/tb_alu.vhd

t2-shifter-tb: clean
	@for file in $(PKG_FILES) $(T2_SRC) $(T2_TB_SRC); do \
		cp $$file .; \
	done

	@for file in $(PKG_FILES) $(T2_SRC) $(T2_TB_SRC); do \
		vcom $$(basename $$file); \
	done

	vsim \
		-do ../scripts/tb_t2_shifter.do

p4-adder-tb: clean
	@for file in $(PKG_FILES) $(P4_SRC) $(P4_TB_SRC); do \
		cp $$file .; \
	done

	@for file in $(PKG_FILES) $(P4_SRC) $(P4_TB_SRC); do \
		vcom $$(basename $$file); \
	done

	vsim \
		-do ../scripts/tb_p4_adder.do

boothmul-tb: clean
	@for file in $(PKG_FILES) $(P4_SRC) $(BOOTHMUL_SRC) $(BOOTHMUL_TB_SRC); do \
		cp $$file .; \
	done

	@for file in $(PKG_FILES) $(P4_SRC) $(P4_TB_SRC) $(BOOTHMUL_SRC) $(BOOTHMUL_TB_SRC); do \
		vcom $$(basename $$file); \
	done

	vsim \
		-do ../scripts/tb_boothmul.do

reorder-buffer-tb: clean
	@for file in $(PKG_FILES) $(REORDER_BUFFER_SRC) $(REORDER_BUFFER_TB_SRC); do \
		cp $$file .; \
	done

	@for file in $(PKG_FILES) $(REORDER_BUFFER_SRC) $(REORDER_BUFFER_TB_SRC); do \
		vcom $$(basename $$file); \
	done

	vsim \
		-do ../scripts/tb_reorder_buffer.do

exe-reservation-station-tb: clean
	@for file in $(PKG_FILES) $(EXE_RESERVATION_STATION_SRC) $(EXE_RESERVATION_STATION_TB_SRC); do \
		cp $$file .; \
	done

	@for file in $(PKG_FILES) $(EXE_RESERVATION_STATION_SRC) $(EXE_RESERVATION_STATION_TB_SRC); do \
		vcom $$(basename $$file); \
	done

	vsim \
		-do ../scripts/tb_exe_reservation_station.do

ls-reservation-station-tb: clean
	@for file in $(PKG_FILES) $(LS_RESERVATION_STATION_SRC) $(LS_RESERVATION_STATION_TB_SRC); do \
		cp $$file .; \
	done

	@for file in $(PKG_FILES) $(LS_RESERVATION_STATION_SRC) $(LS_RESERVATION_STATION_TB_SRC); do \
		vcom $$(basename $$file); \
	done

	vsim \
		-do ../scripts/tb_ls_reservation_station.do

alu-tb: clean
	@for file in $(PKG_FILES) $(P4_SRC) $(ALU_SRC) $(ALU_TB_SRC); do \
		cp $$file .; \
	done

	@for file in $(PKG_FILES) $(P4_SRC) $(ALU_SRC) $(ALU_TB_SRC); do \
		vcom $$(basename $$file); \
	done

	vsim \
		-do ../scripts/tb_alu.do

clean:
	rm -f ./*.vhd
	rm -rf ./work
	rm -f transcript
	rm -f vsim.wlf
