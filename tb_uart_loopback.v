// =============================================================================
//  tb_uart_loopback.v — Self-checking loopback testbench
//  Connects TX output directly to RX input and checks round-trip integrity
//  Runs all baud rates × parity modes automatically
// =============================================================================

`timescale 1ns/1ps

module tb_uart_loopback;

    // ── Clock & Reset ──────────────────────────────────────────────────────
    parameter CLK_PERIOD = 20;  // 50 MHz clock (20 ns period)

    reg clk;
    reg rst_n;

    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // ── DUT Instantiation ──────────────────────────────────────────────────
    wire uart_tx_line;
    reg  uart_rx_line;

    // TODO: instantiate uart_top here after Phase 02 RTL is complete

    // ── VCD Dump ───────────────────────────────────────────────────────────
    initial begin
        $dumpfile("sim/uart_sim.vcd");
        $dumpvars(0, tb_uart_loopback);
    end

    // ── Test Variables ─────────────────────────────────────────────────────
    integer pass_count = 0;
    integer fail_count = 0;
    reg [7:0] send_byte;
    reg [7:0] recv_byte;

    // ── Test Sequences ─────────────────────────────────────────────────────
    initial begin
        rst_n = 0;
        #(CLK_PERIOD * 10);
        rst_n = 1;
        #(CLK_PERIOD * 5);

        $display("=== UART Loopback Testbench ===");

        // TODO (Phase 02): Implement test tasks:
        //   task send_byte(input [7:0] data);
        //   task check_rx(input [7:0] expected);
        //   Run all baud rates: 9600, 115200, 1000000, 10000000
        //   Run parity modes: none, even, odd

        #(CLK_PERIOD * 100);

        $display("PASS: %0d  FAIL: %0d", pass_count, fail_count);
        if (fail_count == 0)
            $display("ALL TESTS PASSED ✓");
        else
            $display("FAILURES DETECTED ✗");

        $finish;
    end

endmodule
