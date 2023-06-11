`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2023 07:24:35 AM
// Design Name: 
// Module Name: execute
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


module execute(
    input CLK,
    input RESET
    ); 
    `include "instruction_set.vh"
    //INITIALIZE ALU
    assign pipe.PIPE_ALU_OP1 = pipe.PIPE_RS1;
    assign pipe.PIPE_ALU_OP2 = (pipe.PIPE_IFDCR[7]) ? pipe.PIPE_EXCIMM : pipe.PIPE_RS2;
    assign pipe.PIPE_ALU_WADDR = pipe.PIPE_EXCIMM + pipe.PIPE_ALU_OP1;
    //COMPARING OPERATIONS
    assign pipe.PIPE_SRES_SIGNED[32:0] = {pipe.PIPE_ALU_OP1[31], pipe.PIPE_ALU_OP1} - {pipe.PIPE_ALU_OP2[31], pipe.PIPE_ALU_OP2};
    assign pipe.PIPE_SRES_UNSIGNED[32:0] = {1'b0, pipe.PIPE_ALU_OP1} - {1'b0, pipe.PIPE_ALU_OP2};
    
    
    assign pipe.PIPE_BRSTALL = pipe.PIPE_WBCR[13] || pipe.PIPE_WBCR[14];
    
    
    //Execute Jump&Branch Unit depending on the instruction and operands
    always @(*) begin
        pipe.PIPE_NEXTPC = pipe.PIPE_FPC + 4;
        pipe.PIPE_BRT = !pipe.PIPE_BRSTALL;
        case(1'b1)
            pipe.PIPE_IFDCR[9]   : pipe.PIPE_NEXTPC = pipe.PIPE_PC + pipe.PIPE_EXCIMM;
            pipe.PIPE_IFDCR[10]  : pipe.PIPE_NEXTPC = pipe.PIPE_ALU_OP1 + pipe.PIPE_EXCIMM;
            pipe.PIPE_IFDCR[11]: begin
                case(pipe.PIPE_IFDCR[5:3]) 
                    BEQ : begin
                            pipe.PIPE_NEXTPC = (pipe.PIPE_SRES_SIGNED[32:0] == 'd0) ? (pipe.PIPE_PC + pipe.PIPE_EXCIMM) : pipe.PIPE_FPC + 4;
                            if (pipe.PIPE_SRES_SIGNED[32:0] != 'd0) 
                                pipe.PIPE_BRT = 1'b0;
                    end
                    BNE : begin
                            pipe.PIPE_NEXTPC = (pipe.PIPE_SRES_SIGNED[32:0] != 'd0) ? (pipe.PIPE_PC + pipe.PIPE_EXCIMM) : pipe.PIPE_FPC + 4;
                            if (pipe.PIPE_SRES_SIGNED[32:0] == 'd0) 
                                pipe.PIPE_BRT = 1'b0;
                    end
                    BLT : begin
                            pipe.PIPE_NEXTPC = pipe.PIPE_SRES_SIGNED[32] ? (pipe.PIPE_PC + pipe.PIPE_EXCIMM) : pipe.PIPE_FPC + 4;
                            if (!pipe.PIPE_SRES_SIGNED[32]) 
                                pipe.PIPE_BRT = 1'b0;
                    end
                    BGE : begin
                            pipe.PIPE_NEXTPC = !pipe.PIPE_SRES_SIGNED[32] ? (pipe.PIPE_PC + pipe.PIPE_EXCIMM) : pipe.PIPE_FPC + 4;
                            if (pipe.PIPE_SRES_SIGNED[32]) 
                                pipe.PIPE_BRT = 1'b0;
                    end
                    BLTU: begin
                            pipe.PIPE_NEXTPC = pipe.PIPE_SRES_UNSIGNED[32] ? pipe.PIPE_PC + pipe.PIPE_EXCIMM : pipe.PIPE_FPC + 4;
                            if (!pipe.PIPE_SRES_UNSIGNED[32]) 
                                pipe.PIPE_BRT = 1'b0;
                    end
                    BGEU: begin
                            pipe.PIPE_NEXTPC = !pipe.PIPE_SRES_UNSIGNED[32] ? pipe.PIPE_PC + pipe.PIPE_EXCIMM : pipe.PIPE_FPC + 4;
                            if (pipe.PIPE_SRES_UNSIGNED[32]) 
                                pipe.PIPE_BRT = 1'b0;
                    end
                    default: begin
                            pipe.PIPE_NEXTPC    = pipe.PIPE_FPC;
                    end
                endcase
            end
            default  : begin
                   pipe.PIPE_NEXTPC          = pipe.PIPE_FPC + 4;
                   pipe.PIPE_BRT        = 1'b0;
            end
        endcase
    end
    
    //Execute ALU and its Arithmatic & Logic Operations
    always @(*) begin
        case(1'b1)
            pipe.PIPE_IFDCR[12]:  pipe.PIPE_ALU_RES = pipe.PIPE_ALU_OP2;
            pipe.PIPE_IFDCR[9]:   pipe.PIPE_ALU_RES = pipe.PIPE_PC + 4;
            pipe.PIPE_IFDCR[10]:  pipe.PIPE_ALU_RES = pipe.PIPE_PC + 4;
            pipe.PIPE_IFDCR[8]:   pipe.PIPE_ALU_RES = pipe.PIPE_EXCIMM;
            pipe.PIPE_IFDCR[2]:
            case(pipe.PIPE_IFDCR[5:3])
                ADD : if (pipe.PIPE_IFDCR[6] == 1'b0)
                        pipe.PIPE_ALU_RES  = pipe.PIPE_ALU_OP1 + pipe.PIPE_ALU_OP2;
                      else
                        pipe.PIPE_ALU_RES  = pipe.PIPE_ALU_OP1 - pipe.PIPE_ALU_OP2;
                SLL : pipe.PIPE_ALU_RES = pipe.PIPE_ALU_OP1 << pipe.PIPE_ALU_OP2;
                SLT : pipe.PIPE_ALU_RES = pipe.PIPE_SRES_SIGNED[32] ? 'd1 : 'd0;
                SLTU: pipe.PIPE_ALU_RES = pipe.PIPE_SRES_UNSIGNED[32] ? 'd1 : 'd0;
                XOR : pipe.PIPE_ALU_RES = pipe.PIPE_ALU_OP1 ^ pipe.PIPE_ALU_OP2;
                SR  : if (pipe.PIPE_IFDCR[6] == 1'b0)
                        pipe.PIPE_ALU_RES = pipe.PIPE_ALU_OP1 >>> pipe.PIPE_ALU_OP2;
                      else
                        pipe.PIPE_ALU_RES = $signed(pipe.PIPE_ALU_OP1) >>> pipe.PIPE_ALU_OP2;
                OR  : pipe.PIPE_ALU_RES = pipe.PIPE_ALU_OP1 | pipe.PIPE_ALU_OP2;
                AND : pipe.PIPE_ALU_RES = pipe.PIPE_ALU_OP1 & pipe.PIPE_ALU_OP2;
                default: pipe.PIPE_ALU_RES = 'hx;
            endcase
            default: pipe.PIPE_ALU_RES = 'hx;
        endcase
    end
    
    //Adjust PC depending on the Branch stall
    always@(posedge CLK or negedge RESET) begin
        if(!RESET) pipe.PIPE_FPC <= 32'h00000000;
        else if(!pipe.PIPE_IFDCR[0]) 
            pipe.PIPE_FPC <= (pipe.PIPE_BRSTALL) ? (pipe.PIPE_FPC + 4) : pipe.PIPE_NEXTPC;
    end

    //Initialize output for WB
    always@(posedge CLK or negedge RESET) begin
        if(!RESET) begin
            pipe.PIPE_WBRES <= 32'h00000000;
            pipe.PIPE_WBCR[27:2] <= 26'h0;
        end
        
        else if(!pipe.PIPE_IFDCR[0]) begin
            pipe.PIPE_WBRES       <= pipe.PIPE_ALU_RES;
            pipe.PIPE_WBCR[2]     <= pipe.PIPE_IFDCR[2] | pipe.PIPE_IFDCR[8] | pipe.PIPE_IFDCR[9] | pipe.PIPE_IFDCR[10] | pipe.PIPE_IFDCR[13];
            pipe.PIPE_WBCR[5:3]   <= pipe.PIPE_IFDCR[5:3];
            pipe.PIPE_WBCR[6]     <= pipe.PIPE_IFDCR[12] && !pipe.PIPE_BRSTALL;
            pipe.PIPE_WBCR[7]     <= pipe.PIPE_IFDCR[13];
            pipe.PIPE_WBCR[12:8]  <= pipe.PIPE_IFDCR[28:24];
            pipe.PIPE_WBCR[13]    <= pipe.PIPE_BRT;
            pipe.PIPE_WBCR[14]    <= pipe.PIPE_WBCR[13];
            pipe.PIPE_WBCR[27:26] <= pipe.DATAMEM_RDADDR[1:0];    
        end
    end
endmodule
