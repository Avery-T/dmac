`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2025 06:43:04 PM
// Design Name: 
// Module Name: dmac
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

module simple_dma_axi4lite (
    input  logic        aclk,
    input  logic        aresetn,

    // AXI4-Lite Configuration Interface
    // Address bus from AXI interconnect to slave peripheral.
    input  logic [31:0] s_axi_awaddr,
    //Valid signal, asserting that the S_AXI_AWADDR can be sampled by the slave peripheral.
    input  logic        s_axi_awvalid,
    // Ready signal, indicating that the slave is ready to accept the value on S_AXI_AWADDR.
    output logic        s_axi_awready,
    input  logic [31:0] s_axi_wdata,
    input  logic [3:0]  s_axi_wstrb,
    input  logic        s_axi_wvalid,
    output logic        s_axi_wready,
    output logic [1:0]  s_axi_bresp,
    output logic        s_axi_bvalid,
    input  logic        s_axi_bready,

    input  logic [31:0] s_axi_araddr,
    input  logic        s_axi_arvalid,
    output logic        s_axi_arready,
    output logic [31:0] s_axi_rdata,
    output logic [1:0]  s_axi_rresp,
    output logic        s_axi_rvalid,
    input  logic        s_axi_rready,

    // AXI4-Lite Data Interface
    output logic [31:0] m_axi_araddr,
    output logic        m_axi_arvalid,
    input  logic        m_axi_arready, 
    input  logic [31:0] m_axi_rdata, 
    input  logic [1:0]  m_axi_rresp,
    input  logic        m_axi_rvalid,
    output logic        m_axi_rready,

    output logic [31:0] m_axi_awaddr,
    output logic        m_axi_awvalid,
    input  logic        m_axi_awready,
    output logic [31:0] m_axi_wdata,
    output logic [3:0]  m_axi_wstrb,
    output logic        m_axi_wvalid,
    input  logic        m_axi_wready,
    input  logic [1:0]  m_axi_bresp,
    input  logic        m_axi_bvalid,
    output logic        m_axi_bready
);

    typedef enum logic [2:0] {
        IDLE, READ_ADDR, READ_DATA, WRITE_ADDR, WRITE_DATA, WRITE_RESP, DONE
    } state_t;

    state_t state;
    logic [31:0] src_addr, dst_addr;
    logic [15:0] transfer_len;
    logic [31:0] data_buffer;
    logic [15:0] remaining;
    logic start_pulse;

    // Configuration registers
    always_ff @(posedge aclk or posedge aresetn) begin
        if (aresetn) begin
            src_addr <= '0;
            dst_addr <= '0;
            transfer_len <= '0;
            start_pulse <= '0;
        end
        else if (s_axi_awvalid && s_axi_wvalid) begin
            //its up to the salve to determin what the write address means
            case (s_axi_awaddr)
                32'h00: src_addr <= s_axi_wdata; //might need to look into this
                32'h04: dst_addr <= s_axi_wdata;
                32'h08: transfer_len <= s_axi_wdata[15:0];
                32'h0C: start_pulse <= s_axi_wdata[0];
                default: begin end
            endcase
        end
    end

    // Status readback
    always_comb begin
        s_axi_rdata = '0;
        case (s_axi_araddr) // 32 bit addressing makes it simplier to read 
            32'h00: s_axi_rdata = src_addr;
            32'h04: s_axi_rdata = dst_addr;
            32'h08: s_axi_rdata = transfer_len;
            32'h0C: s_axi_rdata = {31'b0, (state != IDLE)};
            default: begin end
        endcase
    end

    // AXI4-Lite handshaking
    assign s_axi_awready = 1'b1;
    assign s_axi_wready = 1'b1;
    assign s_axi_bresp = 2'b00;
    assign s_axi_bvalid = s_axi_awvalid && s_axi_wvalid;

    assign s_axi_arready = 1'b1;
    assign s_axi_rresp = 2'b00;
    assign s_axi_rvalid = s_axi_arvalid;

    // DMA Control FSM
    always_ff @(posedge aclk or posedge aresetn) begin
        if (aresetn) begin
            state <= IDLE;
            remaining <= '0;
            data_buffer <= '0;
        end
        else begin
            case (state)
                IDLE:
                    if (start_pulse) begin
                        remaining <= transfer_len;
                        state <= READ_ADDR;
                    end

                READ_ADDR:
                    if (m_axi_arready)
                        state <= READ_DATA;

                READ_DATA:
                    if (m_axi_rvalid) begin
                        data_buffer <= m_axi_rdata;
                        state <= WRITE_ADDR;
                    end

                WRITE_ADDR:
                    if (m_axi_awready)
                        state <= WRITE_DATA;

                WRITE_DATA:
                    if (m_axi_wready)
                        state <= WRITE_RESP;

                WRITE_RESP:
                    if (m_axi_bvalid) begin
                        if (remaining == 0)
                            state <= DONE;
                        else begin
                            remaining <= remaining - 1;
                            state <= READ_ADDR;
                        end
                    end

                DONE: state <= IDLE;

                default: begin end
            endcase
        end
    end

    // AXI4-Lite Data Interface Control
    assign m_axi_araddr = src_addr + (transfer_len - remaining) * 4;
    assign m_axi_arvalid = (state == READ_ADDR);
    assign m_axi_rready = (state == READ_DATA);

    assign m_axi_awaddr = dst_addr + (transfer_len - remaining) * 4;
    assign m_axi_awvalid = (state == WRITE_ADDR);
    assign m_axi_wdata = data_buffer;
    assign m_axi_wstrb = 4'b1111;
    assign m_axi_wvalid = (state == WRITE_DATA);
    assign m_axi_bready = (state == WRITE_RESP);
endmodule
