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


//module Floating_point_unit(
//    input [31:0] a, b,          // Input operands
//    input [3:0] fpu_op,         // Operation code from decoder
//    output reg [31:0] result,   // Floating-point result
//    output reg fp_cc,              // Comparison flag
//    output reg invalid,         // Exception flags
//    output reg overflow,
//    output reg underflow
//);

//// Internal representations
//real fp_a, fp_b;
//real fp_result;

//// Conversion functions
//function real to_real;
//    input [31:0] bits;
//    reg sign;
//    reg [7:0] exponent;
//    reg [22:0] mantissa;
//    real significand;
//    begin
//        sign = bits[31];
//        exponent = bits[30:23];
//        mantissa = bits[22:0];

//        if (exponent == 8'hFF) begin // Special cases
//            if (mantissa == 0)
//                to_real = sign ? -$infinity : $infinity;
//            else
//                to_real = $nan;
//        end
//        else if (exponent == 0) begin // Denormal
//            significand = $itor(mantissa) / (2.0**23);
//            to_real = sign ? -significand : significand;
//        end
//        else begin // Normal numbers
//            significand = 1.0 + ($itor(mantissa) / (2.0**23));
//            to_real = $ldexp(sign ? -significand : significand, exponent - 127);
//        end
//    end
//endfunction

//function [31:0] to_bits;
//    input real value;
//    reg sign;
//    integer exponent;
//    real abs_val;
//    real mantissa;
//    integer mantissa_bits;
//    begin
//        if (value == 0.0) begin
//            to_bits = 32'h00000000; // Zero representation
//        end
//        else if (value != value) begin // NaN check
//            to_bits = 32'h7FC00000; // NaN representation
//        end
//        else if (value >= $infinity) begin
//            to_bits = 32'h7F800000; // +Infinity representation
//        end
//        else if (value <= -$infinity) begin
//            to_bits = 32'hFF800000; // -Infinity representation
//        end
//        else begin
//            abs_val = value < 0.0 ? -value : value;
//            sign = value < 0.0;

//            // Normalize
//            exponent = 127;
//            if (abs_val >= 2.0) begin
//                while (abs_val >= 2.0 && exponent < 254) begin
//                    abs_val = abs_val / 2.0;
//                    exponent = exponent + 1;
//                end
//            end
//            else if (abs_val < 1.0) begin
//                while (abs_val < 1.0 && exponent > 0) begin
//                    abs_val = abs_val * 2.0;
//                    exponent = exponent - 1;
//                end
//            end

//            // Extract mantissa by subtracting the implicit leading 1 and scale it to fit 23 bits
//            mantissa = abs_val - 1.0;
//            mantissa_bits = $rtoi(mantissa * (2.0 ** 23)); // Scale the mantissa to 23 bits

//            // Handle denormalized numbers (subnormal values where exponent == 0)
//            if (exponent == 0) begin
//                mantissa_bits = $rtoi(abs_val * (2.0 ** 23)); // Denormalized numbers don't have the implicit 1
//            end

//            // Ensure mantissa fits within 23 bits
//            mantissa_bits = mantissa_bits[22:0]; // Only take the lower 23 bits

//            // Combine sign, exponent, and mantissa into a 32-bit IEEE 754 representation
//            to_bits = {sign, exponent[7:0], mantissa_bits};
//        end
//    end
//endfunction


//always @(*) begin
//    // Default values
//    result = 32'b0;
//    fp_cc = 1'b0;
//    invalid = 1'b0;
//    overflow = 1'b0;
//    underflow = 1'b0;

//    // Convert inputs
//    fp_a = to_real(a);
//    fp_b = to_real(b);

//    case(fpu_op)
//        4'b0001: begin // add.s
//            fp_result = fp_a + fp_b;
//            result = to_bits(fp_result);

//            // Exception detection
//            overflow = (fp_result > 3.4028235e38) ||
//           (fp_result < -3.4028235e38);
//            underflow = (fp_result != 0.0) &&
//                       (fp_result > -1.17549435e-38) &&
//                       (fp_result < 1.17549435e-38);
//        end

//        4'b0010: begin // sub.s
//            fp_result = fp_a - fp_b;
//            result = to_bits(fp_result);

//            overflow = (fp_result > 3.4028235e38) ||
//           (fp_result < -3.4028235e38);
//            underflow = (fp_result != 0.0) &&
//                       (fp_result > -1.17549435e-38) &&
//                       (fp_result < 1.17549435e-38);
//        end

//        4'b0011: begin // c.eq.s
//            fp_cc = (fp_a == fp_b);
//            invalid = (fp_a != fp_a) || (fp_b != fp_b); // NaN comparison
//        end

//        4'b0100: begin // c.lt.s
//            fp_cc = (fp_a < fp_b);
//            invalid = (fp_a != fp_a) || (fp_b != fp_b); // NaN comparison
//        end

//        4'b0101: begin // c.le.s
//            fp_cc = (fp_a <= fp_b);
//            invalid = (fp_a != fp_a) || (fp_b != fp_b); // NaN comparison
//        end

//        4'b0110: begin // mov.s
//            result = a; // Simple bit copy
//        end

//        default: begin
//            result = 32'b0;
//            invalid = 1'b1;
//        end
//    endcase
//end




//endmodule





// IEEE 754 FPU Module (synthesizable, bit-level, single-cycle)
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