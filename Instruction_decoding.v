`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04/09/2025 02:31:52 PM
// Design Name:
// Module Name: Instruction_decoding
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

//module Instruction_decoding(
//    input [31:0] instruction,
//    input [31:0] pc_plus_4,output reg [5:0] opcode,
//    output reg [4:0] rs, rt, rd, shamt,
//    output reg [5:0] funct,output reg [15:0] imm16,
//    output reg [25:0] target,
//    output reg reg_write,
//    output reg mem_read,output reg mem_write,
//    output reg branch,
//    output reg jump,output reg alu_src,
//    output reg [3:0] alu_op,
//    output reg mem_to_reg,output reg is_float,
//    output reg reg_dst,
//    output reg[1:0] jump_src,
//    output reg mfc1, output reg mtc1
//);

//always @(*) begin
//    reg_write = 0;
//    mem_read = 0;
//    mem_write = 0;
//    branch = 0;
//    jump = 0;
//    alu_src = 0;
//    alu_op = 4'b0000;
//    mem_to_reg = 0;
//    is_float = 0;
//    reg_dst = 0;
//    jump_src = 2'b00;
//    mfc1 = 0;
//    mtc1 = 0;

//    // Instruction fields
//    opcode = instruction[31:26];
//    rs = instruction[25:21];
//    rt = instruction[20:16];
//    rd = instruction[15:11];
//    shamt = instruction[10:6];
//    funct = instruction[5:0];
//    imm16 = instruction[15:0]; //I type
//    target = instruction[25:0]; //J type

//    case(opcode)
//        // R-type instructions
//        6'b000000:
//            case(funct)
//                // Arithmetic
//                6'b100000: begin // add
//                    reg_write = 1;
//                    alu_op = 4'b0001;
//                end
//                6'b100010: begin // sub
//                    reg_write = 1;
//                    alu_op = 4'b0010;
//                end
//                6'b100001: begin // addu
//                    reg_write = 1;
//                    alu_op = 4'b0001;
//                end
//                6'b100011: begin // subu
//                    reg_write = 1;
//                    alu_op = 4'b0010;
//                end
//                6'b111100: begin // madd
//                    reg_write = 1;
//                    alu_op = 4'b0011; // Multiplication and addition
//                end
//                6'b111101: begin // maddu
//                    reg_write = 1;
//                    alu_op = 4'b0100; // Unsigned multiplication and addition
//                end
//                6'b011000: begin // mul
//                    reg_write = 1;
//                    alu_op = 4'b0101; // Multiplication
//                end
//                // Bitwise operations
//                6'b100100: begin // and
//                    reg_write = 1;
//                    alu_op = 4'b0110;
//                end
//                6'b100101: begin // or
//                    reg_write = 1;
//                    alu_op = 4'b0111;
//                end
//                6'b100111: begin // nor
//                    reg_write = 1;
//                    alu_op = 4'b1000;
//                end
//                6'b100110: begin // xor
//                    reg_write = 1;
//                    alu_op = 4'b1001;
//                end
//                6'b101010: begin // slt
//                    reg_write = 1;
//                    alu_op = 4'b1010;
//                end
//                6'b101011: begin // sltu
//                    reg_write = 1;
//                    alu_op = 4'b1011;
//                end
//                // Shifting operations
//                6'b000000: begin // sll
//                    reg_write = 1;
//                    alu_op = 4'b1110;
//                end
//                6'b000010: begin // srl
//                    reg_write = 1;
//                    alu_op = 4'b1111;
//                end
//                6'b000011: begin // sra
//                    reg_write = 1;
//                    alu_op = 4'b1111;
//                end
//                6'b000100: begin // sla
//                    reg_write = 1;
//                    alu_op = 4'b1110;
//                end
//                6'b001000: begin // jr
//                    jump = 1;
//                    jump_src = 2'b10; // Jump to register value
//                end
//            endcase

//        // I-type instructions
//        6'b001000: begin // addi
//            reg_write = 1;
//            alu_src = 1;
//            alu_op = 4'b0001;
//        end
//        6'b001001: begin // addiu
//            reg_write = 1;
//            alu_src = 1;
//            alu_op = 4'b0001;
//        end
//        6'b001100: begin // andi
//            reg_write = 1;
//            alu_src = 1;
//            alu_op = 4'b0110;
//        end
//        6'b001101: begin // ori
//            reg_write = 1;
//            alu_src = 1;
//            alu_op = 4'b0111;
//        end
//        6'b001110: begin // xori
//            reg_write = 1;
//            alu_src = 1;
//            alu_op = 4'b1001;
//        end
//        6'b100000: begin // lw
//            reg_write = 1;
//            alu_src = 1;
//            mem_read = 1;
//            mem_to_reg = 1;
//            alu_op = 4'b0001;
//        end
//        6'b101000: begin // sw
//            alu_src = 1;
//            mem_write = 1;
//            alu_op = 4'b0001;
//        end
//        6'b001111: begin // lui
//            reg_write = 1;
//            alu_src = 1;
//            alu_op = 4'b1100;
//        end
//        //Branches
//        6'b000100: begin // beq
//        branch = 1;
//        end
//        6'b000101: begin // bne
//            branch = 1;
//        end
//        6'b000110: begin // bgt
//            branch = 1;
//        end
//        6'b000111: begin // bgte
//            branch = 1;
//        end
//        6'b001000: begin // ble
//            branch = 1;
//        end
//        6'b001001: begin // bleq
//            branch = 1;
//        end
//        6'b001010: begin // bleu
//            branch = 1;
//        end
//        6'b001011: begin // bgtu
//            branch = 1;
//        end
//        //bleq, bleu, bgtu done

//        // J-type instructions
//        6'b000010: begin // j
//            jump = 1;
//        end
//        6'b000011: begin // jal
//            jump = 1;
//            reg_write = 1;
//        end

//        // Floating point instructions
//        6'b110000: begin // add.s
//            is_float = 1;
//            reg_write = 1;
//            alu_op = 4'b0001;
//        end
//        6'b110001: begin // sub.s
//            is_float = 1;
//            reg_write = 1;
//            alu_op = 4'b0010;
//        end
//        6'b110010: begin // c.eq.s
//            is_float = 1;
//            alu_op = 4'b0011;
//        end
//        6'b110011: begin // c.lt.s
//            is_float = 1;
//            alu_op = 4'b0100;
//        end
//        6'b110100: begin // c.le.s
//            is_float = 1;
//            alu_op = 4'b0101;
//        end
//        6'b110101: begin // mov.s
//            is_float = 1;
//            reg_write = 1;
//            alu_op = 4'b0110;
//        end
//        6'b110110: begin // mfc1
//            is_float = 1;
//            reg_write = 1;
//            mfc1 = 1;
//        end
//        6'b110111: begin // mtc1
//            is_float = 1;
//            mtc1 = 1;
//        end
//    endcase
//end

//endmodule




module Instruction_decoding(
    input [31:0] instruction,
    input [31:0] pc_plus_4,
    output reg [5:0] opcode,
    output reg [4:0] rs, rt, rd, shamt,
    output reg [5:0] funct,
    output reg [15:0] imm16,
    output reg [25:0] target,
    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg branch,
    output reg jump,
    output reg alu_src,
    output reg [3:0] alu_op,
    output reg mem_to_reg,
    output reg is_float,
    output reg reg_dst,
    output reg [1:0] jump_src,
    output reg mfc1,
    output reg mtc1
);

always @(*) begin
    // Reset all control signals
    reg_write = 0;
    mem_read = 0;
    mem_write = 0;
    branch = 0;
    jump = 0;
    alu_src = 0;
    alu_op = 4'b0000;
    mem_to_reg = 0;
    is_float = 0;
    reg_dst = 0;
    jump_src = 2'b00;
    mfc1 = 0;
    mtc1 = 0;

    // Instruction fields
    opcode = instruction[31:26];
    rs = instruction[25:21];
    rt = instruction[20:16];
    rd = instruction[15:11];
    shamt = instruction[10:6];
    funct = instruction[5:0];
    imm16 = instruction[15:0];
    target = instruction[25:0];

    case(opcode)
        // R-type instructions
        6'b000000:
            case(funct)
                6'b100000: begin // add
                    reg_write = 1;
                    reg_dst = 1;
                    alu_op = 4'b0001;
                end
                6'b100010: begin // sub
                    reg_write = 1;
                    reg_dst = 1;
                    alu_op = 4'b0010;
                end
                6'b100001: begin // addu
                    reg_write = 1;
                    reg_dst = 1;
                    alu_op = 4'b0001;
                end
                6'b100011: begin // subu
                    reg_write = 1;
                    reg_dst = 1;
                    alu_op = 4'b0010;
                end
                6'b111100: begin // madd
                    reg_write = 1;
                    reg_dst = 1;
                    alu_op = 4'b0011;
                end
                6'b111101: begin // maddu
                    reg_write = 1;
                    reg_dst = 1;
                    alu_op = 4'b0100;
                end
                6'b011000: begin // mul
                    reg_write = 1;
                    reg_dst = 1;
                    alu_op = 4'b0101;
                end
                6'b100100: begin // and
                    reg_write = 1;
                    reg_dst = 1;
                    alu_op = 4'b0110;
                end
                6'b100101: begin // or
                    reg_write = 1;
                    reg_dst = 1;
                    alu_op = 4'b0111;
                end
                6'b100111: begin // nor
                    reg_write = 1;
                    reg_dst = 1;
                    alu_op = 4'b1000;
                end
                6'b100110: begin // xor
                    reg_write = 1;
                    reg_dst = 1;
                    alu_op = 4'b1001;
                end
                6'b101010: begin // slt
                    reg_write = 1;
                    reg_dst = 1;
                    alu_op = 4'b1010;
                end
                6'b101011: begin // sltu
                    reg_write = 1;
                    reg_dst = 1;
                    alu_op = 4'b1011;
                end
                6'b000000: begin // sll
                    reg_write = 1;
                    reg_dst = 1;
                    alu_op = 4'b1110;
                end
                6'b000010: begin // srl
                    reg_write = 1;
                    reg_dst = 1;
                    alu_op = 4'b1111;
                end
                6'b000011: begin // sra
                    reg_write = 1;
                    reg_dst = 1;
                    alu_op = 4'b1111;
                end
                6'b000100: begin // sla
                    reg_write = 1;
                    reg_dst = 1;
                    alu_op = 4'b1110;
                end
                6'b001000: begin // jr
                    jump = 1;
                    jump_src = 2'b10;
                end
            endcase

        // I-type instructions
        6'b001000: begin // addi
            reg_write = 1;
            alu_src = 1;
            alu_op = 4'b0001;
        end
        6'b001001: begin // addiu
            reg_write = 1;
            alu_src = 1;
            alu_op = 4'b0001;
        end
        6'b001100: begin // andi
            reg_write = 1;
            alu_src = 1;
            alu_op = 4'b0110;
        end
        6'b001101: begin // ori
            reg_write = 1;
            alu_src = 1;
            alu_op = 4'b0111;
        end
        6'b001110: begin // xori
            reg_write = 1;
            alu_src = 1;
            alu_op = 4'b1001;
        end
        6'b100000: begin // lw
            reg_write = 1;
            alu_src = 1;
            mem_read = 1;
            mem_to_reg = 1;
            alu_op = 4'b0001;
        end
        6'b101000: begin // sw
            alu_src = 1;
            mem_write = 1;
            alu_op = 4'b0001;
        end
        6'b001111: begin // lui
            reg_write = 1;
            alu_src = 1;
            alu_op = 4'b1100;
        end

        // Branches
        6'b000100, // beq
        6'b000101, // bne
        6'b000110, // bgt
        6'b000111, // bgte
        6'b001000, // ble
        6'b001001, // bleq
        6'b001010, // bleu
        6'b001011: // bgtu
        begin
            branch = 1;
        end

        // J-type
        6'b000010: begin // j
            jump = 1;
        end
        6'b000011: begin // jal
            jump = 1;
            reg_write = 1;
        end

        // Floating point instructions
        6'b110000: begin // add.s
            is_float = 1;
            reg_write = 1;
            alu_op = 4'b0001;
        end
        6'b110001: begin // sub.s
            is_float = 1;
            reg_write = 1;
            alu_op = 4'b0010;
        end
        6'b110010: begin // c.eq.s
            is_float = 1;
            alu_op = 4'b0011;
        end
        6'b110011: begin // c.lt.s
            is_float = 1;
            alu_op = 4'b0100;
        end
        6'b110100: begin // c.le.s
            is_float = 1;
            alu_op = 4'b0101;
        end
        6'b110101: begin // mov.s
            is_float = 1;
            reg_write = 1;
            alu_op = 4'b0110;
        end
        6'b110110: begin // mfc1
            is_float = 1;
            reg_write = 1;
            mfc1 = 1;
        end
        6'b110111: begin // mtc1
            is_float = 1;
            mtc1 = 1;
        end

        default: begin
            // Reset signals in case of unrecognized instruction
            reg_write = 0;
            mem_read = 0;
            mem_write = 0;
            branch = 0;
            jump = 0;
            alu_src = 0;
            alu_op = 4'b0000;
            mem_to_reg = 0;
            is_float = 0;
            reg_dst = 0;
            jump_src = 2'b00;
            mfc1 = 0;
            mtc1 = 0;
        end
    endcase
end

endmodule