/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : L-2016.03-SP2
// Date      : Sat Apr 25 18:27:03 2020
/////////////////////////////////////////////////////////////


module glitchy ( rd, ds, go, ws, clk, reset_n );
  input go, ws, clk, reset_n;
  output rd, ds;
  wire   N12, n4, n5, n6, n7, n8, n9;
  wire   [1:0] glitch_ns;
  assign ds = N12;

  DFFARX1 \glitch_ps_reg[1]  ( .D(glitch_ns[1]), .CLK(clk), .RSTB(reset_n), 
        .Q(n5), .QN(n9) );
  DFFARX1 \glitch_ps_reg[0]  ( .D(glitch_ns[0]), .CLK(clk), .RSTB(reset_n), 
        .Q(n8), .QN(n4) );
  AO21X1 U9 ( .IN1(n8), .IN2(n9), .IN3(n6), .Q(rd) );
  OAI22X1 U10 ( .IN1(n5), .IN2(n4), .IN3(ws), .IN4(n7), .QN(glitch_ns[1]) );
  AO21X1 U11 ( .IN1(go), .IN2(n4), .IN3(n6), .Q(glitch_ns[0]) );
  INVX0 U12 ( .IN(n7), .QN(n6) );
  NAND2X0 U13 ( .IN1(n5), .IN2(n4), .QN(n7) );
  NOR2X0 U14 ( .IN1(n9), .IN2(n4), .QN(N12) );
endmodule

