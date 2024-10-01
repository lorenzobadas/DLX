vsim work.tb_reservation_station -t 10ps -voptargs="+acc"
add wave -r /*
run 500 ns