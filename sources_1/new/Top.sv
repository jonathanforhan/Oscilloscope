`timescale 1ns / 1ps  //
`default_nettype none


module Top (
    input wire clk,
    input wire [7:0] JXADC,
    output wire Hsync,
    output wire Vsync,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaBlue,
    output wire [3:0] vgaGreen,
    output wire [15:0] led,
    //-- PULLUP (see contraints)
    output wire [3:0] an
);
  //--------------------------------------------------------------------------//
  // VGA
  //--------------------------------------------------------------------------//

  wire clk_vga;

  Clock_Gen #(
      .FREQ_IN (100_000_000),
      .FREQ_OUT(25_175_000)
  ) clock_vga (
      .clk_in (clk),
      .clk_out(clk_vga)
  );

  wire vidstate;
  logic [9:0] x, y;
  logic [11:0] rgb;

  VGA_Sync vga_sync (
      .clk     (clk_vga),
      .rgb_in  (rgb),
      .vidstate(vidstate),
      .hsync   (Hsync),
      .vsync   (Vsync),
      .rgb_out ({vgaRed, vgaGreen, vgaBlue}),
      .h       (x),
      .v       (y)
  );

  //--------------------------------------------------------------------------//
  // Oscilloscope
  //--------------------------------------------------------------------------//

  wire [639:0][9:0] ch1;
  wire [639:0][9:0] ch2;

  Oscilloscope oscilloscope (
      .clk_100MHz(clk),
      .xadc      (JXADC),
      .led       (led),
      .ch1       (ch1),
      .ch2       (ch2)
  );

  //--------------------------------------------------------------------------//
  // User Interface
  //--------------------------------------------------------------------------//

  always_ff @(posedge clk_vga) begin
    if (x < 639) begin
      if (y == ch1[x]) begin
        rgb <= 12'b1111_1111_1111;
      end else if (y == ch2[x]) begin
        rgb <= 12'b0000_1111_1111;
      end else if (x % 60 == 0 || y % 48 == 0) begin
        rgb <= 12'b0001_0001_0001;
      end else begin
        rgb <= 12'b0;
      end
    end
  end
endmodule
