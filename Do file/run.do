vlib work
vlog RAM.v SPI_slave.v SPI_wrapper.v SPI_wrapper_tb.v
vsim -voptargs=+acc work.SPI_tb
add wave *
add wave -position insertpoint  \
sim:/SPI_tb/DUT/rx_data \
sim:/SPI_tb/DUT/rx_valid \
sim:/SPI_tb/DUT/tx_data \
sim:/SPI_tb/DUT/tx_valid
add wave -position insertpoint  \
sim:/SPI_tb/DUT/RAM/mem
run -all
