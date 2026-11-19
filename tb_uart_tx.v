`timescale 1ns/1ps

module tb_uart_tx;

reg clk;
reg reset;
reg baud_tick;
reg tx_start;
reg [7:0] tx_data;

wire tx;
wire tx_busy;
wire tx_done;

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

// 50 MHz system clock
always #10 clk = ~clk;

// Generate baud tick manually
// One baud tick every 20 ns for easy simulation
always #10 baud_tick = ~baud_tick;

initial begin

    clk = 1'b0;
    baud_tick = 1'b0;

    reset = 1'b1;
    tx_start = 1'b0;
    tx_data = 8'b0;

    // Hold reset
    #40;

    reset = 1'b0;

    // Transmit 10110010
    #40;
    tx_data = 8'b10110010;
    tx_start = 1'b1;

    #20;
    tx_start = 1'b0;

    // Allow transmission to complete
    #500;

    $finish;

end

initial begin
    $dumpfile("uart_tx.vcd");
    $dumpvars(0, tb_uart_tx);
end

endmodule