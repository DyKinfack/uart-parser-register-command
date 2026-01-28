`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dylann Kinfack
// 
// Create Date: 26.01.2026 21:30:16
// Design Name: Register File
// Module Name: register_file
// Project Name:  UART Command Parser & Register File (FPGA / Verilog)
// Target Devices: Spartan-7
// Tool Versions: Vivado 2020.2
// Description: Features:
// Independent read/write addressing
// Status signal generation
// TX trigger generation for read operations

// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module register_file(
    input clk,
    input reset,
    input we,
    input re,
    input  [7:0] w_data,
    input  [7:0] w_addr,
    input  [7:0] r_addr,
    output reg [7:0] r_data,
    output reg adress_status,
    output  TX_start
    );
    
    reg start;
    reg status;
    reg [7:0] ram[0:63];
    integer i;
    
    reg [5:0] addr;
    reg [7:0] data;
    always @(posedge clk) begin
        if(!reset) begin
            for( i = 0; i < 64; i = i+1)
              ram[i] <= 8'b0;
           
           r_data <= 8'b0;
           adress_status <= 1'b0;
           start <=0;
           addr <=0;
           data <=0;
             
        end
        
        else begin
            adress_status <= 1'b0;
            
            // write operation
            if( we ) 
            begin
                addr <= w_addr;
                data <= w_data;
                if( addr < 'd64 ) 
                begin
                   ram[addr] <= data;
                   adress_status <= 1'b1;
                end
                else
                   adress_status <= 1'b0;
            end
            
            
            
            if( re ) 
            begin
             addr <= r_addr;
                if(addr < 'd64 )
                 begin
                    r_data <= ram[addr];
                    adress_status <= 1'b1;
                    start <= 1'b1;
                    
                 end
            
                else 
                begin
                   adress_status <= 1'b0;
                   start <= 1'b0;
                 end
           end
           else
             start <= 1'b0;
                     
        end     
    end
    
  
       assign  TX_start = start;
endmodule
