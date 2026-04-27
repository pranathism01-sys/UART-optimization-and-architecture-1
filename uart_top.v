// =============================================================================
//  uart_top.v — Register-Mapped Top-Level (APB / Wishbone wrapper)
//  Registers:
//    0x00  CTRL    [7:0]  — parity_en, parity_odd, stop_bits, tx_en, rx_en
//    0x04  STATUS  [7:0]  — tx_busy, rx_valid, framing_err, parity_err,
//                           overrun_err, noise_err, tx_full, rx_empty
//    0x08  DATA    [7:0]  — write: TX data,  read: RX data
//    0x0C  BAUD    [15:0] — runtime baud divisor
// =============================================================================

`timescale 1ns/1ps

module uart_top #(
    parameter CLK_FREQ   = 50_000_000,
    parameter BAUD_RATE  = 115_200,
    parameter DATA_BITS  = 8,
    parameter FIFO_DEPTH = 16,
    parameter PARITY_EN  = 1,
    parameter STOP_BITS  = 1
)(
    input  wire        clk,
    input  wire        rst_n,

    // APB-style slave interface
    input  wire [3:0]  paddr,
    input  wire        psel,
    input  wire        penable,
    input  wire        pwrite,
    input  wire [31:0] pwdata,
    output reg  [31:0] prdata,
    output wire        pready,

    // Physical UART lines
    output wire        uart_tx,
    input  wire        uart_rx
);

    // Internal wires (connect sub-modules here in Phase 03)
    wire tick, tick16;
    wire [DATA_BITS-1:0] tx_data, rx_data;
    wire tx_valid, tx_ready, rx_valid;
    wire framing_err, parity_err, overrun_err, noise_err;

    assign pready = 1'b1;  // zero-wait APB (update if pipelining needed)

    // TODO (Phase 03): Wire up baud_gen, uart_tx, uart_rx, uart_fifo
    //                  and implement APB register read/write logic

endmodule
