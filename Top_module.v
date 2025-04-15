`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04/09/2025 03:41:30 PM
// Design Name:
// Module Name: Top_module
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



module top_module(
    input clk,
    input reset
);
    // Wire declarations for connections between modules
    wire [31:0] instruction, pc, pc_plus_4;
    wire [31:0] read_data1, read_data2, alu_result, immediate, branch_target;
    wire [31:0] f_read_data1, f_read_data2, fpr_write_data;
    wire [31:0] mem_read_data, write_data;
    wire [4:0] rs, rt, rd, shamt;
    wire [5:0] opcode, funct;
    wire reg_write, mem_read, mem_write, branch, jump, alu_src, mem_to_reg, is_float;
    wire [3:0] alu_op, fpu_op;
    wire branch_taken, fp_cc;
    wire mtc1_en, mfc1_en;

    // Instruction Fetch (IF) Module
    Instruction_fetch IF (
        .clk(clk),
        .reset(reset),
        .branch_target(branch_target),
        .branch_taken(branch_taken || jump), // Combine branch and jump
        .instruction(instruction),
//        .pc(pc),
        .pc_plus_4(pc_plus_4)
    );

    // Instruction Decoding (ID) Module
    Instruction_decoding ID (
        .instruction(instruction),
        .pc_plus_4(pc_plus_4),
        .opcode(opcode),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .shamt(shamt),
        .funct(funct),
        .imm16(immediate),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .jump(jump),
        .alu_src(alu_src),
        .alu_op(alu_op),
        .mem_to_reg(mem_to_reg),
        .is_float(is_float),
        .mtc1(mtc1_en),
        .mfc1(mfc1_en)
    );

    // Register File (RF) Module
    register_file RF (
        .clk(clk),
        .reset(reset),

        // GPR Interface
        .gpr_read_addr1(rs),
        .gpr_read_addr2(rt),
        .gpr_read_data1(read_data1),
        .gpr_read_data2(read_data2),

        .gpr_write_addr(rd),
        .gpr_write_data(write_data),
        .gpr_write_en(reg_write && !is_float),

        // FPR Interface
        .fpr_read_addr1(rs),
        .fpr_read_addr2(rt),
        .fpr_read_data1(f_read_data1),
        .fpr_read_data2(f_read_data2),

        .fpr_write_addr(rd),
        .fpr_write_data(fpr_write_data),
        .fpr_write_en(reg_write && is_float),

        // Special move instructions
        .mtc1_en(mtc1_en),
        .mfc1_en(mfc1_en),
        .move_reg(rd)
    );

    // ALU Module
    ALU alu (
        .a(read_data1),
        .b(alu_src ? immediate : read_data2),
        .alu_op(alu_op),
        .is_float(is_float),
        .result(alu_result),
        .zero(), // Not used in this design
        .overflow(), // Not used in this design
        .carry_out(), // Not used in this design
        .fp_cc(fp_cc)
    );

    // Floating Point Unit
    Floating_point_unit FPU (
        .a(f_read_data1),
        .b(f_read_data2),
        .fpu_op(alu_op),
        .result(fpr_write_data),
        .fp_cc(fp_cc),
        .invalid(),
        .overflow(),
        .underflow()
    );

    // Data Memory
    data_memory DM (
        .clk(clk),
        .reset(reset),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(alu_result),
        .write_data(read_data2),
        .read_data(mem_read_data)
    );

    // Branch Unit
    Branch_unit branch_unit (
        .rs_data(read_data1),
        .rt_data(read_data2),
        .imm16(immediate),
        .opcode(opcode),
        .branch_taken(branch_taken),
        .branch_target(branch_target)
    );

    // Write-back MUX
    assign write_data = mem_to_reg ? mem_read_data : alu_result;

endmodule