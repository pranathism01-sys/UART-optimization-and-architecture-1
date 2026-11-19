`timescale 1ns/1ps

module tb_dft_scan;

reg clk;
reg reset;
reg test_mode;
reg scan_in;

reg [15:0] parallel_in;

wire scan_out;
wire [15:0] parallel_out;

dft_scan dut (
    .clk          (clk),
    .reset        (reset),
    .test_mode    (test_mode),
    .scan_in      (scan_in),
    .scan_out     (scan_out),
    .parallel_in  (parallel_in),
    .parallel_out (parallel_out)
);

// Clock
always #5 clk = ~clk;


// --------------------------------------------------
// SHIFT ONE BIT
// --------------------------------------------------

task shift_bit;
    input bit_value;
    begin
        scan_in = bit_value;
        #10;
    end
endtask


initial begin
    $dumpfile("dft_scan.vcd");
$dumpvars(0, tb_dft_scan);

    clk          = 0;
    reset        = 1;
    test_mode    = 0;
    scan_in      = 0;
    parallel_in  = 16'h0000;

    #20;

    reset = 0;

    // ------------------------------------------------
    // LOAD PARALLEL TEST DATA
    // ------------------------------------------------

    parallel_in = 16'hA5A5;

    #10;

    $display("------------------------------------------");
    $display("DFT PARALLEL CAPTURE TEST");
    $display("------------------------------------------");

    $display("Parallel input  = %h", parallel_in);
    $display("Parallel output = %h", parallel_out);

    // ------------------------------------------------
    // SCAN SHIFT TEST
    // ------------------------------------------------

    test_mode = 1;

    $display("");
    $display("------------------------------------------");
    $display("DFT SCAN CHAIN TEST");
    $display("------------------------------------------");

    // Shift 16 bits
    shift_bit(1);
    shift_bit(0);
    shift_bit(1);
    shift_bit(0);
    shift_bit(0);
    shift_bit(1);
    shift_bit(0);
    shift_bit(1);

    shift_bit(1);
    shift_bit(0);
    shift_bit(1);
    shift_bit(0);
    shift_bit(0);
    shift_bit(1);
    shift_bit(0);
    shift_bit(1);

    $display("Scan chain output = %b", parallel_out);
    $display("Scan out          = %b", scan_out);

    // ------------------------------------------------
    // END
    // ------------------------------------------------

    #20;

    $display("");
    $display("------------------------------------------");
    $display("DFT SCAN TEST COMPLETED");
    $display("------------------------------------------");

    $finish;

end

endmodule