`timescale 1ns/1ps

module tb_uart_rx;

reg clk;
reg reset;
reg baud_tick;
reg rx;

wire [7:0] rx_data;
wire rx_valid;
wire rx_busy;


// --------------------------------------------------
// UART RX DUT
// --------------------------------------------------

uart_rx dut (
    .clk(clk),
    .reset(reset),
    .baud_tick(baud_tick),
    .rx(rx),
    .rx_data(rx_data),
    .rx_valid(rx_valid),
    .rx_busy(rx_busy)
);


// --------------------------------------------------
// 50 MHz system clock
// Period = 20 ns
// --------------------------------------------------

always #10 clk = ~clk;


// --------------------------------------------------
// Fractional-style baud tick approximation
//
// 9600 baud × 16 = 153600 Hz
// Period ≈ 6510 ns
//
// The tick is HIGH for only one system clock (20 ns)
// --------------------------------------------------

initial begin

    baud_tick = 1'b0;

    forever begin
        #6490;
        baud_tick = 1'b1;

        #20;
        baud_tick = 1'b0;
    end

end


// --------------------------------------------------
// Send one UART bit
// Each UART bit = 16 baud ticks
// --------------------------------------------------

task send_bit;
    input bit_value;

    begin

        rx = bit_value;

        repeat (16) begin
            @(posedge baud_tick);
        end

    end

endtask


// --------------------------------------------------
// Send one UART byte
// 8 data bits, LSB first
// --------------------------------------------------

task send_byte;
    input [7:0] data;

    begin

        // Start bit
        send_bit(1'b0);

        // Data bits
        send_bit(data[0]);
        send_bit(data[1]);
        send_bit(data[2]);
        send_bit(data[3]);
        send_bit(data[4]);
        send_bit(data[5]);
        send_bit(data[6]);
        send_bit(data[7]);

        // Stop bit
        send_bit(1'b1);

    end

endtask


// --------------------------------------------------
// Test
// --------------------------------------------------

initial begin

    clk   = 1'b0;
    reset = 1'b1;
    rx    = 1'b1;

    // Reset
    #100;

    reset = 1'b0;

    // Wait before transmission
    #100;

    // Send B2
    send_byte(8'hB2);

    // Allow RX to finish
    #10000;

    $finish;

end


// --------------------------------------------------
// VCD waveform
// --------------------------------------------------

initial begin

    $dumpfile("uart_rx.vcd");
    $dumpvars(0, tb_uart_rx);

end
always @(posedge clk) begin
    if (rx_valid) begin
        $display("RX VALID! Received data = %h", rx_data);
    end
end

endmodule