`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.01.2026 19:35:06
// Design Name: UART RX Testbench
// Module Name: UART_RX_tb
// Project Name: UART Command Parser & Register File (FPGA / Verilog)
// Target Devices: Spartan-7
// Tool Versions: Vivado 2020.2
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module UART_RX_tb();
    
    reg clk;
    reg rx;
    reg reset;
    wire [7:0] rx_data; 
    wire rx_valid;
    
    UART_RX RX_tb2(.rx_data(rx_data), .rx_valid(rx_valid), .clk(clk), .reset(reset), .rx(rx));
    
    always #10 clk = ~clk; //Clock generation
    
    // -----------------------------
    // UART parameters must equal to UART Design
    // -----------------------------
    localparam CLK_FREQ   = 50_000_000;
    localparam BAUDRATE   = 300000;
    localparam OVERSAMPLE = 16;

    localparam BAUD_TICK_FREQ = BAUDRATE * OVERSAMPLE;
    localparam BAUD_TICKS     = CLK_FREQ / BAUD_TICK_FREQ; // = 10
    localparam BIT_CLKS       = BAUD_TICKS * OVERSAMPLE;   // = 208
    
    task uart_send_byte(input [7:0] data);
        integer i;
        begin
            // START bit
            rx=0;
            
            #(BIT_CLKS*20);
            
             // DATA bits (LSB first)
             for(i=0; i<8; i=i+1)
             begin
                rx=data[i];
                #(BIT_CLKS*20);
             end
             
            // STOP bit
            rx = 1;
            #(BIT_CLKS * 20);   
             
        end
     endtask
    
    // -----------------------------
    // Test sequence
    // -----------------------------
    //reg [3:0]i;
    // reg [7:0] data=8'hAA;
    
    initial
    begin
        $monitor("time=%d \t Data Recieved RX_DATA =%h \t rx_valid=%b",$time, rx_data, rx_valid);
        clk   = 0;
        rx    = 1;   // UART IDLE = HIGH
        reset = 0;

        // Reset
        #1000;
        reset = 1;
        #1000;
        reset=0;
        #1000;
        reset=1;
        
        // Kleine Pause
        #(BIT_CLKS * 20);

        // Sende 0x55 = 01010101
        uart_send_byte(8'h23);

        // Warte auf rx_valid
        wait(rx_valid);

        
        #1000;
        $stop;
    end
 
 
endmodule

// -----------------------------
    // UART transmit task
    // -----------------------------
    
