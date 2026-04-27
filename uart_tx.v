// =============================================================================
//  uart_tx.v — UART Transmitter FSM
//  States: IDLE → START → DATA → PARITY → STOP
//  Parameters: DATA_BITS, PARITY_EN, STOP_BITS
// =============================================================================

`timescale 1ns/1ps

module uart_tx #(
    parameter DATA_BITS = 8,    // 5–9 bit data width
    parameter PARITY_EN = 1,    // 1 = enable parity
    parameter PARITY_ODD = 0,   // 0 = even, 1 = odd
    parameter STOP_BITS = 1     // 1 or 2 stop bits
)(
    input  wire             clk,
    input  wire             rst_n,
    input  wire             tick,           // from baud_gen
    input  wire [DATA_BITS-1:0] tx_data,   // data from TX FIFO
    input  wire             tx_valid,       // TX FIFO has data
    output reg              tx_ready,       // ready to accept next byte
    output reg              tx_out,         // serial TX line
    output reg              tx_busy         // FSM active flag
);

    // State encoding
    localparam IDLE   = 3'd0;
    localparam START  = 3'd1;
    localparam DATA   = 3'd2;
    localparam PARITY = 3'd3;
    localparam STOP   = 3'd4;

    reg [2:0] state;
    reg [3:0] bit_cnt;
    reg [DATA_BITS-1:0] shift_reg;
    reg parity_bit;

    // TODO (Phase 02): Implement TX FSM state transitions

    initial begin
        tx_out   = 1'b1; // idle line HIGH
        tx_busy  = 1'b0;
        tx_ready = 1'b1;
        state    = IDLE;
    end

endmodule
