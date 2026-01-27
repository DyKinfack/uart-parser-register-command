`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dylann Kinfack
// 
// Create Date: 05.12.2025 23:31:43
// Design Name: uart-register file-command-processor
// Module Name: UART_RX
// Project Name: uart-fpga-command-processor
// Target Devices: Spartan-7
// Tool Versions: Vivado 2020.2
// Description: 
//  EN: UART receiver using 16× baud rate oversampling, start-bit detection, and synchronized RX input to prevent metastability.
//  
//  DE: UART-Empfänger mit Oversampling (16× Baudrate), Startbit-Erkennung und synchronisierter RX-Leitung zur Vermeidung von Metastabilität.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module UART_RX(
    input clk,
    input reset,
    input rx,
    output reg [7:0] rx_data,
    output reg rx_valid
    );
    
   // Recieve rx Synchronisation. rx ist asynchron direkte Nutzung für zu Metastabilität
   reg rx_synch1;
   reg rx_synch2;
   always @(posedge clk)
    begin
        rx_synch1 <= rx;
        rx_synch2<= rx_synch1;
    end
    
    // Baud-Tick /Zeitbasis
    // time base generation
    parameter BAUDRATE= 115200*16;
    parameter CLK_FREQ=50000000;
    parameter CYCLES=CLK_FREQ/BAUDRATE; //27
    
    wire baud_tick;
    reg [4:0] counter;
    
    always @(posedge clk)
    begin
    if(!reset)
        counter <= 5'b0;
    else
        if(counter == CYCLES-1) //zählt bis 26 dann wieder auf 0
            counter <=5'd0;
        else
            counter <= counter +1;
           
    end
    assign baud_tick = (counter == CYCLES-1)?1'b1:1'b0;
    
    
    //FSM Logic
    
    parameter
    IDLE =3'b000, 
    START=3'b001, 
    DATA=3'b010, 
    STOP=3'b011, 
    DONE=3'b100; // state of FSM
    
    reg [2:0] state;
    reg [2:0] next_state;
    reg [7:0] bit_time;
    reg [2:0] pos;
    reg [3:0] read_count;
   
   // actualy state Logic
   always @(posedge clk)
        if(!reset)
            state<=IDLE;
        else
            state<=next_state;
      
    //next state logic
    always @(*)
     begin
        next_state =state; // default state
        
        case(state)
            IDLE:
                if(!rx_synch2)
                    next_state=START;
            START:
                if(baud_tick && bit_time==7)  
                    begin
                       if(!rx_synch2)
                          next_state=DATA;
                       else
                          next_state=IDLE;
                    end
                else
                    next_state=START;
            DATA:
                if(baud_tick && read_count==8)
                    next_state=STOP;
                else
                    next_state=DATA;
            STOP:
                if(baud_tick && bit_time==15 && rx_synch2)
                    next_state=DONE;
                else
                    next_state=STOP;
            DONE:
                next_state=IDLE;
        endcase
            
     end
   
   //Data Logic
   always @(posedge clk)
    begin
        if(!reset)
            begin
            read_count<=0;
            pos<=0;
            bit_time<=0;
            rx_valid<=0;
            end
        else
            begin
         
            //counter bit time increment
            if(baud_tick)
                bit_time<=bit_time+1;
            
            case(state)
                IDLE:
                    begin
                      read_count<=0;
                      pos<=0;
                      bit_time<=0;
                      rx_valid<=0;  
                    end
                    
                START:
                    if(baud_tick && bit_time==7)
                        bit_time<=0;
                DATA:
                    if(baud_tick && bit_time==15)
                        begin
                            rx_data[pos] <= rx_synch2;
                            pos<=pos+1;
                            read_count<=read_count +1;
                            bit_time<=0;
                        end
                STOP:
                    if(baud_tick && bit_time == 15)
                        bit_time<=0;
                DONE:
                    rx_valid<=1;          
            endcase
                    
            end
    end
      
endmodule
