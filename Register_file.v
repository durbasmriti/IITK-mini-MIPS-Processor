// module register_file(
//   input clk,
//   input [4:0] rs, rt, rd, // 5-bit addresses for general-purpose registers
//   input [4:0] frs, frt, frd, // 5-bit addresses for floating-point registers
//   input [31:0] write_data, // Data to write to register
//   input reg_write, // Control signal for writing
//   input float_write, // Control signal for writing to floating-point registers
//   output [31:0] read_data1, read_data2, // Output read data for general-purpose registers
//   output [31:0] f_read_data1, f_read_data2 // Output read data for floating-point registers
// );

//   // Declare general-purpose registers (32 registers, 32-bit each)
//   reg [31:0] regs[0:31];

//   // Declare floating-point registers (32 registers, 32-bit each)
//   reg [31:0] fp_regs[0:31];

//   // Read data for general-purpose registers
//   assign read_data1 = regs[rs];
//   assign read_data2 = regs[rt];

//   // Read data for floating-point registers
//   assign f_read_data1 = fp_regs[frs];
//   assign f_read_data2 = fp_regs[frt];

//   // Write data to general-purpose registers
//   always @(posedge clk) begin
//     if (reg_write) begin
//       regs[rd] <= write_data;
//     end
//   end

//   // Write data to floating-point registers
//   always @(posedge clk) begin
//     if (float_write) begin
//       fp_regs[frd] <= write_data;
//     end
//   end

// endmodule

// module ALU(
//     input [31:0] a, b,
//     input [3:0] alu_op,
//     input is_float,
//     output reg [31:0] result,
//     output reg zero,
//     output reg overflow,
//     output reg carry_out
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

// //            4'b0011: result = a & b;                       // and / andi
// //            4'b0100: result = a | b;                       // or / ori
// //            4'b0101: result = a ^ b;                       // xor / xori
// //            4'b0110: result = ~a;                          // not
// //            4'b0111: result = a << b;                      // sll / sla (shift left)
// //            4'b1000: result = a >> b;                      // srl / sra (shift right)

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


module register_file(
    input clk,
    input reset,

    // General Purpose Register (GPR) ports
    input [4:0] gpr_read_addr1,
    input [4:0] gpr_read_addr2,
    output reg [31:0] gpr_read_data1,
    output reg [31:0] gpr_read_data2,

    input [4:0] gpr_write_addr,
    input [31:0] gpr_write_data,
    input gpr_write_en,

    // Floating-Point Register ports
    input [4:0] fpr_read_addr1,
    input [4:0] fpr_read_addr2,
    output reg [31:0] fpr_read_data1,
    output reg [31:0] fpr_read_data2,

    input [4:0] fpr_write_addr,
    input [31:0] fpr_write_data,
    input fpr_write_en,

    //move instructions
    input mtc1_en,        // Move to FPR from GPR
    input mfc1_en,        // Move to GPR from FPR
    input [4:0] move_reg  // Register number for move ops
);

// 32 General Purpose Registers
reg [31:0] gpr [0:31];

// 32 Floating Point Registers
reg [31:0] fpr [0:31];

// GPR Read Operation
always @(*) begin
    // Read port 1
    if (gpr_read_addr1 == 5'b0)
        gpr_read_data1 = 32'b0; // $zero register
    else
        gpr_read_data1 = gpr[gpr_read_addr1];

    // Read port 2
    if (gpr_read_addr2 == 5'b0)
        gpr_read_data2 = 32'b0; // $zero register
    else
        gpr_read_data2 = gpr[gpr_read_addr2];
end

// FPR Read Operation
always @(*) begin
    fpr_read_data1 = fpr[fpr_read_addr1];
    fpr_read_data2 = fpr[fpr_read_addr2];
end

// GPR Write Operation
always @(posedge clk or posedge reset) begin
    if (reset) begin
        // Initialize registers to 0 on reset
        for (integer i = 0; i < 32; i = i + 1)
          gpr[i] <= 32'b0;

        gpr[29] <= 32'h80000000;  // $sp
        gpr[28] <= 32'h10008000;  // $gp
        gpr[30] <= 32'h00000000;  // $fp
    end
    else begin
        // Normal write operation
        if (gpr_write_en && (gpr_write_addr != 5'b0)) begin
            gpr[gpr_write_addr] <= gpr_write_data;
        end

        // Move from FPR to GPR (mfc1)
        if (mfc1_en && (move_reg != 5'b0)) begin
            gpr[move_reg] <= fpr[fpr_read_addr1];
        end
    end
end

// FPR Write Operation
always @(posedge clk or posedge reset) begin
    if (reset) begin
        // Initialize registers to 0 on reset
        for (integer i = 0; i < 32; i = i + 1)
            fpr[i] <= 32'b0;
    end
    else begin
        // Normal write operation
        if (fpr_write_en) begin
            fpr[fpr_write_addr] <= fpr_write_data;
        end

        // Move from GPR to FPR (mtc1)
        if (mtc1_en) begin
            fpr[move_reg] <= gpr[gpr_read_addr1];
        end
    end
end


endmodule