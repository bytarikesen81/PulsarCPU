`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2023 09:58:41 PM
// Design Name: 
// Module Name: testbench
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


module testbench();
    //Local Parameters
    localparam      IMEMSIZE = 32768;
    localparam      DMEMSIZE = 32768;

    // PC counter and checker
    reg     [31: 0] next_pc;
    reg     [ 7: 0] count;
    
    reg             clk;
    reg             reset;
    reg             stall;
    wire            exception;
    wire    [31: 0] inst_mem_read_data;
    wire            inst_mem_is_valid;
    wire            dmem_write_valid;
    wire            dmem_read_valid;
    wire    [31: 0] dmem_read_data_temp;
    

    assign dmem_write_valid    = 1'b1;
    assign dmem_read_valid     = 1'b1; 
    assign inst_mem_is_valid   = 1'b1;
    
    initial begin
     $monitor("time: %t ,result =%d",$time,pipe.REGFILE[15]);
    end

    initial begin
        //$dumpfile("C:\Users\bytar\Desktop\ARA PROJE ORIG\Kod\RISC-V CPU\pulsarcpu\pulsarcpu.ip_user_files\simulation\pipeline.vcd");
        $dumpvars(0,pipe);
    end


    initial begin
        clk            <= 1'b1;
        reset          <= 1'b0;
        stall          <= 1'b1;

        repeat (2) @(posedge clk);
        reset          <= 1'b1;

        repeat (2) @(posedge clk);
        stall           <= 1'b0;
    end

    always #2 clk      <= ~clk;


    // check timeout if the PC do not change anymore
    always @(posedge clk or negedge reset) begin
        if (!reset) 
        begin
            next_pc     <= 32'h0;
            count       <= 8'h0;
            pipe.REGFILE[2] <= 32'h00000000;
        end 
        else begin
            next_pc     <= pipe.PIPE_IFPC;

            if (next_pc == pipe.PIPE_IFPC)
                count   <= count + 1;
            else
                count   <= 8'h0;
            if (count > 100) begin
                $display("Executing timeout");
                #2 $finish(2);
            end
        end
    end

    // stop at exception
    always @(posedge clk) 
    begin
        if (exception) 
        begin
            $display("All instructions are Fetched");
            #2 $finish(2);
        end
    end
    
    ///////////////////////////////////////////////////////////
/////// Instanatiate Data memory
///////////////////////////////////////////////////////////
    data_memory # (
        //.SEGMENT("dmem.hex"),
        .SIZE(DMEMSIZE)
    ) data_mem (
        .CLK(clk),
        .RESET(reset),
        
        .RE(pipe.DATAMEM_RE),
        .WE(pipe.DATAMEM_WE),
        .WB(pipe.DATAMEM_WB),
        .WRADDR(pipe.DATAMEM_WRADDR[31:2]),
        .RDADDR(pipe.DATAMEM_RDADDR[31:2]),
        .DIN(pipe.DATAMEM_DIN),
        
        .DOUT(dmem_read_data_temp)
    ); 
    
///////////////////////////////////////////////////////////
/////// Instanatiate Instruction memory
///////////////////////////////////////////////////////////
    ins_memory # (
        .PROGRAM("imem.hex"),
        .SIZE(IMEMSIZE)
    ) inst_mem (
        .CLK(clk),
        .RE(1'b0),
        .IOUT (inst_mem_read_data),
        .ADDR (pipe.INSMEM_ADDR[31:2])
    );
    
    ///////////////////////////////////////////////////////////
/////// Instanatiate Pipeline Module
//////////////////////////////////////////////////////////

pipe pipe(
    .CLK (clk),
    .RESET(reset),
    .STALL(stall),
    
    .INS_BUSY(inst_mem_is_valid),
    .IIN(inst_mem_read_data),
    
    .DTEMP(dmem_read_data_temp),
    .DATA_RD_VALID(dmem_read_valid),
    .DATA_WR_VALID(dmem_write_valid),
    
    .FAULT(exception)
);

//check memory range
always @(posedge clk) 
begin
    if (pipe.INSMEM_READY && pipe.INSMEM_ADDR[31:$clog2(IMEMSIZE)] != 'd0) 
    begin
        $display("IMEM address %x out of range", pipe.INSMEM_ADDR);
        #2 $finish(2);
    end
    if (pipe.DATAMEM_WE  && pipe.DATAMEM_WRADDR[31:$clog2(DMEMSIZE)] != 'd0) 
    begin
        $display("DMEM address %x out of range", pipe.DATAMEM_WRADDR);
        #2 $finish(2);
    end
end
    
    


endmodule
