`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/02/2023 05:31:38 AM
// Design Name: 
// Module Name: pipe
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


module pipe(
    input CLK,
    input RESET,
    input STALL,
    
    input INS_BUSY,
    input [31:0]IIN,
    
    input [31:0]DTEMP,
    input DATA_RD_VALID,
    input DATA_WR_VALID,
    
    output FAULT
    );
    
/*PIPE REGISTERS
PIPE_IFDCR [31:0] :-
[0] STALL 
[1] ILLEGAL INSTRUCTION
[2] ALU ENABLE
[5:3] ALU OPERATION
[6] ARITH. SUBTYPE
[7] IMMEDIATE SEL.
[8] LUI OP. FLAG
[9] JMP OP. FLAG
[10] JMPR OP. FLAG
[11] BRANCH OP. FLAG
[12] MEMORY WRITE
[13] MEMORY TO REG FLAG.
[18:14] SRC1_SELECT
[23:19] SRC2_SELECT
[28:24] DEST_SELECT 
[29] RV32M INSTRUCTION
[31:30] RESERVED 

PIPE_IMM [31:0]
PIPE_INSTR [31:0]

PIPE_PC [31:0]
PIPE_IFPC [31:0]
PIPE_FPC [31:0]

X ->[0..31] GPRx [31:0]

PIPE_WBCR[31:0] :-
[0] Stall First Ins. Data
[1] Stall Second Ins. Data
[2] Writeback ALU Result to Reg 
[5:3] Writeback ALU Operation   
[6] Writeback Memory Write      
[7] Writeback Memory to Reg.    
[12:8] Writeback Dest Reg. Sel. 
[13] Writeback Branch           
[14] Writeback Branch Next      
[25:15] RESERVED
[27:26] Writeback Read Address   
[31:28] Writeback Write Byte

PIPE_WBRES [31:0]

PIPE_WRADDR [31:0]
PIPE_WRDATA [31:0]
PIPE_RDDATA [31:0]

WIRE IMEM_ADDR [31:0]

PIPE_BRCR[1:0] :-
[0] Branch Taken
[1] Branch Stall
        
    
    */
    
    /*-------Instruction Fetch & Instruction Decode-------*/
    //Pipe IF/D Control Register
    reg [31:0]PIPE_IFDCR;

    //Pipe Instruction Register 
    reg [31:0]PIPE_INSTR;
    
    //Pipe Immediate Registers
    reg [31:0]PIPE_IMM;
    reg [31:0]PIPE_EXCIMM;
    
    //Program Counters
    reg  [31:0]PIPE_PC;
    reg  [31:0]PIPE_IFPC;
    reg  [31:0]PIPE_FPC;
    
    //Data Signal Wires
    wire [31:0]PIPE_RS1;
    wire [31:0]PIPE_RS2;
    
    
    /*----------------------Execute-----------------------*/
    reg PIPE_BRT;
    wire PIPE_BRSTALL;
    reg [31:0]PIPE_ALU_RES;
    reg [31:0]PIPE_NEXTPC;
    
    reg [63:0]PIPE_ALU_MUL;
    
    wire [31:0]PIPE_ALU_OP1;
    wire [31:0]PIPE_ALU_OP2;
    wire [32:0]PIPE_SRES_SIGNED;
    wire [32:0]PIPE_SRES_UNSIGNED;
    wire [31:0]PIPE_ALU_WADDR;
  
   /*-------------------Memory Interface------------------*/  
    //Data Memory
    wire [31:0]DATAMEM_DIN;
    wire DATAMEM_WE;
    wire DATAMEM_RE;
    wire [31:0]DATAMEM_WRADDR;
    wire [31:0]DATAMEM_RDADDR;
    wire [31:0]DATAMEM_DOUT;
    wire [3:0]DATAMEM_WB;
    wire DATAMEM_RVCHECK;
    
    //Instruction Memory
    wire INSMEM_READY;
    wire [31:0]INSMEM_ADDR;
    
    
    /*---------------------Writeback----------------------*/
    reg [31:0]PIPE_WBCR;
    reg [31:0]PIPE_WBRES;
    reg [31:0]PIPE_WRADDR;
    reg [31:0]PIPE_WRDATA;
    reg [31:0]PIPE_RDDATA;
    
    wire PIPE_WBSTALL;
    
     
    /*-----------------General Purpose Registers----------------*/
    reg [31:0] REGFILE[31:1]; //In RegFile
    
    
    /*-Adjust Initial Connections And Values of CPU Inner Buses-*/
    assign DATAMEM_WRADDR   = PIPE_WRADDR;
    assign DATAMEM_RDADDR   = PIPE_ALU_OP1 + PIPE_EXCIMM;
    assign DATAMEM_RE       = PIPE_IFDCR[13];
    assign DATAMEM_WE       = PIPE_WBCR[6];
    assign DATAMEM_DIN      = PIPE_WRDATA;
    assign DATAMEM_WB       = PIPE_WBCR[31:28];
    assign DATAMEM_DOUT     = DTEMP;
    assign DATAMEM_RVCHECK  = 1'b1;
    
    
    /*------------------Initialize CPU Modules------------------*/
    fetcher FETCH(
        .CLK(CLK),
        .RESET(RESET),
        .WAIT(STALL),
        .INS_BUSY(INS_BUSY),
        .IIN(IIN),
        .FAULT(FAULT)
    );
    
    decoder DECODE(
        .CLK(CLK),
        .RESET(RESET)
    );
    
    execute EXECUTE(
        .CLK(CLK),
        .RESET(RESET)
    );
    
    writeback WB(
        .CLK(CLK),
        .RESET(RESET)
    );
endmodule
