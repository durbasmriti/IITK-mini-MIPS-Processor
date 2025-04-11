module Instruction_fetch(
    input clk,
    input reset,
    input [31:0] branch_target,
    input branch_taken,
    output [31:0] instruction,
    output [31:0] pc_plus_4
);

reg [31:0] PC;
wire [31:0] next_pc;
reg [31:0] inst_mem [0:64];

// PC update logic
assign next_pc = branch_taken ? branch_target : (PC + 4);
assign pc_plus_4 = PC + 4;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        PC <= 32'h0000_0000;
    end else begin
        PC <= next_pc;
    end
end

// Instruction memory read
assign instruction = inst_mem[PC[15:2]]; // Word-aligned access

endmodule

//added a slightly modified version below, to include jump targets

// module Instruction_fetch(
//     input clk,
//     input reset,
//     input [31:0] branch_target,
//     input branch_taken,
//     input jump_taken,
//     input [31:0] jump_target,
//     output [31:0] instruction,
//     output [31:0] pc_plus_4
// );

// parameter MEM_SIZE = 1024; // 1024 words = 4KB
// localparam ADDR_WIDTH = $clog2(MEM_SIZE);

// reg [31:0] PC;
// wire [31:0] next_pc;
// reg [31:0] inst_mem [0:MEM_SIZE-1];

// // Initialize instruction memory
// initial begin
//     for (integer i = 0; i < MEM_SIZE; i = i + 1)
//         inst_mem[i] = 32'h00000000; 
// end

// // PC update logic
// assign next_pc = jump_taken ? jump_target : 
//                 (branch_taken ? branch_target : (PC + 4));
// assign pc_plus_4 = PC + 4;

// always @(posedge clk or posedge reset) begin
//     if (reset) begin
//         PC <= 32'h0000_0000;
//     end else begin
//         PC <= next_pc;
//     end
// end

// // Instruction memory read with alignment check
// wire address_ok = (PC[1:0] == 2'b00); // Check word-aligned
// wire [ADDR_WIDTH-1:0] mem_addr = PC[ADDR_WIDTH+1:2];
// assign instruction = address_ok ? inst_mem[mem_addr] : 32'h00000000;

// endmodule
