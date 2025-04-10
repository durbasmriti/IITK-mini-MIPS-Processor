module top_module(input clk, input reset);
  // Wire declarations for connections between modules
  wire [31:0] instruction, pc, pc_plus_4;
  wire [31:0] read_data1, read_data2, alu_result, immediate, branch_target;
  wire [4:0] rs, rt, rd;
  wire [5:0] opcode, funct;
  wire reg_write, mem_read, mem_write, branch, jump, alu_src, mem_to_reg, is_float;
  wire [3:0] alu_op;
  wire branch_taken;

  // Instruction Fetch (IF) Module
  Instruction_fetch IF (
    .clk(clk),
    .reset(reset),
    .branch_target(branch_target),
    .branch_taken(branch_taken),
    .instruction(instruction),
    .pc_plus_4(pc_plus_4)
  );

  // Instruction Decoding (ID) Module
  Instruction_decoding ID (
    .instruction(instruction),
    .pc_plus_4(pc_plus_4),
    .opcode(opcode),
    .rs(rs),
    .rt(rt),
    .rd(rd),
    .funct(funct),
    .imm16(immediate),
    .target(),
    .reg_write(reg_write),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .branch(branch),
    .jump(jump),
    .alu_src(alu_src),
    .alu_op(alu_op),
    .mem_to_reg(mem_to_reg),
    .is_float(is_float)
  );

  // Register File (RF) Module
  register_file RF (
    .clk(clk),
    .rs(rs),
    .rt(rt),
    .rd(rd),
    .write_data(alu_result), // Write data is from ALU result
    .reg_write(reg_write),
    .float_write(mem_write), // Assuming mem_write indicates float_write
    .read_data1(read_data1),
    .read_data2(read_data2),
    .f_read_data1(),
    .f_read_data2()
  );

  // ALU Module
  ALU alu (
    .a(read_data1),
    .b(read_data2),
    .alu_op(alu_op),
    .is_float(is_float),
    .result(alu_result),
    .zero(),
    .overflow(),
    .carry_out()
  );

  // Branch Unit
  Branch_unit branch_unit (
    .rs_data(read_data1),
    .rt_data(read_data2),
    .imm16(immediate),
    .opcode(opcode),
    .branch_taken(branch_taken),
    .branch_target(branch_target)
  );

endmodule