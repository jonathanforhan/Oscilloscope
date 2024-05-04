`timescale 1ns / 1ps  //
`default_nettype none


package XADC_Ports;
  typedef enum bit [6:0] {
    XA1 = 8'h16,
    XA2 = 8'h17,
    XA3 = 8'h1e,
    XA4 = 8'h1f
  } port_t;
endpackage

/// XADC module wrapper
module XADC_Mod (
    input wire clk_100MHz,  // 100MHz
    input wire [6:0] port,
    input wire vauxp6,
    input wire vauxn6,
    input wire vauxp7,
    input wire vauxn7,
    input wire vauxp14,
    input wire vauxn14,
    input wire vauxp15,
    input wire vauxn15,
    output wire [15:0] data
);
  wire enable, ready;

  //--- IP generated
  xadc_wiz_0 XLXI_7 (
      .di_in              (),            // input wire [15 : 0] di_in
      .daddr_in           (port),        // input wire [6 : 0] daddr_in
      .den_in             (enable),      // input wire den_in
      .dwe_in             (),            // input wire dwe_in
      .drdy_out           (ready),       // output wire drdy_out
      .do_out             (data),        // output wire [15 : 0] do_out
      .dclk_in            (clk_100MHz),  // input wire dclk_in
      .reset_in           (),            // input wire reset_in
      .vp_in              (),            // input wire vp_in
      .vn_in              (),            // input wire vn_in
      .vauxp6             (vauxp6),      // input wire vauxp6
      .vauxn6             (vauxn6),      // input wire vauxn6
      .vauxp7             (vauxp7),      // input wire vauxp7
      .vauxn7             (vauxn7),      // input wire vauxn7
      .vauxp14            (vauxp14),     // input wire vauxp14
      .vauxn14            (vauxn14),     // input wire vauxn14
      .vauxp15            (vauxp15),     // input wire vauxp15
      .vauxn15            (vauxn15),     // input wire vauxn15
      .user_temp_alarm_out(),            // output wire user_temp_alarm_out
      .vccint_alarm_out   (),            // output wire vccint_alarm_out
      .vccaux_alarm_out   (),            // output wire vccaux_alarm_out
      .ot_out             (),            // output wire ot_out
      .channel_out        (),            // output wire [4 : 0] channel_out
      .eoc_out            (enable),      // output wire eoc_out
      .alarm_out          (),            // output wire alarm_out
      .eos_out            (),            // output wire eos_out
      .busy_out           ()             // output wire busy_out
  );
endmodule
