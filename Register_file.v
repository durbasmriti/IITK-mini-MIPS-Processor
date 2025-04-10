module register_file(
  input clk,
  input [4:0] rs, rt, rd, // 5-bit addresses for general-purpose registers
  input [4:0] frs, frt, frd, // 5-bit addresses for floating-point registers
  input [31:0] write_data, // Data to write to register
  input reg_write, // Control signal for writing
  input float_write, // Control signal for writing to floating-point registers
  output [31:0] read_data1, read_data2, // Output read data for general-purpose registers
  output [31:0] f_read_data1, f_read_data2 // Output read data for floating-point registers
);

  // Declare general-purpose registers (32 registers, 32-bit each)
  reg [31:0] regs[0:31];

  // Declare floating-point registers (32 registers, 32-bit each)
  reg [31:0] fp_regs[0:31];

  // Read data for general-purpose registers
  assign read_data1 = regs[rs];
  assign read_data2 = regs[rt];

  // Read data for floating-point registers
  assign f_read_data1 = fp_regs[frs];
  assign f_read_data2 = fp_regs[frt];

  // Write data to general-purpose registers
  always @(posedge clk) begin
    if (reg_write) begin
      regs[rd] <= write_data;
    end
  end

  // Write data to floating-point registers
  always @(posedge clk) begin
    if (float_write) begin
      fp_regs[frd] <= write_data;
    end
  end

endmodule

module ALU(
    input [31:0] a, b,
    input [3:0] alu_op,
    input is_float,
    output reg [31:0] result,
    output reg zero,
    output reg overflow,
    output reg carry_out
);

always @(*) begin
    zero = 0;
    overflow = 0;
    carry_out = 0;

    if (is_float) begin
        case(alu_op)
            4'b1001: result = $realtobits($bitstoreal(a) + $bitstoreal(b)); // add.s
            4'b1010: result = $realtobits($bitstoreal(a) - $bitstoreal(b)); // sub.s
            default: result = 32'b0;
        endcase
    end
    else begin
        // Integer operations
        case(alu_op)
            4'b0001: {carry_out, result} = a + b;          // add / addi / addu
            4'b0010: {carry_out, result} = a - b;          // sub / subu

//            4'b0011: result = a & b;                       // and / andi
//            4'b0100: result = a | b;                       // or / ori
//            4'b0101: result = a ^ b;                       // xor / xori
//            4'b0110: result = ~a;                          // not
//            4'b0111: result = a << b;                      // sll / sla (shift left)
//            4'b1000: result = a >> b;                      // srl / sra (shift right)

            // Overflow check
            4'b0001: begin
                // Addition
                overflow = (a[31] == b[31]) && (result[31] != a[31]);
            end

            4'b0010: begin
                // Subtraction
                overflow = (a[31] != b[31]) && (result[31] != a[31]);
            end

            default: result = 32'b0;
        endcase

        zero = (result == 32'b0); // Zero flag
    end
end

endmodule