vsim work.tb_cpu -t 10ps -voptargs="+acc"

add wave -divider "TB Signals"
add wave /tb_cpu/*

add wave -height 30 -divider "MEMORIES"
add wave -divider "Instruction Memory"
add wave /tb_cpu/imem_inst/ram_s

add wave -divider "Data Memory"
add wave -radix decimal /tb_cpu/dmem_inst/ram_s


add wave -divider "Instruction Fetch"
add wave /tb_cpu/cpu_inst/fetch_inst/*
add wave -divider "IF-ID"
add wave /tb_cpu/cpu_inst/if_id_regs_inst/*
add wave -divider "Instruction Decode"
add wave /tb_cpu/cpu_inst/decode_inst/*
add wave /tb_cpu/cpu_inst/decode_inst/reg_file/regs
add wave -divider "ID-EX"
add wave /tb_cpu/cpu_inst/id_ex_regs_inst/*
add wave -divider "Execution"
add wave /tb_cpu/cpu_inst/execute_inst/*
add wave -divider "EX-MEM"
add wave /tb_cpu/cpu_inst/ex_mem_regs_inst/*
add wave -divider "Memory Access"
add wave /tb_cpu/cpu_inst/mem_access_inst/*
add wave -divider "MEM-WB"
add wave /tb_cpu/cpu_inst/mem_wb_regs_inst/*
add wave -divider "Write Back"
add wave /tb_cpu/cpu_inst/write_back_inst/*

add wave -height 30 -divider "CONTROL"
add wave /tb_cpu/cpu_inst/control_unit_inst/*
add wave -divider "Hazard Unit"
add wave /tb_cpu/cpu_inst/hazard_unit_inst/*
add wave -divider "Forwarding Unit"
add wave /tb_cpu/cpu_inst/forwarding_unit_inst/*

run 100000 ns
