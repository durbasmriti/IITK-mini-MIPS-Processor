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
//
//////////////////////////////////////////////////////////////////////////////////

//module ALU(
//    input [31:0] a, b,
//    input [3:0] alu_op,
//    input is_float,
//    output reg [31:0] result,
//    output reg zero,
//    output reg overflow,
//    output reg carry_out,
//    output reg fp_cc        // Floating-point condition code
//);

//// Temporary variables for operations
//wire [32:0] add_result;
//wire [32:0] sub_result;
//real fp_a, fp_b;

//// Continuous assignments
//assign add_result = {1'b0, a} + {1'b0, b};
//assign sub_result = {1'b0, a} - {1'b0, b};
//assign fp_a = $bitstoreal(a);
//assign fp_b = $bitstoreal(b);

//always @(*) begin
//    // Default values
//    result = 32'b0;
//    zero = 1'b0;
//    overflow = 1'b0;
//    carry_out = 1'b0;
//    fp_cc = 1'b0;

//    if (is_float) begin
//        // Floating-point operations
//        case(alu_op)
//            4'b0001: begin // add.s
//                result = $realtobits(fp_a + fp_b); //there is a high chance realtobits will not work
//            end
//            4'b0010: begin // sub.s
//                result = $realtobits(fp_a - fp_b);
//            end
//            4'b0011: begin // c.eq.s
//                fp_cc = (fp_a == fp_b);
//            end
//            4'b0100: begin // c.lt.s
//                fp_cc = (fp_a < fp_b);
//            end
//            4'b0101: begin // c.le.s
//                fp_cc = (fp_a <= fp_b);
//            end
//            4'b0110: begin // mov.s
//                result = a;  // Direct copy
//            end
//            default: result = 32'b0;
//        endcase
//    end
//    else begin
//        // Integer operations
//        case(alu_op)
//            4'b0001: begin // add/addi/addu
//                result = add_result[31:0];
//                carry_out = add_result[32];
//                overflow = (a[31] == b[31]) && (result[31] != a[31]);
//            end
//            4'b0010: begin // sub/subu
//                result = sub_result[31:0];
//                carry_out = sub_result[32];
//                overflow = (a[31] != b[31]) && (result[31] != a[31]);
//            end
//            4'b0011: begin // madd
//                // Multiply-add (placeholder - would need multiplier implementation)
//                result = a + b; // Simplified for now
//            end
//            4'b0100: begin // maddu
//                result = a + b; // Unsigned version placeholder
//            end
//            4'b0101: begin // mul
//                result = a[15:0] * b[15:0]; // 16x16 multiplier (simplified)
//            end
//            4'b0110: begin // and/andi
//                result = a & b;
//            end
//            4'b0111: begin // or/ori
//                result = a | b;
//            end
//            4'b1000: begin // nor
//                result = ~(a | b);
//            end
//            4'b1001: begin // xor/xori
//                result = a ^ b;
//            end
//            4'b1010: begin // slt/slti
//                result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
//            end
//            4'b1011: begin // sltu/sltiu
//                result = (a < b) ? 32'd1 : 32'd0;
//            end
//            4'b1100: begin // sll
//                result = b << a;
//            end
//            4'b1101: begin // srl
//                result = b >> a;
//            end
//            4'b1110: begin // sra
//                result = $signed(b) >>> a;
//            end
//            4'b1111: begin // lui
//                result = {b[15:0], 16'b0};
//            end
//            default: result = 32'b0;
//        endcase

//        // Zero flag for integer operations
//        zero = (result == 32'b0);
//    end
//end

//endmodule


//module ALU(
//    input [31:0] a, b,             // 32-bit operands
//    input [3:0] alu_op,            // ALU operation
//    input is_float,                // Flag to indicate if operation is on floating-point numbers
//    output reg [31:0] result,      // 32-bit result
//    output reg zero,               // Zero flag
//    output reg overflow,           // Overflow flag
//    output reg carry_out,          // Carry-out flag
//    output reg fp_cc               // Floating-point condition code (e.g., for equality checks)
//);

