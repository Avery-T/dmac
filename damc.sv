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

module simple_dma_controller (
  input logic clk,
  input logic rst_n,
  input logic start,
  input logic [31:0] src_addr,
  input logic [31:0] dst_addr,
  input logic [15:0] transfer_length,
  output logic busy,
  output logic done,
  // Memory interface
  output logic [31:0] mem_addr,
  output logic mem_read,
  output logic mem_write,
  inout logic [31:0] mem_data
);

  typedef enum logic [1:0] {
    IDLE,
    READ,
    WRITE,
    COMPLETE
  } state_t;

  state_t state, next_state;
  logic [31:0] current_src, current_dst;
  logic [15:0] remaining;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= IDLE;
      current_src <= '0;
      current_dst <= '0;
      remaining <= '0;
    end else begin
      state <= next_state;
      if (state == IDLE && start) begin
        current_src <= src_addr;
        current_dst <= dst_addr;
        remaining <= transfer_length;
      end else if (state == WRITE) begin
        current_src <= current_src + 4;
        current_dst <= current_dst + 4;
        remaining <= remaining - 1;
      end
    end
  end

  always_comb begin
    next_state = state;
    case (state)
      IDLE: if (start) next_state = READ;
      READ: next_state = WRITE;
      WRITE: begin
        if (remaining == 1) next_state = COMPLETE;
        else next_state = READ;
      end
      COMPLETE: next_state = IDLE;
    endcase
  end


  always_comb begin
    mem_addr = '0;
    mem_read = 1'b0;
    mem_write = 1'b0;
    busy = 1'b0;
    done = 1'b0;

    case (state)
      IDLE: begin
        busy = 1'b0;
        done = 1'b0;
      end
      READ: begin
        mem_addr = current_src;
        mem_read = 1'b1;
        busy = 1'b1;
      end
      WRITE: begin
        mem_addr = current_dst;
        mem_write = 1'b1;
        busy = 1'b1;
      end
      COMPLETE: begin
        busy = 1'b0;
        done = 1'b1;
      end
    endcase
  end

  logic [31:0] data_buffer;

  always_ff @(posedge clk) begin
    if (state == READ) begin
      data_buffer <= mem_data;
    end
  end

  assign mem_data = (state == WRITE) ? data_buffer : 'z;

endmodule
