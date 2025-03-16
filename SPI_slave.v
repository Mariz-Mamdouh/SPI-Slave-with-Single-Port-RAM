module SPI_slave (
    input clk,rst_n,
    input MOSI,
    input [7:0] tx_data,
    input tx_valid,
    input SS_n,
    output reg MISO,
    output reg [9:0] rx_data,
    output reg rx_valid
);

parameter   IDLE = 3'b000,
            CHK_CMD = 3'b001,
            WRITE = 3'b010,
            READ_ADD = 3'b011,
            READ_DATA = 3'b100;

reg [2:0] ns,cs;
reg read_flag;              // assert when READ_ADD done
reg [3:0] counter_s_p,counter_p_s;
reg [9:0] shift_reg;
reg [7:0] temp;
// State Memory block
always @(posedge clk) begin
    if (!rst_n) begin
        cs <= IDLE;
    end else begin
        cs <= ns;
    end
end

// Next state Logic block
always @(*) begin
    case (cs)
        IDLE: begin
            if (SS_n) ns = IDLE;
            else ns = CHK_CMD;
        end
        CHK_CMD: begin
            if (SS_n) begin
                ns = IDLE;
            end else begin
                if (MOSI) begin
                    if (read_flag) begin
                        ns = READ_DATA;
                    end else begin
                        ns = READ_ADD;
                    end
                end else ns = WRITE;
            end
        end
        WRITE: begin
            if (SS_n == 0) ns = WRITE;
            else ns = IDLE;
        end
        READ_ADD: begin
            if (SS_n == 0) ns = READ_ADD;
            else ns = IDLE;
        end
        READ_DATA: begin
            if (SS_n == 0) ns = READ_DATA;
            else ns = IDLE;
        end
        default: ns = IDLE;
    endcase
end

// Output Logic block
always @(posedge clk) begin
    if (!rst_n) begin
        rx_valid <= 0;
        rx_data <= 10'b0;
        MISO <= 0;
        read_flag <= 0;
        counter_s_p <= 0;
        counter_p_s <= 0;
        shift_reg <= 0;
        temp <= 0;
    end else begin
        case (cs)
        IDLE , CHK_CMD : begin
            counter_s_p <= 0;
            counter_p_s <= 0;
            shift_reg <= 0;
            rx_valid <= 0;
            rx_valid <= 0;
            temp <= 0;
            MISO <= 0;
        end
        WRITE: begin
            if (counter_s_p < 11 ) begin // why 11 :  10 for get 10 bit shifted left then 1 cycle for copy value of temp inside rx_data
                 counter_s_p <= counter_s_p + 1;
                 if (counter_s_p < 10 ) begin // mean i have already 10 cycles before and shift reg was ready to copy and at end of this edge counter will be 11 (remember non blocking)
                    shift_reg <= {shift_reg ,MOSI} ; // shifting left
                 end else if (shift_reg[9]== 1'b0)begin // mean counter equal 10
                     rx_valid <= 1;
                     rx_data <= shift_reg ;
                 end
            end else begin
                rx_valid <= 0 ;
            end
        end 
        READ_ADD: begin
            if (counter_s_p < 11 ) begin // why 11 :  10 for get 10 bit shifted left then 1 cycle for copy value of temp inside rx_data
                 counter_s_p <= counter_s_p + 1;
                 if (counter_s_p < 10 ) begin // mean i have already 10 cycles before and shift reg was ready to copy and at end of this edge counter will be 11 (remember non blocking)
                    shift_reg <= {shift_reg ,MOSI} ; // shifting left
                 end else if (shift_reg[9:8]== 2'b10)begin // mean counter equal 10
                     rx_valid <= 1;
                     rx_data <= shift_reg ;
                     read_flag <= 1 ;
                 end
            end else begin
                rx_valid <= 0 ;
            end
        end     
        READ_DATA: begin
            if(tx_valid == 0)begin
                if (counter_s_p < 11)begin
                    counter_s_p <= counter_s_p + 1;
                    if (counter_s_p < 10) begin
                        shift_reg <= {shift_reg[8:0],MOSI};
                    end else if (shift_reg[9:8] == 2'b11) begin
                        rx_valid <= 1;
                        rx_data <= shift_reg;
                    end
                end else if (counter_s_p > 11 && counter_p_s < 8) begin
                    {MISO,temp} <= {temp,1'b0};
                    read_flag <= 0;
                    counter_p_s <= counter_p_s + 1;
                end else begin // counter equal 11
                    rx_valid <= 0;
                end
            end else begin
                counter_s_p <= counter_s_p + 1;
                // rx_valid <= 0;
                temp <= tx_data;
            end 
        end
        endcase
    end//if
end//always
endmodule