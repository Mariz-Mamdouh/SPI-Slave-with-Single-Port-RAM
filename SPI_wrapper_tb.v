module SPI_tb;
reg clk,rst_n;
reg MOSI;
reg SS_n;
wire MISO;

SPI_wrapper DUT(.*);

initial begin
    clk = 0;
    forever begin
        #1 clk = ~clk;
    end
end

initial begin
     $readmemb ("mem.dat", DUT.RAM.mem);
    rst_n = 0;
    SS_n = 1;
    MOSI = 0;
    @(negedge clk);
    rst_n = 1;

    // Test case1 : write address 10'b0000001111 -> 15
    SS_n = 0; 
    @(negedge clk);
    @(negedge clk);
    // here we in Write
    // Enter the write address MSB first
    MOSI = 0; @(negedge clk);//msb
    MOSI = 0; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    @(negedge clk); // extra clock cycles to check that data will not change 
    SS_n = 1; @(negedge clk);

    // Test case2 : write data 10'b0100001110 -> 14
    SS_n = 0; @(negedge clk);
    MOSI = 0; @(negedge clk);
    // Enter the write data MSB first
    MOSI = 0; @(negedge clk); // MSB
    MOSI = 1; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 0; @(negedge clk);
     @(negedge clk); // extra clock cycles to check that data will not change 
    SS_n = 1; @(negedge clk);


    // Test case3 : read add 10'b0000001111 -> 15
    SS_n = 0; @(negedge clk);
    MOSI = 1; @(negedge clk);
    // Enter the read address MSB first
    MOSI = 1; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    @(negedge clk); // extra clock cycles to check that data will not change 
    SS_n = 1; @(negedge clk);
    
    // Test case4 : read data 10'b1100001110 -> 14
    SS_n = 0; @(negedge clk);
    MOSI = 1; @(negedge clk);
    // Enter the read data MSB first
    MOSI = 1; @(negedge clk);
    MOSI = 1; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 0; @(negedge clk);
    MOSI = 0; @(negedge clk);
    @(negedge clk); // extra clock cycles to check that data will not change
    @(negedge clk); // extra clock cycles to check that data will not change
    repeat(8)begin
       @(negedge clk); 
    end
    SS_n = 1; @(negedge clk);

    $stop;
end
endmodule