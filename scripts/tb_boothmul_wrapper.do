# Booth Multiplier Wrapper Simulation Script - Dual Test
vsim work.booth_multiplier_wrapper_tb -t 10ps -voptargs="+acc"
set NumericStdNoWarnings 1

add wave /booth_multiplier_wrapper_tb/clk
add wave /booth_multiplier_wrapper_tb/reset
add wave /booth_multiplier_wrapper_tb/flush

# Input operands
add wave -radix decimal /booth_multiplier_wrapper_tb/a
add wave -radix decimal /booth_multiplier_wrapper_tb/b

# Handshake signals
add wave /booth_multiplier_wrapper_tb/enable
add wave /booth_multiplier_wrapper_tb/stall
add wave /booth_multiplier_wrapper_tb/arbiter_request
add wave /booth_multiplier_wrapper_tb/bus_grant

# Results
add wave -radix decimal /booth_multiplier_wrapper_tb/result

# Test control
add wave /booth_multiplier_wrapper_tb/test_done

# DUT internal signals
add wave -divider "DUT Internals"
add wave /booth_multiplier_wrapper_tb/DUT/controller_inst/busy
add wave /booth_multiplier_wrapper_tb/DUT/controller_inst/result_ready
add wave /booth_multiplier_wrapper_tb/DUT/controller_inst/load_o

# run sim
run 2000 ns