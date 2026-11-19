module baud_gen_frac_opt (
    input  wire        clk,
    input  wire        reset,
    input  wire [23:0] phase_inc,
    output reg         baud_tick
);

reg [23:0] phase_acc;
reg [24:0] phase_sum;

always @(posedge clk) begin

    if (reset) begin
        phase_acc <= 24'd0;
        baud_tick <= 1'b0;
    end

    else begin
        phase_sum = phase_acc + phase_inc;

        phase_acc <= phase_sum[23:0];
        baud_tick <= phase_sum[24];
    end

end

endmodule