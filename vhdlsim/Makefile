SHELL=/bin/bash
.PHONY: all

t2-shifter-tb: clean
	cp ../src/utils_pkg.vhd .
	cp ../src/t2_shifter_levels_1_2.vhd .
	cp ../src/t2_shifter_level_3.vhd .
	cp ../src/t2_shifter.vhd .
	cp ../tb/tb_t2_shifter.vhd .

	vcom utils_pkg.vhd
	vcom t2_shifter_levels_1_2.vhd
	vcom t2_shifter_level_3.vhd
	vcom t2_shifter.vhd
	vcom tb_t2_shifter.vhd

	vsim \
		-do ../scripts/tb_t2_shifter.do

p4-adder-tb: clean
	cp ../src/g_p.vhd .
	cp ../src/g_g.vhd .
	cp ../src/g_pg.vhd .
	cp ../src/utils_pkg.vhd .
	cp ../src/carry_generator.vhd .
	cp ../src/rca.vhd .
	cp ../src/carry_select_adder.vhd .
	cp ../src/sum_generator.vhd .
	cp ../src/xor_layer.vhd .
	cp ../src/p4_adder.vhd .
	cp ../tb/tb_p4_adder.vhd .

	vcom g_p.vhd
	vcom g_g.vhd
	vcom g_pg.vhd
	vcom utils_pkg.vhd
	vcom carry_generator.vhd
	vcom rca.vhd
	vcom carry_select_adder.vhd
	vcom sum_generator.vhd
	vcom xor_layer.vhd
	vcom p4_adder.vhd
	vcom tb_p4_adder.vhd

	vsim \
		-do ../scripts/tb_p4_adder.do

boothmul-tb: clean
	cp ../src/g_p.vhd .
	cp ../src/g_g.vhd .
	cp ../src/g_pg.vhd .
	cp ../src/utils_pkg.vhd .
	cp ../src/carry_generator.vhd .
	cp ../src/rca.vhd .
	cp ../src/carry_select_adder.vhd .
	cp ../src/sum_generator.vhd .
	cp ../src/xor_layer.vhd .
	cp ../src/p4_adder.vhd .
	cp ../src/shifter_left.vhd .
	cp ../src/mux_mul.vhd .
	cp ../src/boothmul.vhd .
	cp ../tb/tb_boothmul.vhd .

	vcom g_p.vhd
	vcom g_g.vhd
	vcom g_pg.vhd
	vcom utils_pkg.vhd
	vcom carry_generator.vhd
	vcom rca.vhd
	vcom carry_select_adder.vhd
	vcom sum_generator.vhd
	vcom xor_layer.vhd
	vcom p4_adder.vhd
	vcom shifter_left.vhd
	vcom mux_mul.vhd
	vcom boothmul.vhd
	vcom tb_boothmul.vhd

	vsim \
		-do ../scripts/tb_boothmul.do

reorder-buffer-tb: clean
	cp ../src/utils_pkg.vhd .
	cp ../src/o3_pkg.vhd .
	cp ../src/reorder_buffer.vhd .
	cp ../tb/tb_reorder_buffer.vhd .

	vcom utils_pkg.vhd
	vcom o3_pkg.vhd
	vcom reorder_buffer.vhd
	vcom tb_reorder_buffer.vhd

	vsim \
		-do ../scripts/tb_reorder_buffer.do

exe-reservation-station-tb: clean
	cp ../src/utils_pkg.vhd .
	cp ../src/o3_pkg.vhd .
	cp ../src/exe_reservation_station.vhd .
	cp ../tb/tb_exe_reservation_station.vhd .

	vcom utils_pkg.vhd
	vcom o3_pkg.vhd
	vcom exe_reservation_station.vhd
	vcom tb_exe_reservation_station.vhd

	vsim \
		-do ../scripts/tb_exe_reservation_station.do

ls-reservation-station-tb: clean
	cp ../src/utils_pkg.vhd .
	cp ../src/o3_pkg.vhd .
	cp ../src/tb_ls_reservation_station_pkg.vhd .
	cp ../src/ls_reservation_station.vhd .
	cp ../tb/tb_ls_reservation_station.vhd .

	vcom utils_pkg.vhd
	vcom o3_pkg.vhd
	vcom tb_ls_reservation_station_pkg.vhd
	vcom ls_reservation_station.vhd
	vcom tb_ls_reservation_station.vhd

	vsim \
		-do ../scripts/tb_ls_reservation_station.do

clean:
	rm -f ./*.vhd
	rm -rf ./work
	rm -f transcript
	rm -f vsim.wlf
