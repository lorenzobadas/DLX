vsim work.tb_alu -t 10ps -voptargs="+acc"
add wave -r /*
delete wave -r /tb_alu/dut/p4_adder_inst/*
delete wave -r /tb_alu/dut/t2_shifter_inst/*
delete wave -r /tb_alu/dut/t2_logic_ops_inst/*
run -all