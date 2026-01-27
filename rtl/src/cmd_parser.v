`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dylann Kinfack
// 
// Create Date: 26.01.2026 19:30:28
// Design Name: Command Parser
// Module Name: cmd_parser
// Project Name: UART Command Parser & Register File (FPGA / Verilog)
// Target Devices: Spartan-7 Board xc7s6ftgb196-1
// Tool Versions: Vivado 2020.2
// Description: Finite State Machine (FSM) that decodes UART commands.
// Supported commands:
// WRITE: write data to a register
//READ: read data from a register
// Outputs: reg_we, reg_re, w_addr, r_addr, w_data
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cmd_parser(
    input clk,
    input reset,
    input rx_valid,
    input [7:0] rx_data,
    output reg reg_we,
    output reg reg_re,
    output reg [5:0] r_addr,
    output reg [5:0] w_addr,
    output reg [7:0] w_data
    );
    
    // state Definition
    parameter 
            IDLE = 3'b000,
            CMD_BYTE =3'b001,
            ADDR_BYTE = 3'b010,
            DATA_BYTE = 3'b011,
            EXECUTE = 3'b100,
            RESP_TX = 3'b101;
   
   reg [2:0] state, next_state;
   
   // data path variabble
   reg [7:0] cmd; // read/write cmd[7] remain Bits reserved [6:0]
   
   // ====================
   // state Register logic
   // =====================
   always @(posedge clk) begin
        if(!reset)
            state <= IDLE;
        else
            state <= next_state;
   end
   
    // =================
   // next state logic
   // ==================
   always @(*) begin
        
        next_state <= state; // Default state
        
        case(state)
            IDLE: begin
                if(rx_valid)
                    next_state <= CMD_BYTE;
                else
                    next_state <= IDLE;
            end
            
            CMD_BYTE: begin
                if(rx_valid)
                    next_state <= ADDR_BYTE;
                else
                    next_state <= CMD_BYTE;
            end
            
            ADDR_BYTE: begin // from ADDR_BYTE to DATA_BYTE only by write command 
                if(cmd[7]) begin
                    if(rx_valid)
                        next_state <= DATA_BYTE;
                    else
                        next_state <= ADDR_BYTE;
                end
               else
                   next_state <= EXECUTE;
            end
            
            DATA_BYTE: begin
                 next_state <= EXECUTE;
            end
            
            EXECUTE: 
            begin
                 if(reg_we==1 || reg_re==1)
                    next_state <= RESP_TX;
                 else
                    next_state <= EXECUTE;
            end
            
            RESP_TX: begin
                next_state <= IDLE;
            end
        endcase
   end
    
   
    reg [1:0] counter;
    always @(posedge clk) begin
        if(!reset) begin
           cmd <= 0;
           w_addr <= 0;
           r_addr <= 0;
           w_data <= 0;
           reg_we <= 0;
           reg_re <= 0; 
           counter <=0;   
        end
        
        else 
        begin
            // defaults
            reg_we <= 0;
            reg_re <= 0;
             
            case(state)
                IDLE: begin
                   cmd <= 0;
                   w_addr <= 0;
                   r_addr <= 0;
                   w_data <= 0;
                   reg_we <= 0;
                   reg_re <= 0; 
                   counter <=0;  
                end
                
                CMD_BYTE: begin
                     if(counter == 0) begin
                        cmd <= rx_data; 
                        counter <= counter +1; 
                       end
                 end
                 
                 ADDR_BYTE: begin
                    if(counter == 1) begin
                        w_addr <= rx_data[5:0];
                        r_addr <= rx_data[5:0];
                        counter <= counter +1;
                      end      
                 end  
                 
                 DATA_BYTE: begin
                        if(counter == 2) begin
                            w_data <= rx_data;
                            counter <= counter +1;
                        end
                 end
                 
                 EXECUTE: 
                 begin
                    if(cmd[7])
                        reg_we <= 1; // WRITE
                    else
                        reg_re <= 1'b1; // READ
                 end 
                 
            endcase
        end
    end
endmodule
