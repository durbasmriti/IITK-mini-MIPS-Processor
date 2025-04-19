`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04/09/2025 02:48:33 PM
// Design Name:
// Module Name: ALU
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

module ALU (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [3:0] alu_op,
    input wire is_float,
    output [31:0] result,
    output zero,
    output fp_cc,
    output overflow,carry_out
);

    // Internal wires for both integer and float units
    wire [31:0] int_result, float_result;
    wire fp_zero, fp_invalid, fp_overflow, fp_underflow;
    wire float_cc;

    // Integer ALU logic
    reg [31:0] int_res;
    reg zero_flag;

    always @(*) begin
        case(alu_op)
            4'b0001: int_res = a + b;           // add / addi / addu
            4'b0010: int_res = a - b;           // sub / subu
            4'b0011: int_res = ($signed(a) * $signed(b)); // madd
            4'b0100: int_res = a * b;           // maddu
            4'b0101: int_res = a * b;           // mul
            4'b0110: int_res = a & b;           // and / andi
            4'b0111: int_res = a | b;           // or / ori
            4'b1000: int_res = ~(a | b);        // nor
            4'b1001: int_res = a ^ b;           // xor / xori
            4'b1010: int_res = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // slt
            4'b1011: int_res = (a < b) ? 32'd1 : 32'd0; // sltu
            4'b1100: int_res = {b[15:0], 16'b0}; // lui
            4'b1110: int_res = b << a[4:0];      // sll / sla
            4'b1111: int_res = b >> a[4:0];      // srl / sra
            default: int_res = 32'b0;
        endcase
        zero_flag = (int_res == 32'b0);
    end

    // Instantiate Floating Point Unit
    Floating_point_unit fpu (
        .a(a),
        .b(b),
        .fpu_op(alu_op),
        .result(float_result),
        .fp_cc(float_cc),
        .invalid(fp_invalid),
        .overflow(fp_overflow),
        .underflow(fp_underflow)
    );

    // Output logic
    assign result = is_float ? float_result : int_res;
    assign zero = is_float ? (float_result == 32'b0) : zero_flag;
    assign fp_cc = float_cc;
    assign invalid = fp_invalid;
    assign overflow = fp_overflow;
    assign underflow = fp_underflow;

endmodule
