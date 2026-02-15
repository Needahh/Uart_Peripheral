// src/baud_gen.v
`default_nettype none

module baud_gen #(
    parameter CLKS_PER_BIT = 87 // Default for 100MHz clock / 115200 baud
)(
    input  wire       clk,
    input  wire       rst_n,
    output wire       baud_tick // High for one clock cycle
);

    reg [$clog2(CLKS_PER_BIT)-1:0] clk_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_cnt <= 0;
        end else begin
            if (clk_cnt == CLKS_PER_BIT - 1) begin
                clk_cnt <= 0;
            end else begin
                clk_cnt <= clk_cnt + 1;
            end
        end
    end

    // Pulse high when counter wraps around
    assign baud_tick = (clk_cnt == CLKS_PER_BIT - 1);

endmodule