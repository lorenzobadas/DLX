vsim work.tb_boothmul_pipelined -t 10ps -voptargs="+acc"
set NumericStdNoWarnings 1

# Show inputs and output
add wave -signed /tb_boothmul_pipelined/A_in \
                /tb_boothmul_pipelined/B_in \
                /tb_boothmul_pipelined/res

# Show counters and exp_queue
add wave /tb_boothmul_pipelined/idx \
         /tb_boothmul_pipelined/chk_idx

# Run for (TB_LEN + PIPELINE_LATENCY) * CLK_PERIOD = (8+3)*10ns = 110ns
run 1000 ns

