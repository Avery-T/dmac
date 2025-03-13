`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Avery Taylor, Stanley To
//
// Create Date: 03/10/2025 08:10:11 PM
// Design Name:
// Module Name: simple_memory
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


module simple_memory #(
    parameter integer ADDR_WIDTH = 10,  // Address width in bits
    parameter integer DATA_WIDTH = 32   // Data width in bits
)(
    input logic clk,
    input logic rst_n,  // Active low reset

    // AXI4-Lite Configuration Interface
    input logic [31:0] s_axi_awaddr,
    input logic s_axi_awvalid,
    output logic s_axi_awready,
    input logic [31:0] s_axi_wdata,
    input logic [3:0] s_axi_wstrb,
    input logic s_axi_wvalid,
    output logic s_axi_wready,
    output logic [1:0] s_axi_bresp,
    output logic s_axi_bvalid,
    input logic s_axi_bready,

    input logic [31:0] s_axi_araddr,
    input logic s_axi_arvalid,
    output logic s_axi_arready,
    output logic [31:0] s_axi_rdata,
    output logic [1:0] s_axi_rresp,
    output logic s_axi_rvalid,
    input logic s_axi_rready
);

    // Local parameters
    localparam integer ADDR_LSB = $clog2(DATA_WIDTH/8);
    localparam integer MEM_DEPTH = 2**ADDR_WIDTH;

    // Memory array
    logic [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];

    // Internal signals
    logic [ADDR_WIDTH-1:0] axi_awaddr_internal;
    logic [ADDR_WIDTH-1:0] axi_araddr_internal;

    // State machine states
    typedef enum logic [1:0] {
        IDLE,
        WRITE_DATA,
        WRITE_RESP,
        READ_DATA
    } axi_state_t;

    axi_state_t PS, NS;

    // Convert AXI address to internal memory address
    assign axi_awaddr_internal = s_axi_awaddr[ADDR_WIDTH+ADDR_LSB-1:ADDR_LSB];
    assign axi_araddr_internal = s_axi_araddr[ADDR_WIDTH+ADDR_LSB-1:ADDR_LSB];

    // State machine
    always_ff @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            PS <= IDLE;
        end
        else begin
            PS <= NS;
        end
    end

    // Next state logic
    always_comb begin
        NS = PS;

        case (PS)
            IDLE: begin
                if (s_axi_awvalid) begin  //  if (s_axi_awvalid && s_axi_wvalid)
                    NS = WRITE_DATA;
                end
                else if (s_axi_arvalid) begin
                    NS = READ_DATA;
                end
            end

            WRITE_DATA: begin
                NS = WRITE_RESP;
            end

            WRITE_RESP: begin
                if (s_axi_bready) begin
                    NS = IDLE;
                end
            end

            READ_DATA: begin
                if (s_axi_rready) begin
                    NS = IDLE;
                end
            end

            default: begin
                NS = IDLE;
            end
        endcase
    end

    // Control signals
    always_ff @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            s_axi_awready <= 1'b0;
            s_axi_wready <= 1'b0;
            s_axi_bvalid <= 1'b0;
            s_axi_bresp <= 2'b00;
            s_axi_arready <= 1'b0;
            s_axi_rvalid <= 1'b0;
            s_axi_rresp <= 2'b00;
            s_axi_rdata <= {DATA_WIDTH{1'b0}};
        end
        else begin
            case (PS)
                IDLE: begin
                    s_axi_awready <= 1'b1;
                    s_axi_wready <= 1'b1;
                    s_axi_bvalid <= 1'b0;
                    s_axi_arready <= 1'b1;
                    s_axi_rvalid <= 1'b0;
                end

                WRITE_DATA: begin
                    s_axi_awready <= 1'b0;
                    s_axi_wready <= 1'b0;

                    // Write data to memory with byte enable
                    if (s_axi_wstrb[0]) mem[axi_awaddr_internal][7:0] <= s_axi_wdata[7:0];
                    if (s_axi_wstrb[1]) mem[axi_awaddr_internal][15:8] <= s_axi_wdata[15:8];
                    if (s_axi_wstrb[2]) mem[axi_awaddr_internal][23:16] <= s_axi_wdata[23:16];
                    if (s_axi_wstrb[3]) mem[axi_awaddr_internal][31:24] <= s_axi_wdata[31:24];

                    s_axi_bresp <= 2'b00;  // OKAY response
                    s_axi_bvalid <= 1'b1;
                end

                WRITE_RESP: begin
                    if (s_axi_bready) begin
                        s_axi_bvalid <= 1'b0;
                    end
                end

                READ_DATA: begin
                    s_axi_arready <= 1'b0;

                    // Read data from memory
                    s_axi_rdata <= mem[axi_araddr_internal];
                    s_axi_rresp <= 2'b00;       // OKAY response
                    s_axi_rvalid <= 1'b1;

                    if (s_axi_rready) begin
                        s_axi_rvalid <= 1'b0;
                    end
                end

                default: begin
                    s_axi_awready <= 1'b0;
                    s_axi_wready <= 1'b0;
                    s_axi_bvalid <= 1'b0;
                    s_axi_arready <= 1'b0;
                    s_axi_rvalid <= 1'b0;
                end
            endcase
        end
    end
endmodule
