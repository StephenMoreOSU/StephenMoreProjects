/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : L-2016.03-SP2
// Date      : Thu Apr 23 20:57:58 2020
/////////////////////////////////////////////////////////////


module glitchless ( rd, ds, go, ws, clk, reset_n );
  input go, ws, clk, reset_n;
  output rd, ds;
  wire   \no_glitch_ps[1] , n7, n8, n9, n10, n11, n12;
  wire   [3:0] no_glitch_ns;

  DFFARX1 \no_glitch_ps_reg[0]  ( .D(no_glitch_ns[0]), .CLK(clk), .RSTB(
        reset_n), .QN(n12) );
  DFFARX1 \no_glitch_ps_reg[2]  ( .D(no_glitch_ns[2]), .CLK(clk), .RSTB(
        reset_n), .Q(rd), .QN(n7) );
  DFFARX1 \no_glitch_ps_reg[1]  ( .D(no_glitch_ns[1]), .CLK(clk), .RSTB(
        reset_n), .Q(\no_glitch_ps[1] ) );
  DFFARX1 \no_glitch_ps_reg[3]  ( .D(no_glitch_ns[3]), .CLK(clk), .RSTB(
        reset_n), .Q(ds) );
  AND3X1 U12 ( .IN1(rd), .IN2(n8), .IN3(\no_glitch_ps[1] ), .Q(no_glitch_ns[3]) );
  NAND2X0 U13 ( .IN1(n9), .IN2(n10), .QN(no_glitch_ns[2]) );
  AO21X1 U14 ( .IN1(\no_glitch_ps[1] ), .IN2(n8), .IN3(n7), .Q(n10) );
  INVX0 U15 ( .IN(ws), .QN(n8) );
  AOI21X1 U16 ( .IN1(\no_glitch_ps[1] ), .IN2(ws), .IN3(n7), .QN(
        no_glitch_ns[1]) );
  AO21X1 U17 ( .IN1(rd), .IN2(\no_glitch_ps[1] ), .IN3(n11), .Q(
        no_glitch_ns[0]) );
  INVX0 U18 ( .IN(n9), .QN(n11) );
  NAND3X0 U19 ( .IN1(n12), .IN2(n7), .IN3(go), .QN(n9) );
endmodule

