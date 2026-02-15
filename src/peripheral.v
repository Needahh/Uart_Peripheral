/*
 * Copyright (c) 2025 Suliat Saka(zul)
 * SPDX-License-Identifier: Apache-2.0
 */

//peripheral.v

`default_nettype none

module tqvp_zul_uart (
    input         clk,
    input         rst_n,

    input  [7:0]  ui_in,   // ui_in[7] is UART RX
    output [7:0]  uo_out,  // uo_out[0] is UART TX

    input  [5:0]  address,
    input  [31:0] data_in,

    input  [1:0]  data_write_n,
    input  [1:0]  data_read_n,
    
    output [31:0] data_out,
    output        data_ready,

    output        user_interrupt
);

    // Baud rate generator parameter (Example: 64MHz / 115200 baud = ~555)
    parameter CLKS_PER_BIT = 555; 

    wire baud_tick;
    wire tx_busy;
    wire rx_data_valid;
    wire [7:0] rx_data;
    
    reg tx_valid_reg;
    reg rx_data_read_reg;
    reg interrupt_reg;

    // 1. Instantiate Baud Generator
    baud_gen #(.CLKS_PER_BIT(CLKS_PER_BIT)) i_baud_gen (
        .clk(clk),
        .rst_n(rst_n),
        .baud_tick(baud_tick)
    );

    // 2. Instantiate Transmitter
    uart_tx i_uart_tx (
        .clk(clk),
        .rst_n(rst_n),
        .baud_tick(baud_tick),
        .data_in(data_in[7:0]),
        .data_valid(tx_valid_reg),
        .tx_pin(uo_out[0]),
        .busy(tx_busy)
    );

    // 3. Instantiate Receiver
    uart_rx i_uart_rx (
        .clk(clk),
        .rst_n(rst_n),
        .baud_tick(baud_tick),
        .rx_pin(ui_in[7]),
        .data_out(rx_data),
        .data_valid(rx_data_valid)
    );

    // 4. Register and Interfacing Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_valid_reg <= 1'b0;
            interrupt_reg <= 1'b0;
        end else begin
            // Trigger TX
            if (address == 6'h0 && data_write_n != 2'b11) begin
                tx_valid_reg <= 1'b1;
            end else begin
                tx_valid_reg <= 1'b0;
            end

            // Handle Interrupt and Received Data
            if (rx_data_valid) begin
                interrupt_reg <= 1'b1;
            end else if (address == 6'h4 && data_read_n != 2'b11) begin
                interrupt_reg <= 1'b0; // Clear interrupt on read
            end
        end
    end

    // 5. Data Out Mapping
    assign data_out = (address == 6'h0) ? {31'b0, tx_busy} :
                      (address == 6'h4) ? {24'b0, rx_data} :
                      32'h0;
    
    assign data_ready = 1'b1;
    assign user_interrupt = interrupt_reg;

    // Drive unused outputs
    assign uo_out[7:1] = 7'b0;

    // Unused inputs
    wire _unused = &{data_read_n, ui_in[6:0], 1'b0};

endmodule