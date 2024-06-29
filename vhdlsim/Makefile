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
	vcom carry_generator.vhd
	vcom rca.vhd
	vcom carry_select_adder.vhd
	vcom sum_generator.vhd
	vcom xor_layer.vhd
	vcom p4_adder.vhd
	vcom tb_p4_adder.vhd

	vsim \
		-do ../scripts/tb_p4_adder.do


clean:
	rm -f ./*.vhd
	rm -rf ./work
	rm -f transcript
	rm -f vsim.wlf
