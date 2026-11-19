module uart_tx #(
    parameter integer DATA_BITS  = 8,
    parameter         PARITY_EN  = 1'b0,
    parameter         PARITY_ODD = 1'b0,
    parameter integer STOP_BITS  = 1
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       baud_tick,
    input  wire       tx_start,
    input  wire [7:0] tx_data,

    output reg        tx,
    output reg        tx_busy,
    output reg        tx_done
);

localparam IDLE   = 3'b000;
localparam START  = 3'b001;
localparam DATA   = 3'b010;
localparam PARITY = 3'b011;
localparam STOP   = 3'b100;

localparam [2:0] DATA_LAST = DATA_BITS[2:0] - 3'd1;
localparam [1:0] STOP_LAST = STOP_BITS[1:0] - 2'd1;

reg [2:0] state;

reg [3:0] sample_count;
reg [2:0] bit_count;
reg [1:0] stop_count;

reg [7:0] data_reg;
reg       parity_bit;

always @(posedge clk) begin

    if (reset) begin

        state        <= IDLE;
        sample_count <= 4'd0;
        bit_count    <= 3'd0;
        stop_count   <= 2'd0;

        data_reg     <= 8'd0;
        parity_bit   <= 1'b0;

        tx            <= 1'b1;
        tx_busy       <= 1'b0;
        tx_done       <= 1'b0;

    end

    else begin

        tx_done <= 1'b0;

        case (state)

            IDLE: begin

                tx           <= 1'b1;
                tx_busy      <= 1'b0;
                sample_count <= 4'd0;
                bit_count    <= 3'd0;
                stop_count   <= 2'd0;

                if (tx_start) begin

                    data_reg <= tx_data;

                    if (PARITY_ODD)
                        parity_bit <= ~(^tx_data[DATA_BITS-1:0]);
                    else
                        parity_bit <=  ^tx_data[DATA_BITS-1:0];

                    tx_busy      <= 1'b1;
                    sample_count <= 4'd0;
                    bit_count    <= 3'd0;

                    state <= START;

                end

            end

            START: begin

                tx <= 1'b0;

                if (baud_tick) begin

                    if (sample_count == 4'd15) begin

                        sample_count <= 4'd0;
                        bit_count    <= 3'd0;

                        state <= DATA;

                    end

                    else begin
                        sample_count <= sample_count + 4'd1;
                    end

                end

            end

            DATA: begin

                tx <= data_reg[bit_count];

                if (baud_tick) begin

                    if (sample_count == 4'd15) begin

                        sample_count <= 4'd0;

                        if (bit_count == DATA_LAST) begin

                            bit_count <= 3'd0;

                            if (PARITY_EN)
                                state <= PARITY;
                            else
                                state <= STOP;

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

            PARITY: begin

                tx <= parity_bit;

                if (baud_tick) begin

                    if (sample_count == 4'd15) begin

                        sample_count <= 4'd0;
                        stop_count   <= 2'd0;

                        state <= STOP;

                    end

                    else begin
                        sample_count <= sample_count + 4'd1;
                    end

                end

            end

            STOP: begin

                tx <= 1'b1;

                if (baud_tick) begin

                    if (sample_count == 4'd15) begin

                        sample_count <= 4'd0;

                        if (stop_count == STOP_LAST) begin

                            tx_done     <= 1'b1;
                            tx_busy     <= 1'b0;
                            stop_count  <= 2'd0;

                            state <= IDLE;

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

            default: begin

                state        <= IDLE;
                tx           <= 1'b1;
                tx_busy      <= 1'b0;
                sample_count <= 4'd0;
                bit_count    <= 3'd0;
                stop_count   <= 2'd0;

            end

        endcase

    end

end

endmodule
