module baud_gen_frac (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] phase_inc,
    output reg         baud_tick
);

reg  [31:0] phase_acc;
wire [32:0] phase_sum;

// Combinational phase addition
assign phase_sum = {1'b0, phase_acc} + {1'b0, phase_inc};

// Sequential accumulator
always @(posedge clk) begin

    if (reset) begin
        phase_acc <= 32'd0;
        baud_tick <= 1'b0;
    end

    else begin
        phase_acc <= phase_sum[31:0];
        baud_tick <= phase_sum[32];
    end

end

endmodule