`ifndef __PIPELINEWB__
`define __PIPELINEWB__
/*
file: 5 stage pipelne write back stage
    select one of the four write back source, 
    pass the select source to RF(register file) in ID(instruction decode) stage
author: fujie 
time: 2023年 5月 5日 星期五 11时06分55秒 CST
*/
`include "definitions.vh"
module pipelineWB (
    input wire clk,
    // input wire resetn, // no reset need in WB stage
    /* input data passed from MEM stage */
    input wire [31:0] alu_result_m_i,   // alu calculation result
    input wire [31:0] mem_read_data_m_i, // delared as wire, becased the D-memory has 1 cycle delay when reading
    input wire [31:0] extended_imm_m_i,  // extended imm, for 'lui' instruction
    input wire [31:0] pc_plus4_m_i,      // rd=pc+4, for `jal` instruction
    input wire reg_write_en_m_i,
    input wire [4:0] rd_idx_m_i,  // RF write back register index, passed from MEM stage
    input wire [1:0] result_src_m_i,    // select signal to choose one of the four inputs

    /* write back data to ID stage */
    output reg reg_write_en_w_o, // write back to RF enable
    output reg [4:0] rd_idx_w_o,   // RF write register index
    output reg [31:0] write_back_data_w_o // data write to RF in ID 
);


// =========================================================================
// ============================ implementation =============================
// =========================================================================
    always@(posedge clk)begin 
        reg_write_en_w_o <= reg_write_en_m_i;
        rd_idx_w_o <= rd_idx_m_i;
        case(result_src_m_i) 
            `WBSRC_ALU: begin
                write_back_data_w_o <= alu_result_m_i; // choose alu result to write back
            end
            `WBSRC_IMM: begin
                write_back_data_w_o <= extended_imm_m_i; // choose extended immdiate to write back
            end
            `WBSRC_MEM: begin
                write_back_data_w_o <= mem_read_data_m_i;// choose data memory output to write back
            end
            `WBSRC_PC: begin
                write_back_data_w_o <= pc_plus4_m_i;// choose pc+4 to write back
            end
            default: write_back_data_w_o <= alu_result_m_i;
        endcase
    end
endmodule
`endif
