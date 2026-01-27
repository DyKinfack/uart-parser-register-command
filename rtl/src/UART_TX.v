`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dylann Kinfack
// 
// Create Date: 05.12.2025 14:08:23
// Design Name: uart-fpga-command-processor
// Module Name: UART_TX
// Project Name: uart-fpga-command-processor
// Target Devices: Spartan-7
// Tool Versions: Vivado 202.2
// Description: 
// EN:
// UART transmitter implementing an FSM-based control 
// with parameterizable baud rate and synchronized start detection. 
// Transmits serial frames including start, data and stop bits.
// DE:
// UART-Sender mit FSM-basierter Steuerung, 
// parametrisierbarer Baudrate und synchronisiertem Startsignal. 
// Sendet serielle Frames (Startbit, 8 Datenbits, Stopbit).
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module UART_TX(
    input clk,
    input reset,
    input TX_start,
    input [7:0] TX_data,
    output q_busy,
    output TX
    );
    
    //time base generation
    parameter BAUDRATE= 5000000;
    parameter CLK_FREQ=50000000;
    parameter CYCLES=CLK_FREQ/BAUDRATE;
    
    wire enable;
    time_base_generation #(.CYCLES(CYCLES)) baud_generation(.clk(clk), .reset(reset), .q(enable));
    
    //State Definition
    parameter RESET=3'b000,
              IDLE =3'b001,
              START=3'b010,
              SEND =3'b011,
              DONE =3'b100;
              
    reg [2:0] state, next_state;
    
    parameter UART_FRAME_SIZE=10;
    
    // START Request by a single  LOW to HIGH by Tx_start
    reg [1:0] syn_reg;
    wire start_request;
    always @(posedge clk)
        if(!reset)
            syn_reg<=2'b00;
        else
            syn_reg<={syn_reg[0], TX_start};
            
    assign start_request = (syn_reg == 2'b01) ? 1'b1 : 1'b0;
    
    // INTERNAL START DETECTION - START REQUEST ARE ONLY ACCEPTED IN IDLE STATE
    reg start_request_detected =1'b0;
    always @(posedge clk)
        if(!reset)
            start_request_detected <=0;
        else if(state == DONE || state == SEND)
            start_request_detected <=0;
        else if(state ==IDLE && ~start_request_detected)
            start_request_detected <= start_request;
            
     function [7:0] uart_bit_swap (
		 input [7:0] data
		);
		integer i;
		begin
			for (i=0; i < 8; i=i+1) begin : reverse_bits
				uart_bit_swap[7-i] = data[i]; 	
			end
		end
	endfunction
            
    // OUTPUT shift Register
    wire STOP_BIT; assign STOP_BIT  = 1'b1;
    wire START_BIT; assign START_BIT = 1'b0;
    wire [7:0] TXD_DATA; assign TXD_DATA = uart_bit_swap(TX_data);
    
    wire txd_shift_reg_en; wire txd_shift_reg_init;
    assign txd_shift_reg_en = (state == SEND) & enable;
    assign txd_shift_reg_init = start_request & ~start_request_detected;
    
    reg [9:0] txd_shift_reg =0;
    
    always @(posedge clk)
        if(!reset)
            txd_shift_reg <=10'b1111111111;
        else if(txd_shift_reg_init)
            txd_shift_reg <= {STOP_BIT, START_BIT, TXD_DATA};
        else if(txd_shift_reg_en)
            txd_shift_reg <= {txd_shift_reg[8:0], STOP_BIT};
    
    assign TX = txd_shift_reg[9];
    
    //FSM IMPLEMENTATION STATE
    always @(posedge clk)
        if(!reset)
            state <= RESET;
        else if(enable)
            state <= next_state;
             
    // SM IMPLEMENTATION: STATE COUNTER
	reg [3:0] bits_transmitted = 0;
	always @(posedge clk)
		if(!reset)
			bits_transmitted <= 0;
		else if(enable)
			begin
				if(state == SEND)
					bits_transmitted <= bits_transmitted + 1'b1;
				else
					bits_transmitted <= 0;
			end
    
    //NEXT STATE LOGIC
    always @(*)
    begin
        next_state = state;  
        case(state)
            RESET: begin
                next_state=IDLE;
                end
            IDLE: begin
                if(start_request_detected)
                    next_state = SEND;
                  end
            SEND: begin
                if(bits_transmitted != (UART_FRAME_SIZE - 1))
                    next_state = SEND;
                else
                    next_state = DONE;
                   end
            DONE:
                next_state = IDLE;
        endcase         
    end 
    
    assign q_busy = (state == IDLE || state == RESET) ? 1'b0 : 1'b1;
    
endmodule




module time_base_generation #(parameter CYCLES=50000)(
            input clk,
            input reset,
            output q);
            
  localparam BITWIDTH = $clog2(CYCLES);
  
  reg [BITWIDTH-1:0] time_base_counter ='d0;
  always @(posedge clk)
    if(!reset)
        time_base_counter <='d0;
    else 
    begin
        if(time_base_counter == CYCLES -1)
            time_base_counter <='d0;
        else
             time_base_counter<=time_base_counter +1;
    end
        
  assign q=(time_base_counter==(CYCLES -1))?1'b1:1'b0;
       
endmodule
                                            