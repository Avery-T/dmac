`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/07/2025 11:21:22 PM
// Design Name: 
// Module Name: top
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


`timescale 1ns / 1ps

module top_level (
  input logic clk,
  input logic rst_n,
  input logic start,
  input logic [31:0] src_addr,
  input logic [31:0] dst_addr,
  input logic [15:0] transfer_length
);

  // Signals for DMA controller
  logic busy, done;
  logic [31:0] dma_mem_addr;
  logic dma_mem_read, dma_mem_write;
  logic [31:0] dma_mem_data;

  // Signals for Memory module
  logic MEM_RDEN1, MEM_RDEN2, MEM_WE2;
  logic [13:0] MEM_ADDR1; // Instruction memory address (word-addressable)
  logic [31:0] MEM_ADDR2; // Data memory address (byte-addressable)
  logic [31:0] MEM_DIN2;  // Data to write
  logic [1:0] MEM_SIZE;   // Read/write size (byte, half-word, word)
  logic MEM_SIGN;         // Signed/unsigned extension
  logic IO_WR;            // IO write signal
  logic [31:0] MEM_DOUT1; // Instruction memory output
  logic [31:0] MEM_DOUT2; // Data memory output

  // Instantiate DMA controller
  simple_dma_controller dma_inst (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .src_addr(src_addr),
    .dst_addr(dst_addr),
    .transfer_length(transfer_length),
    .busy(busy),
    .done(done),
    .mem_addr(dma_mem_addr),
    .mem_read(dma_mem_read),
    .mem_write(dma_mem_write),
    .mem_data(dma_mem_data)
  );

  // Instantiate Memory module
  Memory mem_inst (
    .MEM_CLK(clk),
    .MEM_RDEN1(1'b0),              // Unused in this example
    .MEM_RDEN2(dma_mem_read),      // Connect DMA read signal
    .MEM_WE2(dma_mem_write),       // Connect DMA write signal
    .MEM_ADDR1(MEM_ADDR1),         // Instruction address (unused here)
    .MEM_ADDR2(dma_mem_addr),      // Connect DMA memory address
    .MEM_DIN2(dma_mem_data),       // Connect DMA data for writing
    .MEM_SIZE(MEM_SIZE),           // Set appropriate size (e.g., word = '2)
    .MEM_SIGN(MEM_SIGN),           // Set signed/unsigned extension
    .IO_IN(32'b0),                 // No external IO in this example
    .IO_WR(IO_WR),                 // IO write signal (unused here)
    .MEM_DOUT1(MEM_DOUT1),         // Instruction output (unused here)
    .MEM_DOUT2(dma_mem_data)       // Connect DMA data for reading
  );

endmodule