//// Internal variables for floating-point operations
//real fp_a, fp_b;

//// Function to convert 32-bit IEEE 754 representation to real number
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

//        // Handle special cases (infinity and NaN)
//        if (exponent == 8'hFF) begin
//            if (mantissa == 0)
//                to_real = sign ? -$infinity : $infinity;
//            else
//                to_real = $nan;
//        end
//        else if (exponent == 0) begin // Denormalized numbers
//            significand = $itor(mantissa) / (2.0**23);
//            to_real = sign ? -significand : significand;
//        end
//        else begin // Normalized numbers
//            significand = 1.0 + ($itor(mantissa) / (2.0**23));
//            to_real = $ldexp(sign ? -significand : significand, exponent - 127);
//        end
//    end
//endfunction

//// Continuous assignments for converting 32-bit to real
//always @(*) begin
//    fp_a = to_real(a);  // Convert 'a' to real
//    fp_b = to_real(b);  // Convert 'b' to real

//    // Default values
//    result = 32'b0;
//    zero = 1'b0;
//    overflow = 1'b0;
//    carry_out = 1'b0;
//    fp_cc = 1'b0;

//    if (is_float) begin
//        // Floating-point operations
//        case(alu_op)
//            4'b0001: begin // add.s
//                result = $realtobits(fp_a + fp_b); // Add and convert back to bits
//            end
//            4'b0010: begin // sub.s
//                result = $realtobits(fp_a - fp_b);
//            end
//            4'b0011: begin // c.eq.s
//                fp_cc = (fp_a == fp_b);  // Floating-point equality check
//            end
//            4'b0100: begin // c.lt.s
//                fp_cc = (fp_a < fp_b);  // Floating-point less-than check
//            end
//            4'b0101: begin // c.le.s
//                fp_cc = (fp_a <= fp_b); // Floating-point less-than-or-equal check
//            end
//            4'b0110: begin // mov.s
//                result = a;  // Direct copy of the 32-bit value
//            end
//            default: result = 32'b0;
//        endcase
//    end
//    else begin
//        // Integer operations
//        case(alu_op)
//            4'b0001: begin // add/addi/addu
//                result = a + b;
//                carry_out = (a + b) > 32'hFFFFFFFF;
//                overflow = (a[31] == b[31]) && (result[31] != a[31]);
//            end
//            4'b0010: begin // sub/subu
//                result = a - b;
//                carry_out = (a < b);
//                overflow = (a[31] != b[31]) && (result[31] != a[31]);
//            end
//            4'b0011: begin // madd (simplified, needs multiplier)
//                result = a + b; // placeholder
//            end
//            4'b0100: begin // maddu (simplified, needs multiplier)
//                result = a + b; // placeholder
//            end
//            4'b0101: begin // mul
//                result = a[15:0] * b[15:0]; // simplified 16x16 multiplier
//            end
//            4'b0110: begin // and/andi
//                result = a & b;
//            end
//            4'b0111: begin // or/ori
//                result = a | b;
//            end
//            4'b1000: begin // nor
//                result = ~(a | b);
//            end
//            4'b1001: begin // xor/xori
//                result = a ^ b;
//            end
//            4'b1010: begin // slt/slti
//                result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
//            end
//            4'b1011: begin // sltu/sltiu
//                result = (a < b) ? 32'd1 : 32'd0;
//            end
//            4'b1100: begin // sll
//                result = b << a;
//            end
//            4'b1101: begin // srl
//                result = b >> a;
//            end
//            4'b1110: begin // sra
//                result = $signed(b) >>> a;
//            end
//            4'b1111: begin // lui
//                result = {b[15:0], 16'b0};
//            end
//            default: result = 32'b0;
//        endcase

//        // Zero flag for integer operations
//        zero = (result == 32'b0);
//    end
//end

//endmodule


module ALU (
    input [31:0] a,
    input [31:0] b,
    input [3:0] alu_op,
    input is_float,
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
