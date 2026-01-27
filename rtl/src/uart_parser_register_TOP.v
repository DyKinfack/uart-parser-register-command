`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dylann Kinfack
// 
// Create Date: 26.01.2026 22:52:30
// Design Name: uart_parser_register_TOP
// Module Name: uart_parser_register_TOP
// Project Name: UART Command Parser & Register File (FPGA / Verilog)
// Target Devices: Spartan-7
// Tool Versions: Vivado 2020.2
// Description: Top-level module integrating all submodules.
// Connect UART RX ? parser ? register file ? UART TX
// Provide clean system-level interfaces

// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_parser_register_TOP(
    input clk,
    input reset,
    input RX,
    output TX,
    output busy
    );
    
    wire  [7:0] rx_data;
    wire rx_valid;
    
    UART_RX uart_rx(
                    .clk(clk),
                    .reset(reset),
                    .rx(RX),
                    .rx_valid(rx_valid),
                    .rx_data(rx_data));
   
   wire reg_we; wire reg_re; 
   wire [5:0] r_addr; wire [5:0] w_addr; 
   wire [7:0] w_data;
   cmd_parser parser(
                    .clk(clk),
                    .reset(reset),
                    .rx_valid(rx_valid),
                    .rx_data(rx_data),
                    .reg_we(reg_we),
                    .reg_re(reg_re),
                    .r_addr(r_addr),
                    .w_addr(w_addr),
                    .w_data(w_data));
    
    wire [7:0] r_data; 
    wire status;  
    wire TX_start;         
    register_file reg_file(
                     .clk(clk),
                     .reset(reset),
                     .we(reg_we),
                     .re(reg_re),
                     .w_addr(w_addr),
                     .r_addr(r_addr),
                     .w_data(w_data),
                     .r_data(r_data),
                     .adress_status(status),
                     .TX_start(TX_start)
                     );   
    
    
    UART_TX uart_tx(
                    .clk(clk),
                    .reset(reset),
                    .TX_start(TX_start),
                    .TX_data(r_data),
                    .TX(TX),
                    .q_busy(busy)
                    );
                                
endmodule
