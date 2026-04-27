// =============================================================================
//  uart_rx.v — UART Receiver FSM with 16x Oversampling
//  States: IDLE → START → DATA → PARITY → STOP
//  Error flags: framing_err, parity_err, overrun_err, noise_err
// =============================================================================

`timescale 1ns/1ps

module uart_rx #(
    parameter DATA_BITS  = 8,
    parameter PARITY_EN  = 1,
    parameter PARITY_ODD = 0,
    parameter STOP_BITS  = 1,
    parameter OVERSAMPLE = 16
)(
    input  wire             clk,
    input  wire             rst_n,
    input  wire             tick16,         // 16x oversample tick from baud_gen
    input  wire             rx_in,          // serial RX line
    output reg  [DATA_BITS-1:0] rx_data,   // received byte
    output reg              rx_valid,       // pulse: valid byte received
    output reg              framing_err,    // stop bit was not HIGH
    output reg              parity_err,     // parity mismatch
    output reg              overrun_err,    // new byte before old read
    output reg              noise_err       // majority vote failed
);

    localparam IDLE   = 3'd0;
    localparam START  = 3'd1;
    localparam DATA   = 3'd2;
    localparam PARITY = 3'd3;
    localparam STOP   = 3'd4;

    reg [2:0]  state;
    reg [3:0]  tick_cnt;    // counts 0–15 within each bit period
    reg [3:0]  bit_cnt;
    reg [DATA_BITS-1:0] shift_reg;
    reg [2:0]  sample_buf;  // 3-sample majority vote for noise rejection

    // TODO (Phase 02): Implement RX FSM with oversampling and error detection

endmodule
