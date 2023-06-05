`ifndef __PIPELINEIFWITHFIFO__
`define __PIPELINEIFWITHFIFO__
`include "imemory.v"
`include "fifo5x16.v"
module pipelineIF_withFIFO
(
    input wire        clk,
    input wire        resetn,
    input wire        enable, // if not enable, stall pipeline
    /* redirectionPC from static branch predictor in ID stage */
    input wire [31:0] redirection_d_i,
    input wire        taken_d_i,
    input wire [ 1:0] drain_cnt_d_i, // 16 bits or 32 bits
    input wire [31:0] redirection_e_i,
    input wire        taken_e_i,
    input             flush_i,

    /* output signals to ID stage */
    output wire [31:0] instruction_f_o
);

    // =========================================================================
    // ============================== variables ================================
    // =========================================================================
    // I-Memory variables
    wire [9:0] sram_addr; // Address to access 32x816 sram
    wire ceb, web;
    wire [31:0] sram_output;
    // FIFO variables
    wire [31:0] mem_addr;
    wire [31:0] re_addr;
    wire        taken;
    reg         taken_reg;
    wire [ 1:0] drain_cnt;

    // =========================================================================
    // ============================ implementation =============================
    // =========================================================================
    
    // instruction memory instance
    assign web = 1; // only read from I-Memory
    assign sram_addr = mem_addr[10:1];

    assign taken = taken_e_i | taken_d_i;
    always @(posedge clk ) begin 
        taken_reg <= taken;
    end
    
    assign re_addr = (taken_e_i == 1'b1) ? redirection_e_i: redirection_d_i;

    // if not enable, to redirection pc, don't read from FIFO
    // assign drain_cnt = {2{enable == 1'b1}} & drain_cnt_d_i;
    assign drain_cnt = ({2{enable == 1'b1 & {taken == 1'b0} & {taken_reg == 1'b0}}}) & (drain_cnt_d_i);

    // I-Memory instance
    imemory u_imemory(
        //ports
        .clk    		( clk    		),
        .resetn 		( resetn 		),
        .ceb    		( ~ceb    		),
        .web    		( web    		),
        .A      		( sram_addr  	),
        .Q      		( sram_output  	)
    );

    // 5x16 FIFO instance
    // TODO: add flush in FIFO
    fifo5x16 u_fifo5x16(
        //ports
        .clk       		( clk       		),
        .resetn    		( resetn    		),
        .mem_data  		( sram_output  		),
        .re_addr   		( re_addr   		),
        .taken     		( taken     		),
        .drain_cnt 		( drain_cnt 		),
        .mem_addr  		( mem_addr  		),
        .mem_rq    		( ceb        		),
        .ir        		( instruction_f_o 	)
    );

endmodule
`endif
