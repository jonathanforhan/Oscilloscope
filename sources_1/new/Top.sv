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
    //-- PULLUP (see contraints)
    output wire [3:0] an
);
  //--------------------------------------------------------------------------//
  // VGA timing
  //--------------------------------------------------------------------------//
  wire clk_vga;

  Clock_Conv #(
      .FREQ_IN (100_000_000),
      .FREQ_OUT(25_175_000)
  ) clock_vga (
      .clk_in (clk),
      .clk_out(clk_vga)
  );

  //--------------------------------------------------------------------------//
  // VGA sync
  //--------------------------------------------------------------------------//
  wire vidstate;
  logic [9:0] x, y;
  logic [11:0] rgb;

  VGA_Sync vga_sync (
      .clk(clk_vga),
      .rgb_in(rgb),
      .vidstate(vidstate),
      .hsync(Hsync),
      .vsync(Vsync),
      .rgb_out({vgaRed, vgaGreen, vgaBlue}),
      .h(x),
      .v(y)
  );

  //--------------------------------------------------------------------------//
  // ADC
  //--------------------------------------------------------------------------//
  wire  [31:0] data;  // pad the 16 bit response with 32 bit for operations
  logic [ 6:0] port = XA1;

  XADC_Mod xadc_mod (
      .clk_100MHz(clk),
      .port(port),
      .vauxp6(JXADC[0]),
      .vauxn6(JXADC[4]),
      .vauxp7(JXADC[2]),
      .vauxn7(JXADC[6]),
      .vauxp14(JXADC[1]),
      .vauxn14(JXADC[5]),
      .vauxp15(JXADC[3]),
      .vauxn15(JXADC[7]),
      .data(data)
  );

  //--------------------------------------------------------------------------//
  // Display
  //--------------------------------------------------------------------------//
  wire clk_disp;

  Clock_Conv #(
      .FREQ_IN (100_000_000),
      .FREQ_OUT(180 * 4)
  ) clock_disp (
      .clk_in (clk),
      .clk_out(clk_disp)
  );

  localparam int UINT16_MAX = 65536;

  logic [799:0][9:0] arr_x1;
  logic [799:0][9:0] arr_x2;
  logic [799:0][9:0] arr_x3;
  logic [799:0][9:0] arr_x4;

  task shift(inout logic [799:0][9:0] arr);
    arr[799:1] <= arr[798:0];
    arr[0] <= 480 - ((data * 480) / UINT16_MAX);
  endtask

  always_ff @(posedge clk_disp) begin
    case (port)
      XA1: begin
        shift(arr_x1);
        port <= XA2;
      end
      XA2: begin
        shift(arr_x2);
        port <= XA3;
      end
      XA3: begin
        shift(arr_x3);
        port <= XA4;
      end
      default: begin
        shift(arr_x4);
        port <= XA1;
      end
    endcase
  end

  task display(input logic [799:0][9:0] arr, input logic [11:0] color);
    if (x < 600 && y == arr[x]) begin
      rgb <= color;
    end
  endtask

  always_ff @(posedge clk_vga) begin
    if (x % 60 == 0 || y % 48 == 0) begin
      rgb <= 12'b0001_0001_0001;
    end else begin
      rgb <= 12'b0;
    end

    #10;

    display(arr_x1, 12'b1111_1111_1111);
    display(arr_x2, 12'b0000_1111_1111);
    display(arr_x3, 12'b1111_0000_1111);
    display(arr_x4, 12'b1111_1111_0000);
  end
endmodule
