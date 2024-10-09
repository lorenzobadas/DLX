vsim work.tb_ls_reservation_station -t 10ps -voptargs="+acc"
add wave -r /tb_ls_reservation_station/dut/*
run -all