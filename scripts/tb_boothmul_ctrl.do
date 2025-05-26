vsim work.tb_control_boothmul -t 10ps -voptargs="+acc"
set NumericStdNoWarnings 1

# Show clock, reset & flush
add wave /tb_control_boothmul/clk_i
add wave /tb_control_boothmul/reset_i
add wave /tb_control_boothmul/flush_i

# Show input & handshake
add wave /tb_control_boothmul/enable_i
add wave /tb_control_boothmul/stall_o
add wave /tb_control_boothmul/arbiter_request_o

# Show grant from stub
add wave /tb_control_boothmul/bus_grant_i

# Show load_o vector
add wave -binary /tb_control_boothmul/load_o

# Run long enough to reset + fill + flush (~140 ns)
# We’ll run 200 ns to be safe
run 10000 ns
