vsim work.tb_cpu -t 10ps -voptargs="+acc"

add wave /tb_cpu/*
add wave /tb_cpu/cpu_inst/decode_inst/reg_file/regs
add wave /tb_cpu/cpu_inst/mem_access_inst/*
add wave /tb_cpu/cpu_inst/write_back_inst/*
run 100ns
