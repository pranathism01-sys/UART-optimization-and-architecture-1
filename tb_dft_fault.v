`timescale 1ns/1ps

module tb_dft_fault;

reg clk;
reg reset;
reg test_mode;
reg scan_in;

reg [15:0] parallel_in;

reg        fault_enable;
reg [3:0]  fault_bit;
reg        fault_value;

wire scan_out;
wire [15:0] parallel_out;

integer i;
integer cycle;

integer detected;
integer total_faults;

reg expected_bit;
reg fault_detected;


dft_scan dut (
    .clk          (clk),
    .reset        (reset),
    .test_mode    (test_mode),
    .scan_in      (scan_in),
    .scan_out     (scan_out),
    .parallel_in  (parallel_in),
    .parallel_out (parallel_out),

    .fault_enable (fault_enable),
    .fault_bit    (fault_bit),
    .fault_value  (fault_value)
);


// CLOCK
always #5 clk = ~clk;


// ==================================================
// STUCK-AT-0
// ==================================================

task test_stuck_at_0;

    input integer test_bit;

    begin

        reset = 1;
        test_mode = 0;
        scan_in = 0;

        fault_enable = 0;
        fault_bit = 0;
        fault_value = 0;

        #10;

        reset = 0;

        // Sensitize every bit to 1
        parallel_in = 16'hFFFF;

        #10;

        // Enable stuck-at-0
        fault_enable = 1;
        fault_bit = test_bit;
        fault_value = 0;

        test_mode = 1;

        fault_detected = 0;

        // Shift 16 cycles
        for (cycle = 0; cycle < 16; cycle = cycle + 1) begin

            // Fault-free expected value:
            // first output is bit 15 of FFFF,
            // then remaining captured bits.
            expected_bit = 1'b1;

            #10;

            if (scan_out != expected_bit)
                fault_detected = 1;

            scan_in = 0;

        end

        fault_enable = 0;

        if (fault_detected) begin

            detected = detected + 1;

            $display(
                "STUCK-AT-0 bit %0d : DETECTED",
                test_bit
            );

        end

        else begin

            $display(
                "STUCK-AT-0 bit %0d : NOT DETECTED",
                test_bit
            );

        end

    end

endtask


// ==================================================
// STUCK-AT-1
// ==================================================

task test_stuck_at_1;

    input integer test_bit;

    begin

        reset = 1;
        test_mode = 0;
        scan_in = 0;

        fault_enable = 0;
        fault_bit = 0;
        fault_value = 0;

        #10;

        reset = 0;

        // Sensitize every bit to 0
        parallel_in = 16'h0000;

        #10;

        // Enable stuck-at-1
        fault_enable = 1;
        fault_bit = test_bit;
        fault_value = 1;

        test_mode = 1;

        fault_detected = 0;

        for (cycle = 0; cycle < 16; cycle = cycle + 1) begin

            // Fault-free expected value
            expected_bit = 1'b0;

            #10;

            if (scan_out != expected_bit)
                fault_detected = 1;

            scan_in = 0;

        end

        fault_enable = 0;

        if (fault_detected) begin

            detected = detected + 1;

            $display(
                "STUCK-AT-1 bit %0d : DETECTED",
                test_bit
            );

        end

        else begin

            $display(
                "STUCK-AT-1 bit %0d : NOT DETECTED",
                test_bit
            );

        end

    end

endtask


// ==================================================
// MAIN TEST
// ==================================================

initial begin

    $dumpfile("dft_fault.vcd");
    $dumpvars(0, tb_dft_fault);

    clk = 0;
    clk = 0;
    reset = 1;

    test_mode = 0;
    scan_in = 0;

    parallel_in = 0;

    fault_enable = 0;
    fault_bit = 0;
    fault_value = 0;

    detected = 0;

    total_faults = 32;

    #20;

    reset = 0;

    $display("");
    $display("==========================================");
    $display("DFT STUCK-AT FAULT COVERAGE TEST");
    $display("==========================================");
    $display("");

    // 16 stuck-at-0 faults
    for (i = 0; i < 16; i = i + 1)
        test_stuck_at_0(i);

    // 16 stuck-at-1 faults
    for (i = 0; i < 16; i = i + 1)
        test_stuck_at_1(i);


    $display("");
    $display("==========================================");
    $display("DFT COVERAGE RESULT");
    $display("==========================================");

    $display(
        "Total faults tested = %0d",
        total_faults
    );

    $display(
        "Faults detected      = %0d",
        detected
    );

    $display(
        "Faults undetected    = %0d",
        total_faults - detected
    );

    $display(
        "Fault coverage       = %0d%%",
        (detected * 100) / total_faults
    );

    $display("==========================================");

    #20;

    $finish;

end

endmodule