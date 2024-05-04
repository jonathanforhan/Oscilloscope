`timescale 1ns / 1ps  //
`default_nettype none


/// Oscilloscope, uses variable frequency from XADC port XA3 and XA4
module Oscilloscope (
    input wire clk_100MHz,
    input wire [7:0] xadc,  // JXADC ports
    output logic [15:0] led,
    output logic [639:0][9:0] ch1,  // channel 1
    output logic [639:0][9:0] ch2  // channel 2
);
  import XADC_Ports::*;

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
  logic [31:0] freq;

  Clock_Var_Gen clock_osc (
      .clk_in (clk_100MHz),
      .rst    (rst),
      .freq   (freq),
      .clk_out(clk_osc)
  );

  logic [9:0] i = 0;

  always_ff @(posedge clk_osc) begin
    case (port)
      XA1: begin
        ch1[i] <= 479 - ((data * 479) / UINT16_MAX);
        port   <= XA2;
      end
      XA2: begin
        ch2[i] <= 479 - ((data * 479) / UINT16_MAX);
        port   <= XA3;
      end
      XA3: begin
        freq <= data;
        led  <= data;
        port <= XA4;
      end
      default: begin
        i <= i == 639 ? 0 : i + 1;
        port <= XA1;
      end
    endcase
  end
endmodule
