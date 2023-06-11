`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2023 06:06:18 PM
// Design Name: 
// Module Name: writeback
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


module writeback(
    input CLK,
    input RESET
    );
    
    `include "instruction_set.vh"
    
    //Writeback next instruction after the execution of current instruction is completed
    assign pipe.INSMEM_ADDR = pipe.PIPE_FPC;
    assign pipe.INSMEM_READY = !pipe.PIPE_IFDCR[0];
    
    //Determine WriteBack mechanism stalls or not
    assign pipe.PIPE_WBSTALL = pipe.PIPE_WBCR[0] || pipe.PIPE_WBCR[1];
    
    //Fetch the next instruction depending on RESET or STALL status
    always @(posedge CLK or negedge RESET) begin
        if(!RESET) pipe.PIPE_IFPC <= 32'h00000000; //Reset PC
        else if(!pipe.PIPE_IFDCR[0]) pipe.PIPE_IFPC <= pipe.PIPE_FPC;
    end
    
    //Control STALL mechanism depending on branching between cur and next. inst
    always @(posedge CLK or negedge RESET) begin
        if(!RESET) begin
            pipe.PIPE_WBCR[0] <= 1'b0;
            pipe.PIPE_WBCR[1] <= 1'b0;
        end
        else if(!pipe.PIPE_IFDCR[0] && !((pipe.PIPE_WBCR[7] && pipe.DATA_WR_VALID))) begin
            pipe.PIPE_WBCR[0] <= pipe.PIPE_WBCR[13];
            pipe.PIPE_WBCR[1] <= pipe.PIPE_WBCR[0];
        end   
    end
    
    
    /*-------------------- MEMORY OPERATIONS--------------------*/
    //Write data for STORE instructions
    always @(posedge CLK or negedge RESET) begin
        if (!RESET) begin
            pipe.PIPE_WRADDR        <= 32'h0;
            pipe.PIPE_WBCR[31:28]   <= 4'h0;
            pipe.PIPE_WRDATA        <= 32'h0;
        end 
        else if (!pipe.PIPE_WBCR[0] && pipe.PIPE_IFDCR[12]) begin
            pipe.PIPE_WRADDR   <= pipe.PIPE_ALU_WADDR;
            case(pipe.PIPE_IFDCR[5:3])
                SB: begin
                    pipe.PIPE_WRDATA <= {4{pipe.PIPE_ALU_OP2[7:0]}};
                    case(pipe.PIPE_ALU_WADDR[1:0])
                        2'b00:  pipe.PIPE_WBCR[31:28]   <= 4'b0001;
                        2'b01:  pipe.PIPE_WBCR[31:28]   <= 4'b0010;
                        2'b10:  pipe.PIPE_WBCR[31:28]   <= 4'b0100;
                        default: pipe.PIPE_WBCR[31:28]  <= 4'b1000;
                    endcase
                end
                SH: begin
                    pipe.PIPE_WRDATA     <= {2{pipe.PIPE_ALU_OP2[15:0]}};
                    pipe.PIPE_WBCR[31:28]   <= pipe.PIPE_ALU_WADDR[1] ? 4'b1100 : 4'b0011;
                end
                SW: begin
                    pipe.PIPE_WRDATA    <= pipe.PIPE_ALU_OP2;
                    pipe.PIPE_WBCR[31:28]    <= 4'hf;
                end
                default: begin
                    pipe.PIPE_WRDATA    <= 32'hx;
                    pipe.PIPE_WBCR[31:28]    <= 4'hx;
                end
            endcase
        end  
    end
    
    //Read data for LOAD instructions
    always @* begin
        case(pipe.PIPE_IFDCR[5:3])
            LB : begin // Load byte 
                case(pipe.PIPE_WBCR[27:26]) // a flag to define which byte to read and load
                    2'b00: pipe.PIPE_RDDATA[31:0] = {{24{pipe.DATAMEM_DOUT[7]}}, pipe.DATAMEM_DOUT[7:0]};
                    2'b01: pipe.PIPE_RDDATA[31:0] = {{24{pipe.DATAMEM_DOUT[15]}}, pipe.DATAMEM_DOUT[15:8]};
                    2'b10: pipe.PIPE_RDDATA[31:0] = {{24{pipe.DATAMEM_DOUT[23]}}, pipe.DATAMEM_DOUT[23:16]};
                    2'b11: pipe.PIPE_RDDATA[31:0] = {{24{pipe.DATAMEM_DOUT[31]}}, pipe.DATAMEM_DOUT[31:24]};
                endcase
            end
            // load halfword
            LH  : pipe.PIPE_RDDATA = (pipe.PIPE_WBCR[27]) ? {{16{pipe.DATAMEM_DOUT[31]}}, pipe.DATAMEM_DOUT[31:16]} : {{16{pipe.DATAMEM_DOUT[15]}}, pipe.DATAMEM_DOUT[15:0]};
            LW  : pipe.PIPE_RDDATA = pipe.DATAMEM_DOUT;      // load word
            LBU : begin     // load byte unsigned
                    case(pipe.PIPE_WBCR[27:26]) // a flag to define which byte to read and load
                        2'b00: pipe.PIPE_RDDATA[31: 0] = {24'h0, pipe.DATAMEM_DOUT[7:0]};
                        2'b01: pipe.PIPE_RDDATA[31: 0] = {24'h0, pipe.DATAMEM_DOUT[15:8]};
                        2'b10: pipe.PIPE_RDDATA[31: 0] = {24'h0, pipe.DATAMEM_DOUT[23:16]};
                        2'b11: pipe.PIPE_RDDATA[31: 0] = {24'h0, pipe.DATAMEM_DOUT[31:24]};
                    endcase
                 end
            // load halfword ungigned
            LHU : pipe.PIPE_RDDATA = (pipe.PIPE_WBCR[27:26]) ? {16'h0, pipe.DATAMEM_DOUT[31:16]} : {16'h0, pipe.DATAMEM_DOUT[15:0]};
            default: pipe.PIPE_RDDATA = 'hx;
        endcase
    end
endmodule
