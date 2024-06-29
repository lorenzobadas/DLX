vsim work.tb_boothmul -t 10ps -voptargs="+acc"
add wave *
add wave /tb_boothmul/test_proc/result
run 2560 ns