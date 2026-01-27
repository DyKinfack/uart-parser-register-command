`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.01.2026 16:22:46
// Design Name: 
// Module Name: UART_TX_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module UART_TX_tb();
    reg clk;
    reg reset;
    reg TX_start;
    reg [7:0] TX_data;
    wire TX;
    wire q_busy;

    // DUT
    UART_TX dut(
        .clk(clk),
        .reset(reset),
        .TX_start(TX_start),
        .TX_data(TX_data),
        .TX(TX),
        .q_busy(q_busy)
    );

    // Clock: 50 MHz
    always #10 clk = ~clk;

    initial begin
        clk = 0;
        reset = 0;
        TX_start = 0;
        TX_data = 8'h00;

        // Reset
        #200;
        reset = 1;

        // Wait a bit
        #2000;

        // Wait until TX done
        wait(q_busy == 0);
        
        #2000;
        // Send byte 0xA5 = 10100101
        TX_data = 8'hA5;
        TX_start = 1;
        #20;
        TX_start = 0;
        
        #2000;
        // Wait until TX done
        wait(q_busy == 0);
        #2000;
        // Send another byte
        #200;
        TX_data = 8'h3C;
        TX_start = 1;
        #20;
        TX_start = 0;

        #300000 $stop;
    end
endmodule
