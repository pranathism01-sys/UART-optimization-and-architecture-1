`timescale 1ns/1ps

module tb_baud_gen;

reg clk;
reg reset;
reg [15:0] baud_div;

wire baud_tick;

baud_gen dut (
    .clk(clk),
    .reset(reset),
    .baud_div(baud_div),
    .baud_tick(baud_tick)
);

always #10 clk = ~clk;

initial begin

    clk = 1'b0;
    reset = 1'b1;
    baud_div = 16'd326;

    #40;

    reset = 1'b0;

    #200000;

    $finish;

end

initial begin
    $dumpfile("baud_gen.vcd");
    $dumpvars(0, tb_baud_gen);
end

endmodule