vsim work.tb_t2_shifter -t 10ps -voptargs="+acc"
add wave *
add wave tb_t2_shifter/test_proc/tmp
run 2600 ns