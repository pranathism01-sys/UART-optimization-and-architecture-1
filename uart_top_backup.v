module uart_top (
    input  wire       clk,
    input  wire       reset,

    input  wire       tx_start,
    input  wire [7:0] tx_data,

    output wire       tx,
    output wire       tx_busy,
    output wire       tx_done,

    output wire [7:0] rx_data,
    output wire       rx_valid,
    output wire       rx_busy
);


// --------------------------------------------------
// Fractional baud generator
//
// 50 MHz clock
// 9600 baud
// 16x oversampling
//
// Phase increment previously verified in GTKWave:
// 00C9539C
// --------------------------------------------------

localparam [31:0] PHASE_INC = 32'h00C9539C;

wire baud_tick;


// --------------------------------------------------
// Internal UART loopback
//
// TX output is directly connected to RX input.
// This lets us test:
//
// TX → RX
// --------------------------------------------------

wire rx_internal;

assign rx_internal = tx;


// --------------------------------------------------
// Baud Generator
// --------------------------------------------------

baud_gen_frac baud_gen (
    .clk      (clk),
    .reset    (reset),
    .phase_inc(PHASE_INC),
    .baud_tick(baud_tick)
);


// --------------------------------------------------
// UART Transmitter
// --------------------------------------------------

uart_tx tx_module (
    .clk      (clk),
    .reset    (reset),
    .baud_tick(baud_tick),
    .tx_start  (tx_start),
    .tx_data   (tx_data),
    .tx        (tx),
    .tx_busy   (tx_busy),
    .tx_done   (tx_done)
);


// --------------------------------------------------
// UART Receiver
// --------------------------------------------------

uart_rx rx_module (
    .clk      (clk),
    .reset    (reset),
    .baud_tick(baud_tick),
    .rx        (rx_internal),
    .rx_data   (rx_data),
    .rx_valid  (rx_valid),
    .rx_busy   (rx_busy)
);


endmodule