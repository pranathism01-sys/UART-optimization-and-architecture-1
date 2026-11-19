module uart_rx (
    input  wire       clk,
    input  wire       reset,
    input  wire       baud_tick,
    input  wire       rx,

    output reg [7:0]  rx_data,
    output reg        rx_valid,
    output reg        rx_busy
);

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

reg [1:0] state;

reg [3:0] sample_count;
reg [2:0] bit_count;

reg [7:0] data_reg;

// RX synchronizer
reg rx_sync1;
reg rx_sync2;

always @(posedge clk) begin

    if (reset) begin
        rx_sync1 <= 1'b1;
        rx_sync2 <= 1'b1;
    end
    else begin
        rx_sync1 <= rx;
        rx_sync2 <= rx_sync1;
    end

end
always @(*) begin
    rx_busy =(state != IDLE);
end
always @(posedge clk) begin

    if (reset) begin
        state        <= IDLE;
        sample_count <= 4'd0;
        bit_count    <= 3'd0;
        data_reg     <= 8'd0;

        rx_data      <= 8'd0;
        rx_valid     <= 1'b0;
        
    end

    else begin

        rx_valid <= 1'b0;

        case (state)

            IDLE: begin
                
                sample_count <= 4'd0;
                bit_count    <= 3'd0;

                // Detect start bit
                if (rx_sync2 == 1'b0) begin
                    state        <= START;
    
                    sample_count <= 4'd0;
                end
            end


            START: begin

                if (baud_tick) begin

                    if (sample_count == 4'd7) begin

                        // Check that RX is still LOW
                        if (rx_sync2 == 1'b0) begin
                            state        <= DATA;
                            sample_count <= 4'd0;
                            bit_count    <= 3'd0;
                        end
                        else begin
                            // False start
                            state   <= IDLE;
                            
                        end

                    end
                    else begin
                        sample_count <= sample_count + 4'd1;
                    end

                end

            end


            DATA: begin

                if (baud_tick) begin

                    if (sample_count == 4'd15) begin

                        // Sample data bit
                        data_reg[bit_count] <= rx_sync2;

                        sample_count <= 4'd0;

                        if (bit_count == 3'd7) begin
                            bit_count <= 3'd0;
                            state     <= STOP;
                        end
                        else begin
                            bit_count <= bit_count + 3'd1;
                        end

                    end
                    else begin
                        sample_count <= sample_count + 4'd1;
                    end

                end

            end


            STOP: begin

                if (baud_tick) begin

                    if (sample_count == 4'd15) begin

                        // Check stop bit
                        if (rx_sync2 == 1'b1) begin
                            rx_data  <= data_reg;
                            rx_valid <= 1'b1;
                        end

                        
                        sample_count <= 4'd0;
                        state        <= IDLE;

                    end
                    else begin
                        sample_count <= sample_count + 4'd1;
                    end

                end

            end

        endcase

    end

end

endmodule
