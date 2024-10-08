vsim work.tb_reorder_buffer -t 10ps -voptargs="+acc"
add wave /tb_reorder_buffer/clk
add wave /tb_reorder_buffer/reset
add wave /tb_reorder_buffer/dut/state
add wave /tb_reorder_buffer/dut/rob_fifo
add wave /*
run -all