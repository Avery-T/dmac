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


module top_tb(

    );
     logic        aclk=0;
     logic        aresetn=0;

    // AXI4-Lite Configuration Interface
    // Address bus from AXI interconnect to slave peripheral.
      logic [31:0] dma_s_axi_awaddr;
    //Valid signal, asserting that the S_AXI_AWADDR can be sampled by the slave peripheral.
      logic        dma_s_axi_awvalid;
    // Ready signal, indicating that the slave is ready to accept the value on S_AXI_AWADDR.
     logic [31:0] dma_s_axi_wdata;
     logic [3:0]  dma_s_axi_wstrb;
     logic        dma_s_axi_wvalid;
     logic        dma_s_axi_bready;
     logic [1:0]  dma_s_axi_bresp;
     logic dma_s_axi_wready; 
     
    logic        dma_s_axi_awready;

     logic [31:0] dma_s_axi_araddr;
     logic        dma_s_axi_arvalid;
     logic        dma_s_axi_arready;
     logic [31:0] dma_s_axi_rdata;
     logic [1:0]  dma_s_axi_rresp;
     logic        dma_s_axi_rvalid;
     logic        dma_s_axi_rready;
     logic        dma_s_axi_bvalid;
    
    
    
    //The wires for giving the dma data to write to memory
    logic [31:0] dma_m_axi_araddr;
    logic        dma_m_axi_arvalid;
    logic        dma_m_axi_arready; 
    logic [31:0] dma_m_axi_rdata;
    logic [1:0]  dma_m_axi_rresp;
    logic        dma_m_axi_rvalid;
    logic        dma_m_axi_rready;
    
    top_level top(.*);
 
    
 initial begin 
   aresetn =1; 
   #20
   
   aresetn = 0;
   
   /*** DMA CONFIGURATION ***/ 
   //Source address
   dma_s_axi_awaddr = 32'h0; //driven by master 00 is soruce
   dma_s_axi_awvalid =1;
   dma_s_axi_wvalid = 1;
   dma_s_axi_wdata = 32'h00002; //CPAR
   #20 //axi make you wait for ready but i dont want to do it
   
   //Dest address
   dma_s_axi_awaddr = 32'h4; 
   dma_s_axi_awvalid =1;
   dma_s_axi_wvalid = 1;
   dma_s_axi_wdata = 32'h0000; //CMAR
   #20 //axi make you wait for ready but i dont want to do it
   //transfer length 
   dma_s_axi_awaddr = 32'h8; 
   dma_s_axi_awvalid =1;
   dma_s_axi_wvalid = 1;
   dma_s_axi_wdata = 32'h0005; //CNDTR
   
   //start pulse
   #20 //axi make you wait for ready but i dont want to do it
   dma_s_axi_awaddr = 32'hC; 
   dma_s_axi_awvalid =1;
   dma_s_axi_wvalid = 1;
   dma_s_axi_wdata = 32'h0001; //start signal CCR->EN
   #20
   /*** Giving the DMA data ***/ 
   dma_m_axi_rvalid = 1; 
   dma_m_axi_arready = 1;
   dma_m_axi_rdata = 32'hDEAD;  
   dma_s_axi_wdata = 32'h0000; //0 turn off start pulse
   
 
 end
 always begin 
    #10
    aclk =~aclk; 
 end    
endmodule
