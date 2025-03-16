module SPI_wrapper (
    input clk,rst_n,
    input MOSI,
    input SS_n,
    output MISO
);

wire [9:0] rx_data;
wire rx_valid;
wire [7:0] tx_data;
wire tx_valid;

SPI_slave SPI(clk,rst_n,MOSI,tx_data,tx_valid,SS_n,MISO,rx_data,rx_valid);
RAM RAM(clk,rst_n,rx_data,rx_valid,tx_data,tx_valid);

endmodule