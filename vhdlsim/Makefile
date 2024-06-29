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

clean:
	rm -f ./*.vhd
	rm -rf ./work
	rm -f transcript
	rm -f vsim.wlf
