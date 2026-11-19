module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16
)(
    input  wire                  clk,
    input  wire                  reset,

    input  wire                  wr_en,
    input  wire                  rd_en,
    input  wire [DATA_WIDTH-1:0] din,

    output reg  [DATA_WIDTH-1:0] dout,
    output wire                  full,
    output wire                  empty
);

reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

reg [3:0] wr_ptr;
reg [3:0] rd_ptr;
reg [4:0] count;


// Write pointer
always @(posedge clk) begin

    if (reset) begin
        wr_ptr <= 4'd0;
    end

    else if (wr_en && !full) begin
        mem[wr_ptr] <= din;
        wr_ptr <= wr_ptr + 4'd1;
    end

end


// Read pointer and output
always @(posedge clk) begin

    if (reset) begin
        rd_ptr <= 4'd0;
        dout   <= 8'd0;
    end

    else if (rd_en && !empty) begin
        dout <= mem[rd_ptr];
        rd_ptr <= rd_ptr + 4'd1;
    end

end


// FIFO count
always @(posedge clk) begin

    if (reset) begin
        count <= 5'd0;
    end

    else begin

        case ({wr_en && !full, rd_en && !empty})

            2'b10: count <= count + 5'd1;

            2'b01: count <= count - 5'd1;

            default: count <= count;

        endcase

    end

end


assign full  = (count == DEPTH);
assign empty = (count == 0);

endmodule
