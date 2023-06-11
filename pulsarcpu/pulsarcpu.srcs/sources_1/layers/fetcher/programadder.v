`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2023 03:09:26 AM
// Design Name: 
// Module Name: programadder
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


module programadder(
    input [31:0]DATAIN,
    output[31:0]DATAOUT);
    assign DATAOUT = DATAIN+4;
endmodule
