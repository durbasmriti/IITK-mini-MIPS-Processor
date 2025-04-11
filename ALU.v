// module ALU(
//     input [31:0] a, b,
//     input [3:0] alu_op,
//     input is_float,
//     output reg [31:0] result,
//     output reg zero,
//     output reg overflow,
//     output reg carry_out
//     output reg fp_cc
// );

// always @(*) begin
//     zero = 0;
//     overflow = 0;
//     carry_out = 0;

//     if (is_float) begin
//         case(alu_op)
//             4'b1001: result = $realtobits($bitstoreal(a) + $bitstoreal(b)); // add.s
//             4'b1010: result = $realtobits($bitstoreal(a) - $bitstoreal(b)); // sub.s
//             default: result = 32'b0;
//         endcase
//     end
//     else begin
//         // Integer operations
//         case(alu_op)
//             4'b0001: {carry_out, result} = a + b;          // add / addi / addu
//             4'b0010: {carry_out, result} = a - b;          // sub / subu


//             // Overflow check
//             4'b0001: begin
//                 // Addition
//                 overflow = (a[31] == b[31]) && (result[31] != a[31]);
//             end

//             4'b0010: begin
//                 // Subtraction
//                 overflow = (a[31] != b[31]) && (result[31] != a[31]);
//             end

//             default: result = 32'b0;
//         endcase

//         zero = (result == 32'b0); // Zero flag
//     end
// end

// endmodule


module ALU(
    input [31:0] a, b,
    input [3:0] alu_op,
    input is_float,
    output reg [31:0] result,
    output reg zero,
    output reg overflow,
    output reg carry_out,
    output reg fp_cc        // Floating-point condition code
);

// Temporary variables for operations
wire [32:0] add_result;
wire [32:0] sub_result;
real fp_a, fp_b;

// Continuous assignments
assign add_result = {1'b0, a} + {1'b0, b};
assign sub_result = {1'b0, a} - {1'b0, b};
assign fp_a = $bitstoreal(a);
assign fp_b = $bitstoreal(b);

always @(*) begin
    // Default values
    result = 32'b0;
    zero = 1'b0;
    overflow = 1'b0;
    carry_out = 1'b0;
    fp_cc = 1'b0;

    if (is_float) begin
        // Floating-point operations
        case(alu_op)
            4'b0001: begin // add.s
                result = $realtobits(fp_a + fp_b);
            end
            4'b0010: begin // sub.s
                result = $realtobits(fp_a - fp_b);
            end
            4'b0011: begin // c.eq.s
                fp_cc = (fp_a == fp_b);
            end
            4'b0100: begin // c.lt.s
                fp_cc = (fp_a < fp_b);
            end
            4'b0101: begin // c.le.s
                fp_cc = (fp_a <= fp_b);
            end
            4'b0110: begin // mov.s
                result = a;  // Direct copy
            end
            default: result = 32'b0;
        endcase
    end
    else begin
        // Integer operations
        case(alu_op)
            4'b0001: begin // add/addi/addu
                result = add_result[31:0];
                carry_out = add_result[32];
                overflow = (a[31] == b[31]) && (result[31] != a[31]);
            end
            4'b0010: begin // sub/subu
                result = sub_result[31:0];
                carry_out = sub_result[32];
                overflow = (a[31] != b[31]) && (result[31] != a[31]);
            end
            4'b0011: begin // madd
                // Multiply-add (placeholder - would need multiplier implementation)
                result = a + b; // Simplified for now
            end
            4'b0100: begin // maddu
                result = a + b; // Unsigned version placeholder
            end
            4'b0101: begin // mul
                result = a[15:0] * b[15:0]; // 16x16 multiplier (simplified)
            end
            4'b0110: begin // and/andi
                result = a & b;
            end
            4'b0111: begin // or/ori
                result = a | b;
            end
            4'b1000: begin // nor
                result = ~(a | b);
            end
            4'b1001: begin // xor/xori
                result = a ^ b;
            end
            4'b1010: begin // slt/slti
                result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            end
            4'b1011: begin // sltu/sltiu
                result = (a < b) ? 32'd1 : 32'd0;
            end
            4'b1100: begin // sll
                result = b << a;
            end
            4'b1101: begin // srl
                result = b >> a;
            end
            4'b1110: begin // sra
                result = $signed(b) >>> a;
            end
            4'b1111: begin // lui
                result = {b[15:0], 16'b0};
            end
            default: result = 32'b0;
        endcase

        // Zero flag for integer operations
        zero = (result == 32'b0);
    end
end

endmodule