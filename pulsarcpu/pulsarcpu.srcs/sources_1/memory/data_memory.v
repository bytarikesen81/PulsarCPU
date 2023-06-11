`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2023 06:08:51 AM
// Design Name: 
// Module Name: data_memory
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


module data_memory #(
    //parameter SEGMENT = "C:\Users\bytar\Desktop\ARA PROJE ORIG\Kod\RISC-V CPU\pulsarcpu\pulsarcpu.ip_user_files\mem_generator\imem_dmem\dmem.hex",
    parameter SIZE = 4096
)(
    input CLK,
    input RESET,
    
    input RE,
    input WE,
    input [3:0] WB,
    input [31:2] WRADDR,
    input [31:2] RDADDR,
    input [31:0] DIN,
    
    output reg [31:0] DOUT);
    
    integer i;
    localparam BITRANGE = $clog2(SIZE/4);
    
    wire [BITRANGE-1:0] WADDR;
    wire [BITRANGE-1:0] RADDR;
    
    assign WADDR[BITRANGE-1:0] =  WRADDR[BITRANGE+1:2];
    assign RADDR[BITRANGE-1:0] =  RDADDR[BITRANGE+1:2];
    reg[31:0] memory[(SIZE/4)-1:0];
    
    
    initial begin
        // initializing memory and loading data in the hex file in the reg memory
            for (i=0; i<SIZE/4; i=i+1) memory[i] = 32'h0;
        // Reading and storing data in bytes, the stan read_data <= memory[read_addr];
        //$readmemh(SEGMENT, memory, 0, SIZE/4-1);
    end
    
    always @(posedge CLK or negedge RESET) begin
        if(!RESET) for(i=0; i<SIZE/4; i = i+1) memory[i] = 32'h0;  
        else begin
            if (WE) begin
                if (WB[0]) memory[WADDR][8*0+7:8*0] <= DIN[8*0+7:8*0];
                if (WB[1]) memory[WADDR][8*1+7:8*1] <= DIN[8*1+7:8*1];
                if (WB[2]) memory[WADDR][8*2+7:8*2] <= DIN[8*2+7:8*2];
                if (WB[3]) memory[WADDR][8*3+7:8*3] <= DIN[8*3+7:8*3];
            end

            if (RE) begin
                if (WE && (RADDR == WADDR)) begin
                    DOUT[8*0+7:8*0] <= (WB[0]) ? DIN[8*0+7:8*0] : memory[RADDR][8*0+7:8*0];
                    DOUT[8*1+7:8*1] <= (WB[1]) ? DIN[8*1+7:8*1] : memory[RADDR][8*1+7:8*1];
                    DOUT[8*2+7:8*2] <= (WB[2]) ? DIN[8*2+7:8*2] : memory[RADDR][8*2+7:8*2];
                    DOUT[8*3+7:8*3] <= (WB[3]) ? DIN[8*3+7:8*3] : memory[RADDR][8*3+7:8*3];
                end 
                else begin
                    DOUT <= memory[RADDR];
                end
            end
        end 
    end
endmodule
