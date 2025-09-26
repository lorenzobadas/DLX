vsim -L /eda/dk/nangate45/verilog/qsim2020.4 work.tb_cpu -voptargs="+acc"

add wave -divider "TB Signals"
add wave /tb_cpu/*

add wave -height 30 -divider "MEMORIES"
add wave -divider "Instruction Memory"
add wave /tb_cpu/imem_inst/ram_s

add wave -divider "Data Memory"
add wave -radix decimal /tb_cpu/dmem_inst/ram_s

run 100000 ns
