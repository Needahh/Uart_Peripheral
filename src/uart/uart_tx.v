//uart_tx.v
`default_nettype none

module uart_tx (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       baud_tick, // Pulsed high by baud_gen
    input  wire [7:0] data_in,
    input  wire       data_valid,
    output reg        tx_pin,
    output reg        busy
);

    // FSM States
    localparam STATE_IDLE  = 2'b00;
    localparam STATE_START = 2'b01;
    localparam STATE_DATA  = 2'b10;
    localparam STATE_STOP  = 2'b11;

    reg [1:0] state;
    reg [2:0] bit_idx;
    reg [7:0] data_buf;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= STATE_IDLE;
            tx_pin   <= 1'b1; // Idle line high
            busy     <= 1'b0;
            bit_idx  <= 0;
            data_buf <= 8'h00;
        end else begin
            // Only act when the baud generator tells us to
            if (baud_tick) begin
                case (state)
                    STATE_IDLE: begin
                        busy   <= 1'b0;
                        bit_idx <= 0;
                        if (data_valid) begin
                            data_buf <= data_in;
                            busy     <= 1'b1;
                            state    <= STATE_START;
                        end else begin
                            tx_pin <= 1'b1; // Keep line high
                        end
                    end

                    STATE_START: begin
                        tx_pin <= 1'b0; // Start bit
                        state  <= STATE_DATA;
                    end

                    STATE_DATA: begin
                        tx_pin <= data_buf[bit_idx]; // LSB First
                        if (bit_idx < 7) begin
                            bit_idx <= bit_idx + 1;
                        end else begin
                            bit_idx <= 0;
                            state   <= STATE_STOP;
                        end
                    end

                    STATE_STOP: begin
                        tx_pin <= 1'b1; // Stop bit
                        state  <= STATE_IDLE;
                    end
                    
                    default: state <= STATE_IDLE;
                endcase
            end
        end
    end
endmodule