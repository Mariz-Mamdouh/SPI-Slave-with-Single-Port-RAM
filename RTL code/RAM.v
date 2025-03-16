module RAM(
    input clk,rst_n,
    input [9:0] din,
    input rx_valid,
    output reg [7:0] dout,
    output reg tx_valid
);
parameter   MEM_DEPTH = 256,
            ADDR_SIZE = 8;

reg [ADDR_SIZE-1:0] mem [MEM_DEPTH-1:0];
reg [ADDR_SIZE-1:0] wr_addr,rd_addr;

always @(posedge clk) begin
    if (!rst_n) begin
        dout <= 0;
        tx_valid <= 0;
        wr_addr <= 0;
        rd_addr <= 0;
    end else begin
        if (rx_valid) begin
            case (din[9:8])
                2'b00: begin
                    wr_addr <= din[7:0];        // Store write address
                    tx_valid <= 0;
                end
                2'b01: begin
                    mem[wr_addr] <= din[7:0];   // Write to memory
                    tx_valid <= 0;
                end
                2'b10: begin
                    rd_addr <= din[7:0];        // Store the read address
                    tx_valid <= 0;
                end
                2'b11: begin
                    dout <= mem[rd_addr];       // Read from memory
                    tx_valid <= 1;
                end
            endcase
        end else begin
             tx_valid <= 0;
        end
    end
end
endmodule