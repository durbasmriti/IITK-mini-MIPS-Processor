`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04/11/2025 03:11:41 PM
// Design Name:
// Module Name: Floating_point_unit
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


// IEEE 754 FPU Module
module Floating_point_unit(
    input [31:0] a, b,
    input [3:0] fpu_op,
    output reg [31:0] result,
    output reg fp_cc,
    output reg invalid,
    output reg overflow,
    output reg underflow
);

// Constants
localparam EXP_ZERO = 8'b00000000;
localparam EXP_MAX  = 8'b11111111;

// Fields of inputs
wire sign_a = a[31];
wire sign_b = b[31];
wire [7:0] exp_a = a[30:23];
wire [7:0] exp_b = b[30:23];
wire [23:0] frac_a = (exp_a == 0) ? {1'b0, a[22:0]} : {1'b1, a[22:0]};
wire [23:0] frac_b = (exp_b == 0) ? {1'b0, b[22:0]} : {1'b1, b[22:0]};

reg [31:0] res_add, res_sub;
reg cmp_eq, cmp_lt, cmp_le, cmp_gt, cmp_ge;

// Alignment and result
reg [24:0] frac_large, frac_small;
reg [7:0] exp_large;
reg sign_res;
reg [24:0] frac_res;
reg [7:0] exp_res;
reg [31:0] final_res;

// Normalize result
function [31:0] pack_result;
    input sign;
    input [7:0] exp;
    input [24:0] frac;
    begin
        if (exp == 0 || exp >= 8'hFF) begin
            pack_result = {sign, 8'hFF, 23'b0}; // Inf/NaN
        end else begin
            pack_result = {sign, exp, frac[22:0]};
        end
    end
endfunction

// ADD/SUB
always @(*) begin
    if (exp_a > exp_b) begin
        frac_large = {1'b0, frac_a};
        frac_small = {1'b0, frac_b} >> (exp_a - exp_b);
        exp_large = exp_a;
    end else begin
        frac_large = {1'b0, frac_b};
        frac_small = {1'b0, frac_a} >> (exp_b - exp_a);
        exp_large = exp_b;
    end

    // ADD
    if (fpu_op == 4'b0001) begin
        if (sign_a == sign_b) begin
            frac_res = frac_large + frac_small;
            sign_res = sign_a;
        end else begin
            frac_res = (frac_large > frac_small) ? frac_large - frac_small : frac_small - frac_large;
            sign_res = (frac_large > frac_small) ? sign_a : sign_b;
        end
        if (frac_res[24]) begin
            frac_res = frac_res >> 1;
            exp_res = exp_large + 1;
        end else begin
            exp_res = exp_large;
        end
        res_add = pack_result(sign_res, exp_res, frac_res);
    end

    // SUB
    if (fpu_op == 4'b0010) begin
        if (sign_a != sign_b) begin
            frac_res = frac_large + frac_small;
            sign_res = sign_a;
        end else begin
            frac_res = (frac_large > frac_small) ? frac_large - frac_small : frac_small - frac_large;
            sign_res = (frac_large > frac_small) ? sign_a : ~sign_a;
        end
        if (frac_res[24]) begin
            frac_res = frac_res >> 1;
            exp_res = exp_large + 1;
        end else begin
            exp_res = exp_large;
        end
        res_sub = pack_result(sign_res, exp_res, frac_res);
    end
end

// COMPARISON
always @(*) begin
    cmp_eq = (a == b);
    cmp_lt = ($signed({sign_a, exp_a, frac_a}) < $signed({sign_b, exp_b, frac_b}));
    cmp_le = cmp_lt | cmp_eq;
    cmp_gt = !cmp_le;
    cmp_ge = !cmp_lt;
end

// OUTPUT LOGIC
always @(*) begin
    result = 32'b0;
    fp_cc = 1'b0;
    invalid = 1'b0;
    case (fpu_op)
        4'b0000: result = a;                        // mov.s
        4'b0001: result = res_add;                 // add.s
        4'b0010: result = res_sub;                 // sub.s
        4'b0011: fp_cc = cmp_eq;                   // c.eq.s
        4'b0100: fp_cc = cmp_lt;                   // c.lt.s
        4'b0101: fp_cc = cmp_le;                   // c.le.s
        4'b0110: fp_cc = cmp_ge;                   // c.ge.s
        4'b0111: fp_cc = cmp_gt;                   // c.gt.s
        4'b1000: result = b;                       // mov.s f0=f1
        default: invalid = 1'b1;
    endcase
end

endmodule
