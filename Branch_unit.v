`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04/09/2025 02:49:43 PM
// Design Name:
// Module Name: Branch_unit
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

//////////////////////////////////////////////////////////////////////////////////
module Branch_unit(
    input [31:0] rs_data, rt_data,
    input [31:0] imm16, // Immediate value from instruction
    input [5:0] opcode,
    output reg branch_taken,
    output [31:0] branch_target
);

wire signed [31:0] signed_rs = rs_data;
wire signed [31:0] signed_rt = rt_data;
wire [31:0] unsigned_rs = rs_data;
wire [31:0] unsigned_rt = rt_data;

assign branch_target = {{14{imm16[15]}}, imm16, 2'b00}; // Sign-extend the immediate and shift left by 2

always @(*) begin
    case(opcode)
        6'b000100: branch_taken = (rs_data == rt_data); // beq
        6'b000101: branch_taken = (rs_data != rt_data); // bne
        6'b000110: branch_taken = (signed_rs > signed_rt); // bgt
        6'b000111: branch_taken = (signed_rs >= signed_rt); // bgte
        6'b001000: branch_taken = (signed_rs < signed_rt); // ble
        6'b001001: branch_taken = (signed_rs <= signed_rt); // bleq
        6'b001010: branch_taken = (unsigned_rs < unsigned_rt); // bleu
        6'b001011: branch_taken = (unsigned_rs > unsigned_rt); // bgtu
        default: branch_taken = 0;
    endcase
end

endmodule