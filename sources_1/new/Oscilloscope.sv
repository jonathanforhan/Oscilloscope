`timescale 1ns / 1ps  //
`default_nettype none


module Oscilloscope (
    input wire clk_100MHz,
    input wire [7:0] xadc,  // JXADC ports
    input wire [15:0] freq,
    output logic [639:0][9:0] ch1,
    output logic [639:0][9:0] ch2
);
  import ePort::*;

  localparam int UINT16_MAX = 65535;

  wire  [31:0] data;  // pad the 16 bit response with 32 bits
  logic [ 6:0] port = XA1;

  XADC_Mod xadc_mod (
      .clk_100MHz(clk_100MHz),
      .port      (port),
      .vauxp6    (xadc[0]),
      .vauxn6    (xadc[4]),
      .vauxp7    (xadc[2]),
      .vauxn7    (xadc[6]),
      .vauxp14   (xadc[1]),
      .vauxn14   (xadc[5]),
      .vauxp15   (xadc[3]),
      .vauxn15   (xadc[7]),
      .data      (data[15:0])
  );

  logic clk_osc;
  logic [31:0] i;

  always_ff @(posedge clk_100MHz) begin
    if (i >= (100_000_000 / (freq * 2)) >> 1) begin
      i <= 0;
      clk_osc <= ~clk_osc;
    end else begin
      i <= i + 1;
    end
  end

  logic [9:0] counter;

  always_ff @(posedge clk_osc) begin
    case (port)
      XA1: begin
        ch1[counter] <= 479 - ((data * 479) / UINT16_MAX);
        port <= XA2;
      end
      XA2: begin
        ch2[counter] <= 479 - ((data * 479) / UINT16_MAX);
        port <= XA3;
      end
      XA3: port <= XA4;
      default: begin
        port <= XA1;
        counter <= counter == 639 ? 0 : counter + 1;
      end
    endcase
  end
endmodule
