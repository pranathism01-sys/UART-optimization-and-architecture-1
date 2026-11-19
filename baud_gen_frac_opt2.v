module baud_gen_frac_opt2 (
    input  wire        clk,
    input  wire        reset,
    input  wire [23:0] phase_inc,
    output reg         baud_tick
);

reg [23:0] phase_acc;

always @(posedge clk) begin
    if (reset) begin
        phase_acc <= 24'd0;
        baud_tick <= 1'b0;
    end
    else begin
        {baud_tick, phase_acc} <= {1'b0, phase_acc} + {1'b0, phase_inc};
    end
end

endmodule