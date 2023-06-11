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
            /*        
        	memory[0] = 32'h00000493;
        	memory[1] = 32'h00400393;
        	memory[2] = 32'h00000537;
        	memory[3] = 32'h00050513;
            memory[4] = 32'h00052283;            
            memory[5] = 32'h40938933;
        	memory[6] = 32'h00452303;
        	memory[7] = 32'h0062c663;
        	memory[8] = 32'h00652023;
        	memory[9] = 32'h00552223;
        	memory[10] = 32'h0062ae33;
	        memory[11] = 32'h000e0463;
	        memory[12] = 32'h000302b3;
	        memory[13] = 32'h00450513;
 	        memory[14] = 32'hfff90913;   
 	        memory[15] = 32'hfc091ee3;
 	        memory[16] = 32'h00148493;
 	        memory[17] = 32'hfc74c2e3;
 	        memory[18] = 32'h00008067;
        
        /*
        memory[0] = 32'h06400093;
	    memory[1] = 32'h001000a3;
	    memory[2] = 32'h00100103;
	    memory[3] = 32'h00101183;
	    memory[4] = 32'h00310233;
	    memory[5] = 32'h401202b3;
	    memory[6] = 32'h0ff00f93;
	    memory[7] = 32'h02428333;
	    memory[8] = 32'h025313b3;
	    memory[9] = 32'h00100f13;
	    memory[10] = 32'h41e18433;
	    memory[11] = 32'h028354b3;
	    memory[12] = 32'h02837533;
	    memory[13] = 32'h00844eb3;
	    memory[14] = 32'h03d35e33;
	    memory[15] = 32'hf0100d93;
	    memory[16] = 32'h03b34d33;
	    memory[17] = 32'h000015b7;
	    memory[18] = 32'h00001617;
	    memory[19] = 32'h00100c33;
	    memory[20] = 32'h00100cb3;
	    memory[21] = 32'h00c0006f;
	    memory[22] = 32'h00309c93;
	    memory[23] = 32'h4020dc13;
	    memory[24] = 32'hff9c0ce3;
	    memory[25] = 32'h018ca6b3;
	    memory[26] = 32'h019c2733;
	    memory[27] = 32'h00e6e7b3;
	    memory[28] = 32'h0ff77813;*/
    end
   
   always @(posedge CLK) begin
        if(!RE) IOUT = memory[INSADDR];
   end
endmodule
