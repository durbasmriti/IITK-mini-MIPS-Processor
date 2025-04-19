`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04/15/2025 06:19:50 PM
// Design Name:
// Module Name: data_memory
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


module data_memory (
    input clk,
    input reset,
    input mem_read,
    input mem_write,
    input [31:0] address,
    input [31:0] write_data,
    output reg [31:0] read_data
);

    // Declare memory with 256 locations
    reg [31:0] memory [0:255];

    always @(posedge clk or posedge reset) begin
        if (reset) begin:my_block
            // Reset all memory values to 0
            integer i;
            for (i = 0; i < 256; i = i + 1) begin
                memory[i] <= 32'b0;
            end
        end:my_block
        else begin
            // Memory read operation
            if (mem_read) begin
                read_data <= memory[address[7:0]]; // Using lower 8 bits of address as memory index
            end

            // Memory write operation
            if (mem_write) begin
                memory[address[7:0]] <= write_data; // Store the write data at the address location
            end
        end
    end
endmodule