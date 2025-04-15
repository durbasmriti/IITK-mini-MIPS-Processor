module floating_point_unit(
    input [31:0] a, b,          // Input operands
    input [3:0] fpu_op,         // Operation code from decoder
    output reg [31:0] result,   // Floating-point result
    output reg fp_cc,           // Comparison flag
    output reg invalid,         // Exception flags
    output reg overflow,
    output reg underflow
);

// Internal representations
real fp_a, fp_b;
real fp_result;

// Conversion functions
function real to_real;
    input [31:0] bits;
    reg sign;
    reg [7:0] exponent;
    reg [22:0] mantissa;
    real significand;
    begin
        sign = bits[31];
        exponent = bits[30:23];
        mantissa = bits[22:0];

        if (exponent == 8'hFF) begin
            if (mantissa == 0)
                to_real = sign ? -$inf : $inf;
            else
                to_real = $nan;
        end
        else if (exponent == 0) begin
            significand = $itor(mantissa) / (2.0**23);
            to_real = sign ? -significand : significand;
        end
        else begin
            significand = 1.0 + ($itor(mantissa) / (2.0**23));
            to_real = $ldexp(sign ? -significand : significand, exponent - 127);
        end
    end
endfunction

function [31:0] to_bits;
    input real value;
    reg sign;
    integer exponent;
    real abs_val;
    real mantissa;
    begin
        if (value == 0.0) begin
            to_bits = 32'h00000000;
        end
        else if (value != value) begin
            to_bits = 32'h7FC00000; // NaN
        end
        else if (value >= $inf) begin
            to_bits = 32'h7F800000; // +inf
        end
        else if (value <= -$inf) begin
            to_bits = 32'hFF800000; // -inf
        end
        else begin
            abs_val = value < 0.0 ? -value : value;
            sign = value < 0.0;
            exponent = 127;
            if (abs_val >= 2.0) begin
                while (abs_val >= 2.0 && exponent < 254) begin
                    abs_val = abs_val / 2.0;
                    exponent = exponent + 1;
                end
            end
            else if (abs_val < 1.0) begin
                while (abs_val < 1.0 && exponent > 0) begin
                    abs_val = abs_val * 2.0;
                    exponent = exponent - 1;
                end
            end
            mantissa = abs_val - 1.0;
            to_bits = {sign, exponent[7:0], mantissa[22:0]};
        end
    end
endfunction

always @(*) begin
    result = 32'b0;
    fp_cc = 1'b0;
    invalid = 1'b0;
    overflow = 1'b0;
    underflow = 1'b0;

    fp_a = to_real(a);
    fp_b = to_real(b);

    case(fpu_op)
        4'b0001: begin // add.s
            fp_result = fp_a + fp_b;
            result = to_bits(fp_result);
            overflow = (fp_result > 3.4028235e38 || fp_result < -3.4028235e38);
            underflow = (fp_result != 0.0) &&
                        (fp_result > -1.17549435e-38 && fp_result < 1.17549435e-38);
        end

        4'b0010: begin // sub.s
            fp_result = fp_a - fp_b;
            result = to_bits(fp_result);
            overflow = (fp_result > 3.4028235e38 || fp_result < -3.4028235e38);
            underflow = (fp_result != 0.0) &&
                        (fp_result > -1.17549435e-38 && fp_result < 1.17549435e-38);
        end

        4'b0011: begin // c.eq.s
            fp_cc = (fp_a == fp_b);
            invalid = (fp_a != fp_a) || (fp_b != fp_b); // NaN
        end

        4'b0100: begin // c.lt.s
            fp_cc = (fp_a < fp_b);
            invalid = (fp_a != fp_a) || (fp_b != fp_b); // NaN
        end

        4'b0101: begin // c.le.s
            fp_cc = (fp_a <= fp_b);
            invalid = (fp_a != fp_a) || (fp_b != fp_b); // NaN
        end

        4'b0110: begin // mov.s
            result = a;
        end

        4'b0111: begin // c.ge.s
            fp_cc = (fp_a >= fp_b);
            invalid = (fp_a != fp_a) || (fp_b != fp_b);
        end

        4'b1000: begin // c.gt.s
            fp_cc = (fp_a > fp_b);
            invalid = (fp_a != fp_a) || (fp_b != fp_b);
        end

        default: begin
            result = 32'b0;
            invalid = 1'b1;
        end
    endcase
end

endmodule


// module floating_point_unit(
//     input [31:0] a, b,          // Input operands
//     input [3:0] fpu_op,         // Operation code from decoder
//     output reg [31:0] result,   // Floating-point result
//     output reg fp_cc,              // Comparison flag
//     output reg invalid,         // Exception flags
//     output reg overflow,
//     output reg underflow
// );

// // Internal representations
// real fp_a, fp_b;
// real fp_result;

// // Conversion functions
// function real to_real;
//     input [31:0] bits;
//     reg sign;
//     reg [7:0] exponent;
//     reg [22:0] mantissa;
//     real significand;
//     begin
//         sign = bits[31];
//         exponent = bits[30:23];
//         mantissa = bits[22:0];

//         if (exponent == 8'hFF) begin // Special cases
//             if (mantissa == 0)
//                 to_real = sign ? -$infinity : $infinity;
//             else
//                 to_real = $nan;
//         end
//         else if (exponent == 0) begin // Denormal
//             significand = $itor(mantissa) / (2.0**23);
//             to_real = sign ? -significand : significand;
//         end
//         else begin // Normal numbers
//             significand = 1.0 + ($itor(mantissa) / (2.0**23));
//             to_real = $ldexp(sign ? -significand : significand, exponent - 127);
//         end
//     end
// endfunction

// function [31:0] to_bits;
//     input real value;
//     reg sign;
//     integer exponent;
//     real abs_val;
//     real mantissa;
//     begin
//         if (value == 0.0) begin
//             to_bits = 32'h00000000;
//         end
//         else if (value != value) begin // NaN
//             to_bits = 32'h7FC00000;
//         end
//         else if (value >= $infinity) begin
//             to_bits = 32'h7F800000;
//         end
//         else if (value <= -$infinity) begin
//             to_bits = 32'hFF800000;
//         end
//         else begin
//             abs_val = value < 0.0 ? -value : value;
//             sign = value < 0.0;

//             // Normalize
//             exponent = 127;
//             if (abs_val >= 2.0) begin
//                 while (abs_val >= 2.0 && exponent < 254) begin
//                     abs_val = abs_val / 2.0;
//                     exponent = exponent + 1;
//                 end
//             end
//             else if (abs_val < 1.0) begin
//                 while (abs_val < 1.0 && exponent > 0) begin
//                     abs_val = abs_val * 2.0;
//                     exponent = exponent - 1;
//                 end
//             end

//             mantissa = abs_val - 1.0; // Remove implicit leading 1
//             to_bits = {sign, exponent[7:0], mantissa[22:0]};
//         end
//     end
// endfunction

// always @(*) begin
//     // Default values
//     result = 32'b0;
//     fp_cc = 1'b0;
//     invalid = 1'b0;
//     overflow = 1'b0;
//     underflow = 1'b0;

//     // Convert inputs
//     fp_a = to_real(a);
//     fp_b = to_real(b);

//     case(fpu_op)
//         4'b0001: begin // add.s
//             fp_result = fp_a + fp_b;
//             result = to_bits(fp_result);

//             // Exception detection
//             overflow = (fp_result > $itor(3.4028235e38)) ||
//                       (fp_result < $itor(-3.4028235e38));
//             underflow = (fp_result != 0.0) &&
//                        (fp_result > -1.17549435e-38) &&
//                        (fp_result < 1.17549435e-38);
//         end

//         4'b0010: begin // sub.s
//             fp_result = fp_a - fp_b;
//             result = to_bits(fp_result);

//             overflow = (fp_result > $itor(3.4028235e38)) ||
//                       (fp_result < $itor(-3.4028235e38));
//             underflow = (fp_result != 0.0) &&
//                        (fp_result > -1.17549435e-38) &&
//                        (fp_result < 1.17549435e-38);
//         end

//         4'b0011: begin // c.eq.s
//             fp_cc = (fp_a == fp_b);
//             invalid = (fp_a != fp_a) || (fp_b != fp_b); // NaN comparison
//         end

//         4'b0100: begin // c.lt.s
//             fp_cc = (fp_a < fp_b);
//             invalid = (fp_a != fp_a) || (fp_b != fp_b); // NaN comparison
//         end

//         4'b0101: begin // c.le.s
//             fp_cc = (fp_a <= fp_b);
//             invalid = (fp_a != fp_a) || (fp_b != fp_b); // NaN comparison
//         end

//         4'b0110: begin // mov.s
//             result = a; // Simple bit copy
//         end

//         default: begin
//             result = 32'b0;
//             invalid = 1'b1;
//         end
//     endcase
// end

// endmodule
