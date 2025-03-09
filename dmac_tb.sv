`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2025 04:03:24 PM
// Design Name: 
// Module Name: dma_tb
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


module dma_tb(

    );
    logic clk=0, rst_n, start;
    logic [31:0] src_addr
    logic [31:0] dst_addr;
    logic [15:0] transfer_length;
    top dmac(.*);
    
 initial begin 
    rst_n =1; 
    #20
    rst_n = 0; 
    start = 1;
    #13
    start = 0;
    src_addr = 0; 
    dest_addr = 143100; 
 
 end
 always begin 
    #10
    clk =~clk; 
 
 end    
endmodule
