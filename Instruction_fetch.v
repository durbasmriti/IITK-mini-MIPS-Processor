`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04/09/2025 02:46:42 PM
// Design Name:
// Module Name: Instruction_fetch
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
module Instruction_fetch(
    input clk,
    input reset,
    input [31:0] branch_target,
    input branch_taken,
    output [31:0] instruction,
    output [31:0] pc_plus_4
);

reg [31:0] PC;
wire [31:0] next_pc;
reg [31:0] inst_mem [0:64];

// PC update logic
assign next_pc = branch_taken ? branch_target : (PC + 4);
assign pc_plus_4 = PC + 4;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        PC <= 32'h0000_0000;
    end else begin
        PC <= next_pc;
    end
end

// Instruction memory read
assign instruction = inst_mem[PC[15:2]]; // Word-aligned access

endmodule
