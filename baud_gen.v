// =============================================================================
//  baud_gen.v — Fractional Baud Rate Generator
//  Target: 9600 bps – 10 Mbps | Phase error < 0.5%
//  Parameters: CLK_FREQ, BAUD_RATE
// =============================================================================
//  TODO (Phase 02): Implement fractional divisor logic
//    - Integer part:    DIV_INT  = CLK_FREQ / (BAUD_RATE * OVERSAMPLE)
//    - Fractional part: DIV_FRAC = (CLK_FREQ % (BAUD_RATE * OVERSAMPLE)) scaled
//    - Output:          tick — one pulse per baud period
//                       tick16 — 16x oversampled tick for RX FSM

`timescale 1ns/1ps

module baud_gen #(
    parameter CLK_FREQ   = 50_000_000,  // System clock in Hz
    parameter BAUD_RATE  = 115_200,     // Target baud rate
    parameter OVERSAMPLE = 16           // Oversampling ratio for RX
)(
    input  wire clk,
    input  wire rst_n,
    input  wire [15:0] baud_div,        // Runtime-configurable divisor
    output wire tick,                   // 1 pulse per baud period (TX)
    output wire tick16                  // 16x tick (RX oversampling)
);

    // TODO: implement
    assign tick   = 1'b0;
    assign tick16 = 1'b0;

endmodule
