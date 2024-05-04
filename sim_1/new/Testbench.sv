`timescale 1ns / 1ps  //
`default_nettype none


module Testbench;
  logic rst;

  //--------------------------------------------------------------------------//
  // VGA
  //--------------------------------------------------------------------------//
  logic clk_vga;
  logic [11:0] rgb;
  wire vidstate;
  wire Hsync, Vsync;
  wire [3:0] vgaRed, vgaBlue, vgaGreen;
  wire [9:0] x, y;

  VGA_Sync vga_sync_uut (
      .clk     (clk_vga),
      .rst     (rst),
      .rgb_in  (rgb),
      .vidstate(vidstate),
      .hsync   (Hsync),
      .vsync   (Vsync),
      .rgb_out ({vgaRed, vgaGreen, vgaBlue}),
      .h       (x),
      .v       (y)
  );

  initial begin
    clk_vga = 0;
    rgb = 0;
    rst = 1;

    #10;
    rst = 0;

    forever begin
      #39.722ns clk_vga <= ~clk_vga;
      #100 rgb <= rgb + 1;
    end

    $finish;
  end
endmodule
