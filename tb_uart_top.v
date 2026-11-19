`timescale 1ns/1ps

module tb_uart_top;

reg clk;
reg reset;

reg        tx_start;
reg [7:0]  tx_data;
reg rx_read_en;



reg [7:0] expected [0:9];
integer i;
integer pass_count;
integer fail_count;


wire       tx;
wire       tx_busy;
wire       tx_done;

wire [7:0] rx_data;
wire       rx_valid;
wire       rx_busy;
wire [7:0] rx_fifo_data;
wire       rx_fifo_empty;
wire       rx_fifo_full;


// --------------------------------------------------
// UART TOP
// --------------------------------------------------

uart_top dut (
    .clk      (clk),
    .reset    (reset),

    .tx_start (tx_start),
    .tx_data  (tx_data),

    .tx       (tx),
    .tx_busy  (tx_busy),
    .tx_done  (tx_done),

    .rx_data  (rx_data),
    .rx_valid (rx_valid),
    .rx_busy  (rx_busy),
    .rx_read_en(rx_read_en),
    .rx_fifo_data(rx_fifo_data),
    .rx_fifo_empty(rx_fifo_empty),
    .rx_fifo_full(rx_fifo_full)
);


// --------------------------------------------------
// 50 MHz clock
// --------------------------------------------------

always #10 clk = ~clk;


// --------------------------------------------------
// Test
// --------------------------------------------------

initial begin

    clk      = 1'b0;
    reset    = 1'b1;
    tx_start = 1'b0;
    tx_data  = 8'h00;
    rx_read_en = 1'b0;
    expected[0] = 8'hB2;
expected[1] = 8'hA5;
expected[2] = 8'h11;
expected[3] = 8'h22;
expected[4] = 8'h33;
expected[5] = 8'h44;
expected[6] = 8'h55;
expected[7] = 8'h66;
expected[8] = 8'h77;
expected[9] = 8'h88;

pass_count = 0;
fail_count = 0;

    // Reset
    #100;

    reset = 1'b0;

    // Give the design some time after reset
    #100;

  // --------------------------------------------------
// SEND MULTIPLE BYTES
// --------------------------------------------------

// Send B2
tx_data  = 8'hB2;
tx_start = 1'b1;
#20;
tx_start = 1'b0;

#20;

// Send A5
tx_data  = 8'hA5;
tx_start = 1'b1;
#20;
tx_start = 1'b0;

#20;

// --------------------------------------------------
// SEND 8 BYTES
// --------------------------------------------------

tx_data = 8'h11;
tx_start = 1'b1;
#20;
tx_start = 1'b0;
#20;

tx_data = 8'h22;
tx_start = 1'b1;
#20;
tx_start = 1'b0;
#20;

tx_data = 8'h33;
tx_start = 1'b1;
#20;
tx_start = 1'b0;
#20;

tx_data = 8'h44;
tx_start = 1'b1;
#20;
tx_start = 1'b0;
#20;

tx_data = 8'h55;
tx_start = 1'b1;
#20;
tx_start = 1'b0;
#20;

tx_data = 8'h66;
tx_start = 1'b1;
#20;
tx_start = 1'b0;
#20;

tx_data = 8'h77;
tx_start = 1'b1;
#20;
tx_start = 1'b0;
#20;

tx_data = 8'h88;
tx_start = 1'b1;
#20;
tx_start = 1'b0;


// --------------------------------------------------
// WAIT FOR COMPLETE TX -> RX LOOPBACK
// --------------------------------------------------

#16000000;
// --------------------------------------------------
// AUTOMATIC RX FIFO VERIFICATION
// --------------------------------------------------

$display("\n====================================");
$display("       RX FIFO VERIFICATION");
$display("====================================");

for (i = 0; i < 10; i = i + 1) begin

    @(negedge clk);
    rx_read_en = 1'b1;

    @(negedge clk);
    rx_read_en = 1'b0;

    @(posedge clk);
    #1;

    if (rx_fifo_data === expected[i]) begin

        $display("PASS: BYTE %0d | Expected=%h | Received=%h",
                 i+1, expected[i], rx_fifo_data);

        pass_count = pass_count + 1;

    end
    else begin

        $display("FAIL: BYTE %0d | Expected=%h | Received=%h",
                 i+1, expected[i], rx_fifo_data);

        fail_count = fail_count + 1;

    end

end

$display("------------------------------------");
$display("TOTAL PASSED = %0d", pass_count);
$display("TOTAL FAILED = %0d", fail_count);
$display("------------------------------------");

if (fail_count == 0)
    $display("FINAL RESULT: ALL TESTS PASSED");
else
    $display("FINAL RESULT: VERIFICATION FAILED");

$display("RX FIFO EMPTY = %b", rx_fifo_empty);


$display("FIFO BYTE 7 = %h", rx_fifo_data);



    $display("--------------------------------------------------");
    $display("UART LOOPBACK TEST");
    $display("Transmitted data = %h", tx_data);
    $display("Received data    = %h", rx_data);
    $display("RX valid         = %b", rx_valid);
    $display("TX busy          = %b", tx_busy);
    $display("RX busy          = %b", rx_busy);
    $display("--------------------------------------------------");

    $finish;

end


// --------------------------------------------------
// Display received byte
// --------------------------------------------------

always @(posedge clk) begin

    if (rx_valid) begin
        $display("RX VALID! Received data = %h", rx_data);
    end

end
always @(posedge clk) begin

    if (dut.rx_fifo_rd_en) begin
        $display("!!! RX FIFO READ OCCURRED at %0t ns, data = %h, count = %d",
                 $time,
                 dut.rx_fifo_dout,
                 dut.rx_fifo.count);
    end

end
always @(posedge clk) begin

    if (dut.rx_fifo_wr_en) begin
        $display("!!! RX FIFO WRITE OCCURRED at %0t ns, data = %h, count = %d",
                 $time,
                 rx_data,
                 dut.rx_fifo.count);
    end

end
// --------------------------------------------------
// RX DEBUG
// --------------------------------------------------


always @(posedge clk) begin
    if (dut.rx_fifo_wr_en) begin
        $display("### RX FIFO WRITE: time=%0t, data=%h, count=%d",
                 $time,
                 dut.rx_data,
                 dut.rx_fifo.count);
    end
end
always @(posedge clk) begin
    if (rx_valid) begin
        $display("### RX VALID: time=%0t, data=%h",
                 $time,
                 rx_data);
    end
end



// --------------------------------------------------
// VCD waveform
// --------------------------------------------------

initial begin

    $dumpfile("uart_top.vcd");
    $dumpvars(0, tb_uart_top);

end

endmodule