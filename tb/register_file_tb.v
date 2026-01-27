`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dylann Kinfack
// 
// Create Date: 26.01.2026 22:05:36
// Design Name: Register File
// Module Name: register_file_tb
// Project Name: UART Command Parser & Register File (FPGA / Verilog)
// Target Devices: Spartan-7
// Tool Versions: Vivado 2020.2
// Description: Verifies register write/read functionality
// Confirms address decoding
// Validates output data consistency
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module register_file_tb();

     reg clk;
    reg reset;
    reg we;
    reg re;
    reg [7:0] w_data;
    reg [7:0] w_addr;
    reg [7:0] r_addr;

    wire [7:0] r_data;
    wire adress_status;
    wire TX_start;
    // DUT
    register_file dut (
        .clk(clk),
        .reset(reset),
        .we(we),
        .re(re),
        .w_data(w_data),
        .w_addr(w_addr),
        .r_addr(r_addr),
        .r_data(r_data),
        .adress_status(adress_status),
        .TX_start(TX_start)
    );

    // Clock: 10ns period
    always #5 clk = ~clk;

    initial begin
        // Init
        clk = 0;
        reset = 0;
        we = 0;
        re = 0;
        w_data = 0;
        w_addr = 0;
        r_addr = 0;

        // RESET
        #10;
        reset = 1;
        #10;

        // WRITE register 5 = 0xAB
        we = 1;
        w_addr = 6'd5;
        w_data = 8'hAB;
        #10;
        we = 0;

        // READ register 5
        #10
        re = 1;
        r_addr = 6'd5;
        #10;
        re = 0;

        // INVALID WRITE (addr 70)
        #10;
        we = 1;
        w_addr = 8'd70;
        w_data = 8'hFF;
        #10;
        we = 0;

        // INVALID READ
        #10;
        re = 1;
        r_addr = 8'd70;
        #10;
        re = 0;

        // END
        #400;
        $finish;
    end
endmodule
