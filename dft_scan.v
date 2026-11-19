module dft_scan (
    input  wire        clk,
    input  wire        reset,

    input  wire        test_mode,

    input  wire        scan_in,
    output wire        scan_out,

    input  wire [15:0] parallel_in,
    output wire [15:0] parallel_out,

    // DFT fault injection
    input  wire        fault_enable,
    input  wire [3:0]  fault_bit,
    input  wire        fault_value
);

reg [15:0] scan_reg;

always @(posedge clk) begin

    if (reset) begin
        scan_reg <= 16'd0;
    end

    else if (test_mode) begin

        // Normal scan shift
        scan_reg <= {scan_reg[14:0], scan_in};

        // Inject selected stuck-at fault
        if (fault_enable)
            scan_reg[fault_bit] <= fault_value;

    end

    else begin

        // Parallel capture
        scan_reg <= parallel_in;

    end

end

assign scan_out     = scan_reg[15];
assign parallel_out = scan_reg;

endmodule