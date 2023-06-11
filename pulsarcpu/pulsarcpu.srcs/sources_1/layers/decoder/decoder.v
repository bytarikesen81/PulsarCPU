`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2023 03:00:03 AM
// Design Name: 
// Module Name: decoder
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


module decoder(
    input CLK,
    input RESET);
    
    `include "instruction_set.vh"
    integer i;
    
    //DECODE IMMEDIATE VALUE FOR EXECUTION DEPENDING ON INSTRUCTION'S TYPE
    always @* begin
        pipe.PIPE_IMM = 32'h00000000;
        pipe.PIPE_IFDCR[1] = 1'b0;
        case(pipe.PIPE_INSTR[`OPCODE])
            JMPR  : pipe.PIPE_IMM       = {{20{pipe.PIPE_INSTR[31]}}, pipe.PIPE_INSTR[31:20]}; // I-Type 
            JMP   : pipe.PIPE_IMM       = {{12{pipe.PIPE_INSTR[31]}}, pipe.PIPE_INSTR[19:12], pipe.PIPE_INSTR[20], pipe.PIPE_INSTR[30:21], 1'b0}; // J-type
            BRANCH: pipe.PIPE_IMM       = {{20{pipe.PIPE_INSTR[31]}}, pipe.PIPE_INSTR[7], pipe.PIPE_INSTR[30:25], pipe.PIPE_INSTR[11:8], 1'b0}; // B-type
            LOAD  : pipe.PIPE_IMM       = {{20{pipe.PIPE_INSTR[31]}}, pipe.PIPE_INSTR[31:20]}; // I-type
            STORE : pipe.PIPE_IMM       = {{20{pipe.PIPE_INSTR[31]}}, pipe.PIPE_INSTR[31:25], pipe.PIPE_INSTR[11:7]}; // S-type
            ALI   : pipe.PIPE_IMM       = (pipe.PIPE_INSTR[`FUNC3] == SLL || pipe.PIPE_INSTR[`FUNC3] == SR) ? {27'h0, pipe.PIPE_INSTR[24:20]} : {{20{pipe.PIPE_INSTR[31]}}, pipe.PIPE_INSTR[31:20]}; // I-type
            ALR   : pipe.PIPE_IMM       = 32'h00000000; // R-type
            LUI   : pipe.PIPE_IMM       = {pipe.PIPE_INSTR[31:12], 12'd0}; // U-type
            default: begin //Illegal Instruction
                pipe.PIPE_IFDCR[1] = 1'b1;
            end
        endcase
    end
    
    //CREATE DECODING SIGNALS DEPENDING ON INSTRUCTION
    always @(posedge CLK or negedge RESET) 
    begin
        // If reset of the system is performed, reset all the values. 
        if (!RESET) 
        begin
            pipe.PIPE_EXCIMM            <= 32'h00000000;
            pipe.PIPE_IFDCR[31:2]       <= 30'h00000000;
            pipe.PIPE_PC                <= 32'h00000000;
        end 
        //If system is not stall positon, Decode the current instruction
        else if(!pipe.PIPE_IFDCR[0]) 
        begin                      // else take the values from the IF stage and decode it to pass values to corresponding wires
            pipe.PIPE_EXCIMM            <= pipe.PIPE_IMM;
            pipe.PIPE_IFDCR[2]          <= (pipe.PIPE_INSTR[`OPCODE] == ALR) || (pipe.PIPE_INSTR[`OPCODE] == ALI);
            pipe.PIPE_IFDCR[5:3]        <= pipe.PIPE_INSTR[`FUNC3];
            pipe.PIPE_IFDCR[6]          <= pipe.PIPE_INSTR[`SUBTYPE] && !(pipe.PIPE_INSTR[`OPCODE] == ALI && pipe.PIPE_INSTR[`FUNC3] == ADD);
            pipe.PIPE_IFDCR[7]          <= (pipe.PIPE_INSTR[`OPCODE] == JMPR  ) || (pipe.PIPE_INSTR[`OPCODE] == LOAD  ) || (pipe.PIPE_INSTR[`OPCODE] == ALI);
            pipe.PIPE_IFDCR[8]          <= pipe.PIPE_INSTR[`OPCODE] == LUI;
            pipe.PIPE_IFDCR[9]          <= pipe.PIPE_INSTR[`OPCODE] == JMP;
            pipe.PIPE_IFDCR[10]         <= pipe.PIPE_INSTR[`OPCODE] == JMPR;
            pipe.PIPE_IFDCR[11]         <= pipe.PIPE_INSTR[`OPCODE] == BRANCH;
            pipe.PIPE_IFDCR[12]         <= pipe.PIPE_INSTR[`OPCODE] == STORE;
            pipe.PIPE_IFDCR[13]         <= pipe.PIPE_INSTR[`OPCODE] == LOAD;
            pipe.PIPE_IFDCR[18:14]      <= pipe.PIPE_INSTR[`RS1];
            pipe.PIPE_IFDCR[23:19]      <= pipe.PIPE_INSTR[`RS2];
            pipe.PIPE_IFDCR[28:24]      <= pipe.PIPE_INSTR[`RD];
            pipe.PIPE_PC                <= pipe.PIPE_IFPC;
        end
    end
    
    //READ AND FORWARD DATA FROM REGISTERS BY AVOIDING DATA HAZARDS DEPENDING ON WRITE STALLS.
    //INITIALIZE RS1 BUS DEPENDING ON THE CURRENT AND PREV. INSTRUCTION
    assign pipe.PIPE_RS1 = (pipe.PIPE_IFDCR[18:14] == 5'b00000) ? 32'h00000000:
        (!pipe.PIPE_WBSTALL && pipe.PIPE_WBCR[2] && (pipe.PIPE_WBCR[12:8] == pipe.PIPE_IFDCR[18:14])) ? (pipe.PIPE_WBCR[7] ? pipe.PIPE_RDDATA : pipe.PIPE_WBRES):
        pipe.REGFILE[pipe.PIPE_IFDCR[18:14]];
        
   //INITIALIZE RS2 BUS DEPENDING ON THE CURRENT AND PREV. INSTRUCTION     
    assign pipe.PIPE_RS2 = (pipe.PIPE_IFDCR[23:19] == 5'b00000) ? 32'h00000000:
        (!pipe.PIPE_WBSTALL && pipe.PIPE_WBCR[2] && (pipe.PIPE_WBCR[12:8] == pipe.PIPE_IFDCR[23:19])) ? (pipe.PIPE_WBCR[7] ? pipe.PIPE_RDDATA : pipe.PIPE_WBRES):
        pipe.REGFILE[pipe.PIPE_IFDCR[23:19]];
        
   //WAIT FOR PREV INSTRUCTION'S WRITEBACK IF IT NEEDED
   always@(posedge CLK or negedge RESET)
   begin
        if(!RESET) for(i=0; i<31; i=i+1) pipe.REGFILE[i] <= 32'h00000000;
        else if(pipe.PIPE_WBCR[2] && !pipe.PIPE_IFDCR[0] && !(pipe.PIPE_WBSTALL))
            pipe.REGFILE[pipe.PIPE_WBCR[12:8]] <= pipe.PIPE_WBCR[7] ? pipe.PIPE_RDDATA : pipe.PIPE_WBRES;   
   end     
endmodule
