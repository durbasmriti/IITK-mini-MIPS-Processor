`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04/09/2025 03:24:53 PM
// Design Name:
// Module Name: Register_file
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
// author - Dhriti Barnwal, Durbasmriti Saha
//////////////////////////////////////////////////////////////////////////////////


module register_file(
    input clk,
    input reset,

    // General Purpose Register (GPR) ports
    input [4:0] gpr_read_addr1,
    input [4:0] gpr_read_addr2,
    output reg [31:0] gpr_read_data1,
    output reg [31:0] gpr_read_data2,

    input [4:0] gpr_write_addr,
    input [31:0] gpr_write_data,
    input gpr_write_en,

    // Floating-Point Register ports
    input [4:0] fpr_read_addr1,
    input [4:0] fpr_read_addr2,
    output reg [31:0] fpr_read_data1,
    output reg [31:0] fpr_read_data2,

    input [4:0] fpr_write_addr,
    input [31:0] fpr_write_data,
    input fpr_write_en,

    //move instructions
    input mtc1_en,        // Move to FPR from GPR
    input mfc1_en,        // Move to GPR from FPR
    input [4:0] move_reg  // Register number for move ops
);

// 32 General Purpose Registers
reg [31:0] gpr [0:31];

// 32 Floating Point Registers
reg [31:0] fpr [0:31];

// GPR Read Operation
always @(*) begin
    // Read port 1
    if (gpr_read_addr1 == 5'b0)
        gpr_read_data1 = 32'b0; // $zero register
    else
        gpr_read_data1 = gpr[gpr_read_addr1];

    // Read port 2
    if (gpr_read_addr2 == 5'b0)
        gpr_read_data2 = 32'b0; // $zero register
    else
        gpr_read_data2 = gpr[gpr_read_addr2];
end

// FPR Read Operation
always @(*) begin
    fpr_read_data1 = fpr[fpr_read_addr1];
    fpr_read_data2 = fpr[fpr_read_addr2];
end

// GPR Write Operation
always @(posedge clk or posedge reset) begin
    if (reset) begin:my_new_block
        // Initialize registers to 0 on reset
        integer i;
        for (i = 0; i < 32; i = i + 1)
          begin
          gpr[i] <= 32'b0;
          end
        gpr[29] <= 32'h80000000;  // $sp
        gpr[28] <= 32'h10008000;  // $gp
        gpr[30] <= 32'h00000000;  // $fp
    end:my_new_block
    else begin
        // Normal write operation
        if (gpr_write_en && (gpr_write_addr != 5'b0)) begin
            gpr[gpr_write_addr] <= gpr_write_data;
        end

        // Move from FPR to GPR (mfc1)
        if (mfc1_en && (move_reg != 5'b0)) begin
            gpr[move_reg] <= fpr[fpr_read_addr1];
        end
    end
end

// FPR Write Operation
always @(posedge clk or posedge reset) begin

    if (reset) begin : my_initial_block
     integer i;
        // Initialize registers to 0 on reset

        for (i = 0; i < 32; i = i + 1)
        begin
            fpr[i] <= 32'b0;
         end
    end:my_initial_block
    else begin
        // Normal write operation
        if (fpr_write_en) begin
            fpr[fpr_write_addr] <= fpr_write_data;
        end

        // Move from GPR to FPR (mtc1)
        if (mtc1_en) begin
            fpr[move_reg] <= gpr[gpr_read_addr1];
        end
    end
end


endmodule