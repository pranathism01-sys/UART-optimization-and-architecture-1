`timescale 1ns/1ps

module tb_uart_tx_baud;

reg clk;
reg reset;
reg tx_start;
reg [7:0] tx_data;
reg [31:0] phase_inc;

wire baud_tick;
wire tx;
wire tx_busy;
wire tx_done;


// --------------------------------------------------
// Fractional Baud Generator
// --------------------------------------------------

baud_gen_frac baud_gen (
    .clk(clk),
    .reset(reset),
    .phase_inc(phase_inc),
    .baud_tick(baud_tick)
);


// --------------------------------------------------
// UART TX
// --------------------------------------------------

uart_tx dut (
    .clk(clk),
    .reset(reset),
    .baud_tick(baud_tick),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx(tx),
    .tx_busy(tx_busy),
    .tx_done(tx_done)
);


// --------------------------------------------------
// 50 MHz System Clock
// --------------------------------------------------

always #10 clk = ~clk;


// --------------------------------------------------
// Test
// --------------------------------------------------

initial begin

   clk       = 1'b0;
reset     = 1'b1;
tx_start  = 1'b0;
tx_data   = 8'h00;
phase_inc = 32'd13194140;

    // Reset
    #100;

    reset = 1'b0;

    // Give the circuit a little time
    #100;

    // Send B2 = 10110010
    tx_data  = 8'hB2;
    tx_start = 1'b1;

    #20;

    tx_start = 1'b0;

    // Wait for complete UART transmission
    #1_000_000;

    $finish;

end


// --------------------------------------------------
// Waveform dump
// --------------------------------------------------

initial begin

    $dumpfile("uart_tx_baud.vcd");
    $dumpvars(0, tb_uart_tx_baud);

end

endmodule