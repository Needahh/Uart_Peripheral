//uart_rx.v
`default_nettype none

module uart_rx (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       baud_tick, // Pulsed high by baud_gen
    input  wire       rx_pin,
    output reg  [7:0] data_out,
    output reg        data_valid
);

    // FSM States
    localparam STATE_IDLE  = 2'b00;
    localparam STATE_START = 2'b01;
    localparam STATE_DATA  = 2'b10;
    localparam STATE_STOP  = 2'b11;

    reg [1:0] state;
    reg [2:0] bit_idx;
    reg [7:0] shift_reg;
    reg       rx_sync;

    // Synchronize RX pin to local clock to prevent metastability
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) rx_sync <= 1'b1;
        else        rx_sync <= rx_pin;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= STATE_IDLE;
            data_out   <= 8'h00;
            data_valid <= 1'b0;
            bit_idx    <= 0;
            shift_reg  <= 8'h00;
        end else begin
            // Only act when the baud generator tells us to
            if (baud_tick) begin
                case (state)
                    STATE_IDLE: begin
                        data_valid <= 1'b0;
                        bit_idx    <= 0;
                        if (rx_sync == 1'b0) begin // Start bit detected
                            state <= STATE_START;
                        end
                    end

                    STATE_START: begin
                        // In the start state, we are waiting for the middle of 
                        // the start bit. Since the baud_tick happens at the
                        // edge, we need to wait another 1/2 bit period ideally,
                        // but skipping straight to data sampling works if 
                        // synchronized properly.
                        if (rx_sync == 1'b0) begin
                            state <= STATE_DATA;
                        end else begin
                            state <= STATE_IDLE; // False start
                        end
                    end

                    STATE_DATA: begin
                        shift_reg[bit_idx] <= rx_sync; // Sample data bit
                        if (bit_idx < 7) begin
                            bit_idx <= bit_idx + 1;
                        end else begin
                            bit_idx <= 0;
                            state   <= STATE_STOP;
                        end
                    end

                    STATE_STOP: begin
                        // Stop bit
                        data_out   <= shift_reg;
                        data_valid <= 1'b1; // Data is ready
                        state      <= STATE_IDLE;
                    end
                    
                    default: state <= STATE_IDLE;
                endcase
            end
        end
    end
endmodule