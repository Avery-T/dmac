`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2025
// Design Name: Top-Level Module
// Module Name: top_level
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Top-level module connecting simple_memory and simple_dma_axi4lite.
// 
// Dependencies: 
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module top_level (
    input  logic        aclk,
    input  logic        aresetn,

    // AXI4-Lite Configuration Interface
    // Address bus from AXI interconnect to slave peripheral.
    input  logic [31:0] dma_s_axi_awaddr,
    //Valid signal, asserting that the S_AXI_AWADDR can be sampled by the slave peripheral.
    input  logic        dma_s_axi_awvalid,
    // Ready signal, indicating that the slave is ready to accept the value on S_AXI_AWADDR.
    output logic        dma_s_axi_awready,
    input  logic [31:0] dma_s_axi_wdata,
    input  logic [3:0]  dma_s_axi_wstrb,
    input  logic        dma_s_axi_wvalid,
    output logic        dma_s_axi_wready,
    output logic [1:0]  dma_s_axi_bresp,
    output logic        dma_s_axi_bvalid,
    input  logic        dma_s_axi_bready,

    input  logic [31:0] dma_s_axi_araddr,
    input  logic        dma_s_axi_arvalid,
    output logic        dma_s_axi_arready,
    output logic [31:0] dma_s_axi_rdata,
    output logic [1:0]  dma_s_axi_rresp,
    output logic        dma_s_axi_rvalid,
    input  logic        dma_s_axi_rready,
    
    //THE DATA the DMA is READING ***it only writes to the memory
    
    output logic [31:0] dma_m_axi_araddr,
    output logic        dma_m_axi_arvalid,
    input  logic        dma_m_axi_arready, 
    input  logic [31:0] dma_m_axi_rdata, 
    input  logic [1:0]  dma_m_axi_rresp,
    input  logic        dma_m_axi_rvalid,
    output logic        dma_m_axi_rready
    
    
    
    
    
);

    // Internal signals for AXI4-Lite connection between DMA and memory
    wire [31:0] dma_m_axi_awaddr;
    wire dma_m_axi_awvalid;
    wire dma_m_axi_awready;
    wire [31:0] dma_m_axi_wdata;
    wire [3:0] dma_m_axi_wstrb;
    wire dma_m_axi_wvalid;
    wire dma_m_axi_wready;
    wire [1:0] dma_m_axi_bresp;
    wire dma_m_axi_bvalid;
    wire dma_m_axi_bready;
    
//    wire [31:0] dma_m_axi_araddr;
//    wire dma_m_axi_arvalid;
//    wire dma_m_axi_arready;
//    wire [31:0] dma_m_axi_rdata;
//    wire [1:0] dma_m_axi_rresp;
//    wire dma_m_axi_rvalid;
//    wire dma_m_axi_rready;
    logic GND = 32'b0; 
    // Instantiate simple_memory
    simple_memory #(
        .ADDR_WIDTH(10),
        .DATA_WIDTH(32)
    ) memory_inst (
        .clk(aclk),
        .rst_n(aresetn),

        // AXI4-Lite slave interface (connected to DMA's master interface)
        .s_axi_awaddr(dma_m_axi_awaddr),
        .s_axi_awvalid(dma_m_axi_awvalid),
        .s_axi_awready(dma_m_axi_awready),
        .s_axi_wdata(dma_m_axi_wdata),
        .s_axi_wstrb(dma_m_axi_wstrb),
        .s_axi_wvalid(dma_m_axi_wvalid),
        .s_axi_wready(dma_m_axi_wready),
        .s_axi_bresp(dma_m_axi_bresp),
        .s_axi_bvalid(dma_m_axi_bvalid),
        .s_axi_bready(dma_m_axi_bready),

        .s_axi_araddr(GND),
        .s_axi_arvalid(GND),
        .s_axi_arready(GND),
        .s_axi_rdata(GND),
        .s_axi_rresp(GND),
        .s_axi_rvalid(GND),
        .s_axi_rready(GND)
    );

    // Instantiate simple_dma
    simple_dma_axi4lite dma_inst (
        .aclk(aclk),
        .aresetn(aresetn),

        // AXI4-Lite slave interface for configuration (external control)
        .s_axi_awaddr(dma_s_axi_awaddr),
        .s_axi_awvalid(dma_s_axi_awvalid),
        .s_axi_awready(dma_s_axi_awready),
        .s_axi_wdata(dma_s_axi_wdata),
        .s_axi_wvalid(dma_s_axi_wvalid),
        .s_axi_wready(dma_s_axi_wready),
        .s_axi_wstrb(dma_s_axi_wstrb),
        .s_axi_bresp(dma_s_axi_bresp),
        .s_axi_bvalid(dma_s_axi_bvalid),
        .s_axi_bready(dma_s_axi_bready),
        .s_axi_araddr(dma_s_axi_araddr),
        .s_axi_arvalid(dma_s_axi_arvalid),
        .s_axi_arready(dma_s_axi_arready),
        .s_axi_rdata(dma_s_axi_rdata),
        .s_axi_rresp(dma_s_axi_rresp),
        .s_axi_rvalid(dma_s_axi_rvalid),
        .s_axi_rready(dma_s_axi_rready),

        // AXI4-Lite master interface (connected to memory)
        .m_axi_awaddr(dma_m_axi_awaddr),
        .m_axi_awvalid(dma_m_axi_awvalid),
        .m_axi_awready(dma_m_axi_awready),
        .m_axi_wdata(dma_m_axi_wdata),
        .m_axi_wstrb(dma_m_axi_wstrb),
        .m_axi_wvalid(dma_m_axi_wvalid),
        .m_axi_wready(dma_m_axi_wready),
        .m_axi_bresp(dma_m_axi_bresp),
        .m_axi_bvalid(dma_m_axi_bvalid),
        .m_axi_bready(dma_m_axi_bready),
        .m_axi_araddr(dma_m_axi_araddr),
        .m_axi_arvalid(dma_m_axi_arvalid),
        .m_axi_arready(dma_m_axi_arready),
        .m_axi_rdata(dma_m_axi_rdata),
        .m_axi_rresp(dma_m_axi_rresp),
        .m_axi_rvalid(dma_m_axi_rvalid),
        .m_axi_rready(dma_m_axi_rready)
    );


endmodule
