// =============================================================================
//  uart_fifo.v — Parameterized Synchronous FIFO
//  Depth: 8 / 16 / 32 / 64 (parameter)
//  Flags: full, empty, almost_full, overrun
// =============================================================================

`timescale 1ns/1ps

module uart_fifo #(
    parameter DEPTH     = 16,   // Must be power of 2: 8, 16, 32, 64
    parameter DATA_W    = 8
)(
    input  wire             clk,
    input  wire             rst_n,
    // Write port
    input  wire             wr_en,
    input  wire [DATA_W-1:0] wr_data,
    output wire             full,
    output wire             almost_full,    // DEPTH - 2 entries used
    // Read port
    input  wire             rd_en,
    output wire [DATA_W-1:0] rd_data,
    output wire             empty,
    output wire             overrun         // write attempted when full
);

    localparam ADDR_W = $clog2(DEPTH);

    reg [DATA_W-1:0] mem [0:DEPTH-1];
    reg [ADDR_W:0]   wr_ptr;
    reg [ADDR_W:0]   rd_ptr;

    wire [ADDR_W:0] count = wr_ptr - rd_ptr;

    assign full        = (count == DEPTH);
    assign empty       = (count == 0);
    assign almost_full = (count >= DEPTH - 2);
    assign rd_data     = mem[rd_ptr[ADDR_W-1:0]];
    assign overrun     = full & wr_en;

    // TODO (Phase 03): Implement FIFO write/read logic

endmodule
