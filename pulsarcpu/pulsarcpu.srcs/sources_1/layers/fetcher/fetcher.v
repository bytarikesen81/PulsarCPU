`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2023 02:58:26 AM
// Design Name: 
// Module Name: fetcher
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


module fetcher(
    input CLK,
    input RESET,
    input WAIT,
    input INS_BUSY,
    input [31:0]IIN,
    output reg FAULT);
    
    `include "instruction_set.vh"
        
    //INSTRUCTION FETCHING
    always @* begin
        if(pipe.PIPE_IFDCR[0]) pipe.PIPE_INSTR = NOP;
        else pipe.PIPE_INSTR = IIN;
    end
    
    //ILLEGAL INSTRUCTION + ILLEGAL MEMORY ADDR. CHECK
    always@(posedge CLK or negedge RESET)
    begin
        if(!RESET) FAULT <= 1'b0;
        else if(pipe.PIPE_IFDCR[1] || (pipe.INSMEM_ADDR[1:0] != 2'b00)) FAULT <= 1'b1;
    end
    
    //STALL CONTROL EVERY CLK
    always@(posedge CLK or negedge RESET)
    begin
        if(!RESET) begin
            pipe.PIPE_IFDCR[0] <= 1'b1;
        end
        else begin
            pipe.PIPE_IFDCR[0] <= WAIT;
        end
    end
endmodule
