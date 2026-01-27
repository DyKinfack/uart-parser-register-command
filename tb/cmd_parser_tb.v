`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.01.2026 20:56:32
// Design Name: uart_parser_register_TOP
// Module Name: cmd_parser_tb
// Project Name: ART Command Parser & Register File (FPGA / Verilog)
// Target Devices: Spartan-7
// Tool Versions: Vivado 2020.2
// Description: Verifies FSM behavior. Ensures correct command decoding. Checks correct generation of control signals
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cmd_parser_tb();

    reg clk;
    reg reset;
    reg rx_valid;
    reg [7:0] rx_data;

    wire reg_we;
    wire reg_re;
    wire [5:0] r_addr;
    wire [5:0] w_addr;

    // DUT
    cmd_parser dut (
        .clk(clk),
        .reset(reset),
        .rx_valid(rx_valid),
        .rx_data(rx_data),
        .reg_we(reg_we),
        .reg_re(reg_re),
        .r_addr(r_addr),
        .w_addr(w_addr)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    // Helper task: send one UART byte
    task send_byte(input [7:0] byte);
    begin
        rx_data  = byte;
        rx_valid = 1;
        #10;
        rx_valid = 0;
        #20;   // Abstand zwischen Bytes
    end
    endtask

    initial begin
        // Init
        clk = 0;
        reset = 0;
        rx_valid = 0;
        rx_data = 8'h00;

        // Reset
        #50;
        reset = 1;
        #50;

        // ============================
        // TEST 1: WRITE Command
        // CMD = 0x80 (WRITE)
        // ADDR = 0x05
        // DATA = 0xAA
        // ============================
        $display("---- WRITE COMMAND ----");
        send_byte(8'h80);   // CMD (WRITE)
        send_byte(8'h05);   // ADDR
        send_byte(8'hAA);   // DATA

        #100;

        // ============================
        // TEST 2: READ Command
        // CMD = 0x00 (READ)
        // ADDR = 0x12
        // ============================
        $display("---- READ COMMAND ----");
        send_byte(8'h00);   // CMD (READ)
        send_byte(8'h12);    // ADDR
       

        #200;

        $stop;
    end

    // Debug Monitoring
    always @(posedge clk) begin
        $display("t=%0t state=%b rx_valid=%b rx_data=%h reg_we=%b reg_re=%b addr_w=%d addr_r=%d",
                 $time,
                 dut.state,
                 rx_valid,
                 rx_data,
                 reg_we,
                 reg_re,
                 w_addr,
                 r_addr);
    end
endmodule
