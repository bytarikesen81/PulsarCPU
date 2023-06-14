`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2023 06:08:51 AM
// Design Name: 
// Module Name: ins_memory
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


module ins_memory #(
    parameter PROGRAM = "imem.hex",
    parameter SIZE = 32768
)(
    input CLK,
    input [31:2] ADDR, //read_address
    input RE,
    output reg [31:0] IOUT //read_data
    );
    
    localparam BITRANGE = $clog2(SIZE/4);
    wire [BITRANGE-1:0] INSADDR;
    assign INSADDR[BITRANGE-1:0] = ADDR[BITRANGE+1:2];
    reg[31:0] memory[(SIZE/4)-1:0];
    
    //Load program file into the instruction memory
    initial begin
        $readmemh(PROGRAM, memory);
    end
   
   always @(posedge CLK) begin
        if(!RE) IOUT = memory[INSADDR];
   end
endmodule
