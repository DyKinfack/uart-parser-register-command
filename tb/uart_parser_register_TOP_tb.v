`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dylann Kinfack
// 
// Create Date: 27.01.2026 10:23:51
// Design Name:  uart_parser_register_TOP
// Module Name: uart_parser_register_TOP_tb
// Project Name: UART Command Parser & Register File (FPGA / Verilog)
// Target Devices: Spartan-7 
// Tool Versions: Vivado 2020.2
// Description: Full system-level verification
// UART stimulus generation (bit-accurate)
// End-to-end write & read command testing

// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_parser_register_TOP_tb();


 reg clk;
    reg reset;
    reg rx;
    wire TX;
    wire busy;

    uart_parser_register_TOP dut(
        .clk(clk),
        .reset(reset),
        .RX(rx),
        .TX(TX),
        .busy(busy)
    );

    // ====================
    // Clock: 50 MHz
    // ====================
    always #10 clk = ~clk;

     // -----------------------------
    // UART parameters must equal to UART Design
    // -----------------------------
    localparam CLK_FREQ   = 50_000_000;
    localparam BAUDRATE   = 115200;
    localparam OVERSAMPLE = 16;

    localparam BAUD_TICK_FREQ = BAUDRATE * OVERSAMPLE;
    localparam BAUD_TICKS     = CLK_FREQ / BAUD_TICK_FREQ; // = 10
    localparam BIT_CLKS       = BAUD_TICKS * OVERSAMPLE;   // = 208

    // ====================
    // UART SEND TASK
    // ====================
    task uart_send_byte(input [7:0] data);
        integer i;
        begin
            // START bit
            rx = 0;
            #(BIT_CLKS*20);

            // DATA bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #(BIT_CLKS*20);
            end

            // STOP bit
            rx = 1;
            #(BIT_CLKS*20);
        end
    endtask

    // ====================
    // Monitor RX bytes
    // ====================
    always @(posedge clk)
        if (dut.uart_rx.rx_valid)
            $display("t=%0t RX_BYTE = %h", $time, dut.uart_rx.rx_data);

    // ====================
    // TEST SEQUENCE
    // ====================
    initial begin
        clk = 0;
        rx  = 1;
        reset = 0;

        // Reset
        #2000;
        reset = 1;
        #2000;

        // -------------------------
        // WRITE: Reg[5] = 0xAA
        // -------------------------
        $display("\n--- WRITE COMMAND ---");
        uart_send_byte(8'h80); // WRITE
        uart_send_byte(8'h05); // ADDR
        uart_send_byte(8'hAA); // DATA

        // wait for write
        #50000;

        // -------------------------
        // READ: Reg[5]
        // -------------------------
        $display("\n--- READ COMMAND ---");
        uart_send_byte(8'h00); // READ
        uart_send_byte(8'h05); // ADDR
       
        // wait for TX
        wait(busy == 1);
        wait(busy == 0);

        #400;

        $display("\nTEST DONE");
        $stop;
    end

endmodule
