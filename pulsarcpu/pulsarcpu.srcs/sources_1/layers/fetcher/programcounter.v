`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2023 03:09:26 AM
// Design Name: 
// Module Name: programcounter
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


module programcounter(
    input CLK, RESET, WE,
    input [31:0]DIN,
    output reg[31:0]COUNTER
    );
    
    always @(RESET) begin
        if(RESET) begin
            #1; COUNTER = 32'h00000000;
        end
     end
     
     always @(posedge CLK) begin
        #1;
        if(!WE && !RESET)
            COUNTER = DIN;
        end
endmodule
