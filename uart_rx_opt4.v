module uart_rx_opt4 #(
    parameter integer DATA_BITS  = 8,
    parameter integer PARITY_EN  = 0,
    parameter integer PARITY_ODD = 0,
    parameter integer STOP_BITS  = 1
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       baud_tick,
    input  wire       rx,

    output reg [7:0] rx_data,
    output reg       rx_valid,
    output reg       rx_busy
);

localparam IDLE   = 3'b000;
localparam START  = 3'b001;
localparam DATA   = 3'b010;
localparam PARITY = 3'b011;
localparam STOP   = 3'b100;

reg [2:0] state;

reg [3:0] sample_count;
reg [3:0] bit_count;
reg [1:0] stop_count;

reg [7:0] data_reg;
reg       parity_error;
reg       parity_bit;

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


always @(posedge clk) begin

    if (reset) begin

        state        <= IDLE;
        sample_count <= 4'd0;
        bit_count    <= 4'd0;
        stop_count   <= 2'd0;

        data_reg     <= 8'd0;
        parity_error <= 1'b0;
        parity_bit   <= 1'b0;

        rx_data      <= 8'd0;
        rx_valid     <= 1'b0;
        rx_busy      <= 1'b0;

    end

    else begin

        rx_valid <= 1'b0;

        case (state)

            // ==========================================
            // IDLE
            // ==========================================

            IDLE: begin

                rx_busy      <= 1'b0;
                sample_count <= 4'd0;
                bit_count    <= 4'd0;
                stop_count   <= 2'd0;

                if (rx_sync2 == 1'b0) begin

                    state        <= START;
                    rx_busy      <= 1'b1;
                    sample_count <= 4'd0;

                end

            end


            // ==========================================
            // START BIT
            // ==========================================

            START: begin

                if (baud_tick) begin

                    if (sample_count == 4'd7) begin

                        if (rx_sync2 == 1'b0) begin

                            state        <= DATA;
                            sample_count <= 4'd0;
                            bit_count    <= 4'd0;
                            parity_error <= 1'b0;

                        end

                        else begin

                            state   <= IDLE;
                            rx_busy <= 1'b0;

                        end

                    end

                    else begin

                        sample_count <= sample_count + 4'd1;

                    end

                end

            end


            // ==========================================
            // DATA BITS
            // ==========================================

            DATA: begin

                if (baud_tick) begin

                    if (sample_count == 4'd15) begin

                        data_reg[bit_count] <= rx_sync2;

                        sample_count <= 4'd0;

                        if (bit_count == DATA_BITS-1) begin

                            bit_count <= 4'd0;

                            if (PARITY_EN)
                                state <= PARITY;
                            else begin
                                stop_count <= 2'd0;
                                state <= STOP;
                            end

                        end

                        else begin

                            bit_count <= bit_count + 4'd1;

                        end

                    end

                    else begin

                        sample_count <= sample_count + 4'd1;

                    end

                end

            end


            // ==========================================
            // PARITY BIT
            // ==========================================

            PARITY: begin

                if (baud_tick) begin

                    if (sample_count == 4'd15) begin

                        parity_bit <= rx_sync2;

                        // Calculate expected parity
                        if (PARITY_ODD)
                            parity_error <=
                                ((^data_reg[DATA_BITS-1:0]) == rx_sync2);
                        else
                            parity_error <=
                                ((^data_reg[DATA_BITS-1:0]) != rx_sync2);

                        sample_count <= 4'd0;
                        stop_count   <= 2'd0;

                        state <= STOP;

                    end

                    else begin

                        sample_count <= sample_count + 4'd1;

                    end

                end

            end


            // ==========================================
            // STOP BIT(S)
            // ==========================================

            STOP: begin

                if (baud_tick) begin

                    if (sample_count == 4'd15) begin

                        sample_count <= 4'd0;

                        if (rx_sync2 == 1'b1 && !parity_error) begin
                            rx_data  <= data_reg;
                            rx_valid <= 1'b1;
                        end

                        if (stop_count == STOP_BITS-1) begin

                            rx_busy    <= 1'b0;
                            stop_count <= 2'd0;
                            state      <= IDLE;

                        end

                        else begin

                            stop_count <= stop_count + 2'd1;

                        end

                    end

                    else begin

                        sample_count <= sample_count + 4'd1;

                    end

                end

            end


            // ==========================================
            // DEFAULT
            // ==========================================

            default: begin

                state        <= IDLE;
                rx_busy      <= 1'b0;
                sample_count <= 4'd0;
                bit_count    <= 4'd0;
                stop_count   <= 2'd0;

            end

        endcase

    end

end

endmodule