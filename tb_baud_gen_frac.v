`timescale 1ns/1ps

module tb_baud_gen_frac;

reg clk;
reg reset;
reg [31:0] phase_inc;

wire baud_tick;

integer tick_count;
time last_tick_time;
time tick_period;

baud_gen_frac dut (
    .clk(clk),
    .reset(reset),
    .phase_inc(phase_inc),
    .baud_tick(baud_tick)
);

// 50 MHz clock
always #10 clk = ~clk;

// Clock and reset
initial begin
    clk = 1'b0;
    reset = 1'b1;

    // 9600 baud × 16 oversampling
    // 32-bit fractional phase increment
    phase_inc = 32'd13194140;

    #40;
    reset = 1'b0;

    #200000;
    $finish;
end

// Generate VCD
initial begin
    $dumpfile("baud_gen_frac.vcd");
    $dumpvars(0, tb_baud_gen_frac);
end

// Measure baud tick period
initial begin
    tick_count = 0;
    last_tick_time = 0;

    forever begin
        @(posedge baud_tick);

        tick_count = tick_count + 1;

        if (tick_count > 1) begin
            tick_period = $time - last_tick_time;

            $display(
                "Tick %0d: Time = %0t ns, Period = %0t ns",
                tick_count,
                $time,
                tick_period
            );
        end
        else begin
            $display(
                "Tick %0d: Time = %0t ns",
                tick_count,
                $time
            );
        end

        last_tick_time = $time;

        if (tick_count == 20)
            $finish;
    end
end

endmodule