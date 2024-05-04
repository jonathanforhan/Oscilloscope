`timescale 1ns / 1ps  //
`default_nettype none


/// VGA sync module for timing of hsync, vsync and hookup rgb
module VGA_Sync #(
    parameter int H_DISPLAY = 640,  // horizontal display area
    parameter int H_L_BORDER = 48,  // horizontal left border
    parameter int H_R_BORDER = 16,  // horizontal right border
    parameter int H_RETRACE = 96,  // horizontal retrace
    parameter int V_DISPLAY = 480,  // vertical display area
    parameter int V_T_BORDER = 10,  // vertical top border
    parameter int V_B_BORDER = 33,  // vertical bottom border
    parameter int V_RETRACE = 2  // vertical retrace
) (
    input wire clk,
    input wire rst,
    input wire [11:0] rgb_in,
    output wire vidstate,
    output wire hsync,
    output wire vsync,
    output wire [11:0] rgb_out,
    output logic [9:0] h,
    output logic [9:0] v
);
  localparam int H_MAX = H_DISPLAY + H_L_BORDER + H_R_BORDER + H_RETRACE - 1;
  localparam int START_H_RETRACE = H_DISPLAY + H_R_BORDER;
  localparam int END_H_RETRACE = H_DISPLAY + H_R_BORDER + H_RETRACE - 1;

  localparam int V_MAX = V_DISPLAY + V_T_BORDER + V_B_BORDER + V_RETRACE - 1;
  localparam int START_V_RETRACE = V_DISPLAY + V_B_BORDER;
  localparam int END_V_RETRACE = V_DISPLAY + V_B_BORDER + V_RETRACE - 1;

  // iterate left to right, top to bottom
  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
      h <= 0;
      v <= 0;
    end else begin
      if (h == H_MAX) begin
        h <= 0;
        v <= v == V_MAX ? 0 : v + 1;
      end else begin
        h <= h + 1;
      end
    end
  end

  // [h|v]sync are active LOW, so inactive when in retrace
  assign hsync = h >= START_H_RETRACE && h <= END_H_RETRACE;
  assign vsync = v >= START_V_RETRACE && v <= END_V_RETRACE;
  assign vidstate = (h < H_DISPLAY) && (v < V_DISPLAY);

  // VGA expects colors are low when not in screen bounds
  assign rgb_out = vidstate ? rgb_in : 12'b0;
endmodule
