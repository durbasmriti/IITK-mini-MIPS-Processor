`timescale 1ns / 1ps

module ALU_tb;

    // Inputs
    reg [31:0] a;
    reg [31:0] b;
    reg [3:0] alu_op;
    reg is_float;

    // Outputs
    wire [31:0] result;
    wire zero;
    wire fp_cc;
    wire overflow;
    wire carry_out;

    // Instantiate the ALU
    ALU uut (
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .is_float(is_float),
        .result(result),
        .zero(zero),
        .fp_cc(fp_cc),
        .overflow(overflow),
        .carry_out(carry_out)
    );

    // Test stimulus
    initial begin
        // Monitor signals
        $monitor("Time: %0t | a: %h | b: %h | alu_op: %b | is_float: %b | result: %h | zero: %b | overflow: %b | carry_out: %b | fp_cc: %b",
                 $time, a, b, alu_op, is_float, result, zero, overflow, carry_out, fp_cc);

        // Test integer addition
        a = 32'h00000010; b = 32'h00000020; alu_op = 4'b0001; is_float = 0;
        #10;

        // Test integer subtraction
        a = 32'h00000030; b = 32'h00000010; alu_op = 4'b0010; is_float = 0;
        #10;

        // Test integer AND
        a = 32'hF0F0F0F0; b = 32'h0F0F0F0F; alu_op = 4'b0110; is_float = 0;
        #10;

        // Test integer OR
        a = 32'hF0F0F0F0; b = 32'h0F0F0F0F; alu_op = 4'b0111; is_float = 0;
        #10;

        // Test integer SLT
        a = 32'h00000010; b = 32'h00000020; alu_op = 4'b1010; is_float = 0;
        #10;

        // Test floating-point addition
        a = 32'h3F800000; // 1.0 in IEEE 754
        b = 32'h40000000; // 2.0 in IEEE 754
        alu_op = 4'b0001; is_float = 1;
        #10;

        // Test floating-point subtraction
        a = 32'h40000000; // 2.0 in IEEE 754
        b = 32'h3F800000; // 1.0 in IEEE 754
        alu_op = 4'b0010; is_float = 1;
        #10;


        $finish;
    end

endmodule