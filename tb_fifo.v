
`timescale 1ns/1ps

module tb_fifo;

reg clk;
reg reset;

reg        wr_en;
reg        rd_en;
reg [7:0]  din;

wire [7:0] dout;
wire       full;
wire       empty;


// --------------------------------------------------
// FIFO DUT
// --------------------------------------------------

fifo #(
    .DATA_WIDTH(8),
    .DEPTH(16)
) dut (
    .clk   (clk),
    .reset (reset),

    .wr_en (wr_en),
    .rd_en (rd_en),
    .din   (din),

    .dout  (dout),
    .full  (full),
    .empty (empty)
);


// --------------------------------------------------
// 50 MHz clock
// --------------------------------------------------

always #10 clk = ~clk;


// --------------------------------------------------
// Test
// --------------------------------------------------

initial begin

    clk   = 1'b0;
    reset = 1'b1;

    wr_en = 1'b0;
    rd_en = 1'b0;
    din   = 8'h00;

    // Reset
    #100;

    reset = 1'b0;

    // ----------------------------------------------
    // WRITE A1
    // ----------------------------------------------

    @(negedge clk);
    din   = 8'hA1;
    wr_en = 1'b1;

    @(posedge clk);
    #1;

    wr_en = 1'b0;

    $display("FIFO WRITE: %h", 8'hA1);


    // ----------------------------------------------
    // WRITE B2
    // ----------------------------------------------

    @(negedge clk);
    din   = 8'hB2;
    wr_en = 1'b1;

    @(posedge clk);
    #1;

    wr_en = 1'b0;

    $display("FIFO WRITE: %h", 8'hB2);


    // ----------------------------------------------
    // WRITE C3
    // ----------------------------------------------

    @(negedge clk);
    din   = 8'hC3;
    wr_en = 1'b1;

    @(posedge clk);
    #1;

    wr_en = 1'b0;

    $display("FIFO WRITE: %h", 8'hC3);


    // ----------------------------------------------
    // WRITE D4
    // ----------------------------------------------

    @(negedge clk);
    din   = 8'hD4;
    wr_en = 1'b1;

    @(posedge clk);
    #1;

    wr_en = 1'b0;

    $display("FIFO WRITE: %h", 8'hD4);


    // ----------------------------------------------
    // READ 1
    // ----------------------------------------------

    @(negedge clk);
    rd_en = 1'b1;

    @(posedge clk);
    #1;

    rd_en = 1'b0;

    $display("FIFO READ:  %h", dout);


    // ----------------------------------------------
    // READ 2
    // ----------------------------------------------

    @(negedge clk);
    rd_en = 1'b1;

    @(posedge clk);
    #1;

    rd_en = 1'b0;

    $display("FIFO READ:  %h", dout);


    // ----------------------------------------------
    // READ 3
    // ----------------------------------------------

    @(negedge clk);
    rd_en = 1'b1;

    @(posedge clk);
    #1;

    rd_en = 1'b0;

    $display("FIFO READ:  %h", dout);


    // ----------------------------------------------
    // READ 4
    // ----------------------------------------------

    @(negedge clk);
    rd_en = 1'b1;

    @(posedge clk);
    #1;

    rd_en = 1'b0;

    $display("FIFO READ:  %h", dout);


    #100;

    $finish;

end


// --------------------------------------------------
// Waveform
// --------------------------------------------------

initial begin

    $dumpfile("fifo.vcd");
    $dumpvars(0, tb_fifo);

end

endmodule