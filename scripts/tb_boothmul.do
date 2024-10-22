vsim work.tb_boothmul -t 10ps -voptargs="+acc"
set NumericStdNoWarnings 1
add wave -signed *
add wave -signed /tb_boothmul/test_proc/result
run 2560 ns