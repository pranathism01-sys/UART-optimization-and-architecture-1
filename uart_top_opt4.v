module uart_top #(
    parameter integer DATA_BITS  = 8,
    parameter integer PARITY_EN  = 0,
    parameter integer PARITY_ODD = 0,
    parameter integer STOP_BITS  = 1,
    parameter integer FIFO_DEPTH = 16,
    parameter [23:0] PHASE_INC  = 24'h00C954
)(
    input  wire       clk,
    input  wire       reset,

    input  wire       tx_start,
    input  wire [7:0] tx_data,

    output wire       tx,
    output wire       tx_busy,
    output wire       tx_done,

    output wire [7:0] rx_data,
output wire       rx_valid,
output wire       rx_busy,

// RX FIFO interface
input  wire       rx_read_en,
output wire [7:0] rx_fifo_data,
output wire       rx_fifo_empty,
output wire       rx_fifo_full
);


// ==================================================
// BAUD GENERATOR
// ==================================================


wire baud_tick;


// ==================================================
// TX FIFO
// ==================================================

wire [7:0] tx_fifo_dout;
wire       tx_fifo_full;
wire       tx_fifo_empty;

reg        tx_fifo_wr_en;
reg        tx_fifo_rd_en;
// --------------------------------------------------
// RX FIFO
// --------------------------------------------------

wire [7:0] rx_fifo_dout;
wire       rx_fifo_full_internal;
wire       rx_fifo_empty_internal;

reg        rx_fifo_wr_en;
reg        rx_fifo_rd_en;

reg [7:0]  tx_byte;
reg        tx_start_internal;
reg [1:0] tx_ctrl_state;

localparam TX_IDLE    = 2'd0;
localparam TX_FETCH   = 2'd1;
localparam TX_CAPTURE = 2'd2;
localparam TX_START   = 2'd3;


// ==================================================
// RX INTERNAL LOOPBACK
// ==================================================

wire rx_internal;

assign rx_internal = tx;


// ==================================================
// TX CONTROL
// ==================================================





// ==================================================
// BAUD GENERATOR
// ==================================================

baud_gen_frac_opt2  baud_gen (
    .clk       (clk),
    .reset     (reset),
    .phase_inc (PHASE_INC),
    .baud_tick (baud_tick)
);


// ==================================================
// TX FIFO
// ==================================================

fifo #(
    .DATA_WIDTH(DATA_BITS),
    .DEPTH(FIFO_DEPTH)
) tx_fifo (
    .clk   (clk),
    .reset (reset),

    .wr_en (tx_fifo_wr_en),
    .rd_en (tx_fifo_rd_en),
    .din   (tx_data),

    .dout  (tx_fifo_dout),
    .full  (tx_fifo_full),
    .empty (tx_fifo_empty)
    );
   
// --------------------------------------------------
// RX FIFO
// --------------------------------------------------

fifo #(
    .DATA_WIDTH(DATA_BITS),
    .DEPTH(FIFO_DEPTH)
) rx_fifo (
    .clk    (clk),
    .reset  (reset),
    .wr_en  (rx_fifo_wr_en),
    .rd_en  (rx_fifo_rd_en),
    .din    (rx_data),
    .dout   (rx_fifo_dout),
    .full   (rx_fifo_full_internal),
    .empty  (rx_fifo_empty_internal)
    );
    assign rx_fifo_data  = rx_fifo_dout;
assign rx_fifo_empty = rx_fifo_empty_internal;
assign rx_fifo_full  = rx_fifo_full_internal;
// --------------------------------------------------
// RX FIFO WRITE / READ CONTROL
// --------------------------------------------------

always @(posedge clk) begin

    if (reset) begin
        rx_fifo_wr_en <= 1'b0;
        rx_fifo_rd_en <= 1'b0;
    end

    else begin

        // Default: no FIFO operation
        rx_fifo_wr_en <= 1'b0;
        rx_fifo_rd_en <= 1'b0;

        // Write received byte into RX FIFO
        if (rx_valid && !rx_fifo_full_internal) begin
            rx_fifo_wr_en <= 1'b1;
        end

        // Read byte from RX FIFO
        if (rx_read_en && !rx_fifo_empty_internal) begin
            rx_fifo_rd_en <= 1'b1;
        end

    end

end



// ==================================================
// UART TRANSMITTER
// ==================================================

uart_tx #(
    .DATA_BITS(DATA_BITS),
    .PARITY_EN(PARITY_EN),
    .PARITY_ODD(PARITY_ODD),
    .STOP_BITS(STOP_BITS)
) tx_module (
    .clk       (clk),
    .reset     (reset),
    .baud_tick (baud_tick),

    .tx_start  (tx_start_internal),
    .tx_data   (tx_byte),

    .tx        (tx),
    .tx_busy   (tx_busy),
    .tx_done   (tx_done)
);


// ==================================================
// UART RECEIVER
// ==================================================

uart_rx_opt4 #(
    .DATA_BITS(DATA_BITS),
    .PARITY_EN(PARITY_EN),
    .PARITY_ODD(PARITY_ODD),
    .STOP_BITS(STOP_BITS)
) rx_module (
    .clk       (clk),
    .reset     (reset),
    .baud_tick (baud_tick),

    .rx        (rx_internal),

    .rx_data   (rx_data),
    .rx_valid  (rx_valid),
    .rx_busy   (rx_busy)
);

// ==================================================
// TX FIFO CONTROL - OPTIMIZATION 2
// ==================================================

always @(posedge clk) begin

    if (reset) begin

        tx_fifo_wr_en     <= 1'b0;
        tx_fifo_rd_en     <= 1'b0;

        tx_byte           <= 8'h00;
        tx_start_internal <= 1'b0;

        tx_ctrl_state     <= TX_IDLE;

    end

    else begin

        // Default: one-clock pulses
        tx_fifo_wr_en     <= 1'b0;
        tx_fifo_rd_en     <= 1'b0;
        tx_start_internal <= 1'b0;

        // --------------------------------------------------
        // WRITE NEW DATA INTO TX FIFO
        // --------------------------------------------------

        if (tx_start && !tx_fifo_full) begin
            tx_fifo_wr_en <= 1'b1;
        end

        // --------------------------------------------------
        // TX FIFO CONTROL FSM
        // --------------------------------------------------

        case (tx_ctrl_state)

            // ----------------------------------------------
            // IDLE
            // ----------------------------------------------

            TX_IDLE: begin

                if (!tx_busy && !tx_fifo_empty) begin

                    tx_fifo_rd_en <= 1'b1;
                    tx_ctrl_state <= TX_FETCH;

                end

            end


            // ----------------------------------------------
            // WAIT FOR FIFO READ
            // ----------------------------------------------

            TX_FETCH: begin

                tx_ctrl_state <= TX_CAPTURE;

            end


            // ----------------------------------------------
            // CAPTURE FIFO DATA
            // ----------------------------------------------

            TX_CAPTURE: begin

                tx_byte       <= tx_fifo_dout;
                tx_ctrl_state <= TX_START;

            end


            // ----------------------------------------------
            // START TRANSMISSION
            // ----------------------------------------------

            TX_START: begin

                if (!tx_busy) begin

                    tx_start_internal <= 1'b1;
                    tx_ctrl_state     <= TX_IDLE;

                end

            end

            default: begin

                tx_ctrl_state <= TX_IDLE;

            end

        endcase

    end

end
endmodule 

