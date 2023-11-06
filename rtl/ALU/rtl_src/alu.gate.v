/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : L-2016.03-SP2
// Date      : Fri Apr 17 14:10:50 2020
/////////////////////////////////////////////////////////////


module alu_DW01_addsub_0 ( A, B, CI, ADD_SUB, SUM, CO );
  input [8:0] A;
  input [8:0] B;
  output [8:0] SUM;
  input CI, ADD_SUB;
  output CO;

  wire   [9:0] carry;
  wire   [8:0] B_AS;
  assign carry[0] = ADD_SUB;

  FADDX1 U1_7 ( .A(A[7]), .B(B_AS[7]), .CI(carry[7]), .CO(carry[8]), .S(SUM[7]) );
  FADDX1 U1_6 ( .A(A[6]), .B(B_AS[6]), .CI(carry[6]), .CO(carry[7]), .S(SUM[6]) );
  FADDX1 U1_5 ( .A(A[5]), .B(B_AS[5]), .CI(carry[5]), .CO(carry[6]), .S(SUM[5]) );
  FADDX1 U1_4 ( .A(A[4]), .B(B_AS[4]), .CI(carry[4]), .CO(carry[5]), .S(SUM[4]) );
  FADDX1 U1_3 ( .A(A[3]), .B(B_AS[3]), .CI(carry[3]), .CO(carry[4]), .S(SUM[3]) );
  FADDX1 U1_2 ( .A(A[2]), .B(B_AS[2]), .CI(carry[2]), .CO(carry[3]), .S(SUM[2]) );
  FADDX1 U1_1 ( .A(A[1]), .B(B_AS[1]), .CI(carry[1]), .CO(carry[2]), .S(SUM[1]) );
  FADDX1 U1_0 ( .A(A[0]), .B(B_AS[0]), .CI(carry[0]), .CO(carry[1]), .S(SUM[0]) );
  XOR2X1 U1 ( .IN1(carry[0]), .IN2(carry[8]), .Q(SUM[8]) );
  XOR2X1 U2 ( .IN1(B[7]), .IN2(carry[0]), .Q(B_AS[7]) );
  XOR2X1 U3 ( .IN1(B[6]), .IN2(carry[0]), .Q(B_AS[6]) );
  XOR2X1 U4 ( .IN1(B[5]), .IN2(carry[0]), .Q(B_AS[5]) );
  XOR2X1 U5 ( .IN1(B[4]), .IN2(carry[0]), .Q(B_AS[4]) );
  XOR2X1 U6 ( .IN1(B[3]), .IN2(carry[0]), .Q(B_AS[3]) );
  XOR2X1 U7 ( .IN1(B[2]), .IN2(carry[0]), .Q(B_AS[2]) );
  XOR2X1 U8 ( .IN1(B[1]), .IN2(carry[0]), .Q(B_AS[1]) );
  XOR2X1 U9 ( .IN1(B[0]), .IN2(carry[0]), .Q(B_AS[0]) );
endmodule


module alu ( in_a, in_b, opcode, alu_out, alu_zero, alu_carry );
  input [7:0] in_a;
  input [7:0] in_b;
  input [3:0] opcode;
  output [7:0] alu_out;
  output alu_zero, alu_carry;
  wire   N53, N54, N55, N56, N57, N58, N59, N60, N61, N62, N63, N64, N65, N66,
         N67, N68, N69, N70, N71, N72, N73, N74, N75, N76, N77, N78, N79, N80,
         N81, N82, N83, N84, N85, \U3/U1/Z_0 , \U3/U1/Z_1 , \U3/U1/Z_2 ,
         \U3/U1/Z_3 , \U3/U1/Z_4 , \U3/U1/Z_5 , \U3/U1/Z_6 , \U3/U1/Z_7 ,
         \U3/U2/Z_0 , \U3/U2/Z_1 , \U3/U2/Z_2 , \U3/U2/Z_3 , \U3/U2/Z_4 ,
         \U3/U2/Z_5 , \U3/U2/Z_6 , \U3/U2/Z_7 , \U3/U3/Z_0 , n144, n145, n146,
         n147, n148, n149, n150, n151, n152, n153, n154, n155, n156, n157,
         n158, n159, n160, n161, n162, n163, n164, n165, n166, n167, n168,
         n169, n170, n171, n172, n173, n174, n175, n176, n177, n178, n179,
         n180, n181, n182, n183, n184, n185, n186, n187, n188, n189, n190,
         n191, n192, n193, n194, n195, n196, n197, n198, n199, n200, n201,
         n202, n203, n204, n205, n206, n207, n208, n209, n210, n211, n212,
         n213, n214, n215, n216, n217, n218, n219;

  alu_DW01_addsub_0 r30 ( .A({1'b0, \U3/U1/Z_7 , \U3/U1/Z_6 , \U3/U1/Z_5 , 
        \U3/U1/Z_4 , \U3/U1/Z_3 , \U3/U1/Z_2 , \U3/U1/Z_1 , \U3/U1/Z_0 }), .B(
        {1'b0, \U3/U2/Z_7 , \U3/U2/Z_6 , \U3/U2/Z_5 , \U3/U2/Z_4 , \U3/U2/Z_3 , 
        \U3/U2/Z_2 , \U3/U2/Z_1 , \U3/U2/Z_0 }), .CI(1'b0), .ADD_SUB(
        \U3/U3/Z_0 ), .SUM({N61, N60, N59, N58, N57, N56, N55, N54, N53}) );
  INVX0 U162 ( .IN(n168), .QN(n190) );
  INVX0 U163 ( .IN(n176), .QN(n189) );
  INVX0 U164 ( .IN(n181), .QN(n188) );
  INVX0 U165 ( .IN(n182), .QN(n187) );
  INVX0 U166 ( .IN(N61), .QN(n192) );
  INVX0 U167 ( .IN(opcode[0]), .QN(n185) );
  INVX0 U168 ( .IN(opcode[3]), .QN(n191) );
  INVX0 U169 ( .IN(opcode[1]), .QN(n186) );
  OA21X1 U170 ( .IN1(opcode[0]), .IN2(opcode[1]), .IN3(opcode[2]), .Q(n182) );
  NOR2X0 U171 ( .IN1(n191), .IN2(n185), .QN(n144) );
  AO22X1 U172 ( .IN1(n187), .IN2(n191), .IN3(n144), .IN4(opcode[1]), .Q(n175)
         );
  AND3X1 U173 ( .IN1(opcode[3]), .IN2(n185), .IN3(opcode[1]), .Q(n174) );
  AND4X1 U174 ( .IN1(opcode[0]), .IN2(opcode[2]), .IN3(n186), .IN4(n191), .Q(
        n173) );
  AOI222X1 U175 ( .IN1(N53), .IN2(n175), .IN3(n219), .IN4(n174), .IN5(N69), 
        .IN6(n173), .QN(n147) );
  AND3X1 U176 ( .IN1(opcode[2]), .IN2(n191), .IN3(opcode[1]), .Q(n145) );
  AND2X1 U177 ( .IN1(n145), .IN2(opcode[0]), .Q(n178) );
  NAND2X0 U178 ( .IN1(opcode[3]), .IN2(n186), .QN(n181) );
  NAND2X0 U179 ( .IN1(n188), .IN2(n185), .QN(n168) );
  AND2X1 U180 ( .IN1(n145), .IN2(n185), .Q(n177) );
  AOI222X1 U181 ( .IN1(N85), .IN2(n178), .IN3(n190), .IN4(in_a[1]), .IN5(N77), 
        .IN6(n177), .QN(n146) );
  NAND2X0 U182 ( .IN1(n147), .IN2(n146), .QN(alu_out[0]) );
  NAND2X0 U183 ( .IN1(N84), .IN2(n178), .QN(n151) );
  NAND2X0 U184 ( .IN1(N76), .IN2(n177), .QN(n150) );
  NAND2X0 U185 ( .IN1(opcode[0]), .IN2(n188), .QN(n176) );
  OA22X1 U186 ( .IN1(n217), .IN2(n168), .IN3(n219), .IN4(n176), .Q(n149) );
  AOI222X1 U187 ( .IN1(N54), .IN2(n175), .IN3(n218), .IN4(n174), .IN5(N68), 
        .IN6(n173), .QN(n148) );
  NAND4X0 U188 ( .IN1(n151), .IN2(n150), .IN3(n149), .IN4(n148), .QN(
        alu_out[1]) );
  NAND2X0 U189 ( .IN1(N83), .IN2(n178), .QN(n155) );
  NAND2X0 U190 ( .IN1(N75), .IN2(n177), .QN(n154) );
  OA22X1 U191 ( .IN1(n216), .IN2(n168), .IN3(n218), .IN4(n176), .Q(n153) );
  AOI222X1 U192 ( .IN1(N55), .IN2(n175), .IN3(n217), .IN4(n174), .IN5(N67), 
        .IN6(n173), .QN(n152) );
  NAND4X0 U193 ( .IN1(n155), .IN2(n154), .IN3(n153), .IN4(n152), .QN(
        alu_out[2]) );
  NAND2X0 U194 ( .IN1(N82), .IN2(n178), .QN(n159) );
  NAND2X0 U195 ( .IN1(N74), .IN2(n177), .QN(n158) );
  OA22X1 U196 ( .IN1(n215), .IN2(n168), .IN3(n217), .IN4(n176), .Q(n157) );
  AOI222X1 U197 ( .IN1(N56), .IN2(n175), .IN3(n216), .IN4(n174), .IN5(N66), 
        .IN6(n173), .QN(n156) );
  NAND4X0 U198 ( .IN1(n159), .IN2(n158), .IN3(n157), .IN4(n156), .QN(
        alu_out[3]) );
  NAND2X0 U199 ( .IN1(N81), .IN2(n178), .QN(n163) );
  NAND2X0 U200 ( .IN1(N73), .IN2(n177), .QN(n162) );
  OA22X1 U201 ( .IN1(n214), .IN2(n168), .IN3(n216), .IN4(n176), .Q(n161) );
  AOI222X1 U202 ( .IN1(N57), .IN2(n175), .IN3(n215), .IN4(n174), .IN5(N65), 
        .IN6(n173), .QN(n160) );
  NAND4X0 U203 ( .IN1(n163), .IN2(n162), .IN3(n161), .IN4(n160), .QN(
        alu_out[4]) );
  NAND2X0 U204 ( .IN1(N80), .IN2(n178), .QN(n167) );
  NAND2X0 U205 ( .IN1(N72), .IN2(n177), .QN(n166) );
  OA22X1 U206 ( .IN1(n213), .IN2(n168), .IN3(n215), .IN4(n176), .Q(n165) );
  AOI222X1 U207 ( .IN1(N58), .IN2(n175), .IN3(n214), .IN4(n174), .IN5(N64), 
        .IN6(n173), .QN(n164) );
  NAND4X0 U208 ( .IN1(n167), .IN2(n166), .IN3(n165), .IN4(n164), .QN(
        alu_out[5]) );
  NAND2X0 U209 ( .IN1(N79), .IN2(n178), .QN(n172) );
  NAND2X0 U210 ( .IN1(N71), .IN2(n177), .QN(n171) );
  OA22X1 U211 ( .IN1(n212), .IN2(n168), .IN3(n214), .IN4(n176), .Q(n170) );
  AOI222X1 U212 ( .IN1(N59), .IN2(n175), .IN3(n213), .IN4(n174), .IN5(N63), 
        .IN6(n173), .QN(n169) );
  NAND4X0 U213 ( .IN1(n172), .IN2(n171), .IN3(n170), .IN4(n169), .QN(
        alu_out[6]) );
  AOI222X1 U214 ( .IN1(N60), .IN2(n175), .IN3(n212), .IN4(n174), .IN5(N62), 
        .IN6(n173), .QN(n180) );
  AOI222X1 U215 ( .IN1(N78), .IN2(n178), .IN3(n189), .IN4(in_a[6]), .IN5(N70), 
        .IN6(n177), .QN(n179) );
  NAND2X0 U216 ( .IN1(n180), .IN2(n179), .QN(alu_out[7]) );
  OA22X1 U217 ( .IN1(n192), .IN2(n188), .IN3(n181), .IN4(n212), .Q(n184) );
  OA22X1 U218 ( .IN1(opcode[3]), .IN2(n182), .IN3(n191), .IN4(n185), .Q(n183)
         );
  NOR2X0 U219 ( .IN1(n184), .IN2(n183), .QN(alu_carry) );
  NOR2X0 U220 ( .IN1(n193), .IN2(n194), .QN(alu_zero) );
  OR4X1 U221 ( .IN1(alu_out[1]), .IN2(alu_out[0]), .IN3(alu_out[3]), .IN4(
        alu_out[2]), .Q(n194) );
  OR4X1 U222 ( .IN1(alu_out[5]), .IN2(alu_out[4]), .IN3(alu_out[7]), .IN4(
        alu_out[6]), .Q(n193) );
  OAI21X1 U223 ( .IN1(n195), .IN2(opcode[1]), .IN3(n196), .QN(\U3/U3/Z_0 ) );
  NOR2X0 U224 ( .IN1(n197), .IN2(n198), .QN(\U3/U2/Z_7 ) );
  NOR2X0 U225 ( .IN1(n197), .IN2(n199), .QN(\U3/U2/Z_6 ) );
  NOR2X0 U226 ( .IN1(n197), .IN2(n200), .QN(\U3/U2/Z_5 ) );
  NOR2X0 U227 ( .IN1(n197), .IN2(n201), .QN(\U3/U2/Z_4 ) );
  NOR2X0 U228 ( .IN1(n197), .IN2(n202), .QN(\U3/U2/Z_3 ) );
  NOR2X0 U229 ( .IN1(n197), .IN2(n203), .QN(\U3/U2/Z_2 ) );
  NOR2X0 U230 ( .IN1(n197), .IN2(n204), .QN(\U3/U2/Z_1 ) );
  NAND3X0 U231 ( .IN1(n205), .IN2(n206), .IN3(n207), .QN(\U3/U2/Z_0 ) );
  MUX21X1 U232 ( .IN1(n195), .IN2(n185), .S(opcode[1]), .Q(n207) );
  OR2X1 U233 ( .IN1(n208), .IN2(n197), .Q(n205) );
  OA21X1 U234 ( .IN1(opcode[1]), .IN2(opcode[2]), .IN3(n196), .Q(n197) );
  MUX21X1 U235 ( .IN1(n209), .IN2(n210), .S(in_a[7]), .Q(\U3/U1/Z_7 ) );
  MUX21X1 U236 ( .IN1(n209), .IN2(n210), .S(in_a[6]), .Q(\U3/U1/Z_6 ) );
  MUX21X1 U237 ( .IN1(n209), .IN2(n210), .S(in_a[5]), .Q(\U3/U1/Z_5 ) );
  MUX21X1 U238 ( .IN1(n209), .IN2(n210), .S(in_a[4]), .Q(\U3/U1/Z_4 ) );
  MUX21X1 U239 ( .IN1(n209), .IN2(n210), .S(in_a[3]), .Q(\U3/U1/Z_3 ) );
  MUX21X1 U240 ( .IN1(n209), .IN2(n210), .S(in_a[2]), .Q(\U3/U1/Z_2 ) );
  MUX21X1 U241 ( .IN1(n209), .IN2(n210), .S(in_a[1]), .Q(\U3/U1/Z_1 ) );
  MUX21X1 U242 ( .IN1(n209), .IN2(n210), .S(in_a[0]), .Q(\U3/U1/Z_0 ) );
  NAND3X0 U243 ( .IN1(n211), .IN2(n196), .IN3(opcode[1]), .QN(n210) );
  NAND2X0 U244 ( .IN1(n185), .IN2(n195), .QN(n196) );
  INVX0 U245 ( .IN(opcode[2]), .QN(n195) );
  OR2X1 U246 ( .IN1(n185), .IN2(opcode[3]), .Q(n211) );
  INVX0 U247 ( .IN(n206), .QN(n209) );
  NAND2X0 U248 ( .IN1(opcode[3]), .IN2(opcode[1]), .QN(n206) );
  XOR2X1 U249 ( .IN1(in_b[0]), .IN2(in_a[0]), .Q(N85) );
  XOR2X1 U250 ( .IN1(in_b[1]), .IN2(in_a[1]), .Q(N84) );
  XOR2X1 U251 ( .IN1(in_b[2]), .IN2(in_a[2]), .Q(N83) );
  XOR2X1 U252 ( .IN1(in_b[3]), .IN2(in_a[3]), .Q(N82) );
  XOR2X1 U253 ( .IN1(in_b[4]), .IN2(in_a[4]), .Q(N81) );
  XOR2X1 U254 ( .IN1(in_b[5]), .IN2(in_a[5]), .Q(N80) );
  XOR2X1 U255 ( .IN1(in_b[6]), .IN2(in_a[6]), .Q(N79) );
  XOR2X1 U256 ( .IN1(in_b[7]), .IN2(in_a[7]), .Q(N78) );
  NOR2X0 U257 ( .IN1(n219), .IN2(n208), .QN(N77) );
  NOR2X0 U258 ( .IN1(n218), .IN2(n204), .QN(N76) );
  NOR2X0 U259 ( .IN1(n217), .IN2(n203), .QN(N75) );
  NOR2X0 U260 ( .IN1(n216), .IN2(n202), .QN(N74) );
  NOR2X0 U261 ( .IN1(n215), .IN2(n201), .QN(N73) );
  NOR2X0 U262 ( .IN1(n214), .IN2(n200), .QN(N72) );
  NOR2X0 U263 ( .IN1(n213), .IN2(n199), .QN(N71) );
  NOR2X0 U264 ( .IN1(n212), .IN2(n198), .QN(N70) );
  NAND2X0 U265 ( .IN1(n208), .IN2(n219), .QN(N69) );
  INVX0 U266 ( .IN(in_a[0]), .QN(n219) );
  INVX0 U267 ( .IN(in_b[0]), .QN(n208) );
  NAND2X0 U268 ( .IN1(n204), .IN2(n218), .QN(N68) );
  INVX0 U269 ( .IN(in_a[1]), .QN(n218) );
  INVX0 U270 ( .IN(in_b[1]), .QN(n204) );
  NAND2X0 U271 ( .IN1(n203), .IN2(n217), .QN(N67) );
  INVX0 U272 ( .IN(in_a[2]), .QN(n217) );
  INVX0 U273 ( .IN(in_b[2]), .QN(n203) );
  NAND2X0 U274 ( .IN1(n202), .IN2(n216), .QN(N66) );
  INVX0 U275 ( .IN(in_a[3]), .QN(n216) );
  INVX0 U276 ( .IN(in_b[3]), .QN(n202) );
  NAND2X0 U277 ( .IN1(n201), .IN2(n215), .QN(N65) );
  INVX0 U278 ( .IN(in_a[4]), .QN(n215) );
  INVX0 U279 ( .IN(in_b[4]), .QN(n201) );
  NAND2X0 U280 ( .IN1(n200), .IN2(n214), .QN(N64) );
  INVX0 U281 ( .IN(in_a[5]), .QN(n214) );
  INVX0 U282 ( .IN(in_b[5]), .QN(n200) );
  NAND2X0 U283 ( .IN1(n199), .IN2(n213), .QN(N63) );
  INVX0 U284 ( .IN(in_a[6]), .QN(n213) );
  INVX0 U285 ( .IN(in_b[6]), .QN(n199) );
  NAND2X0 U286 ( .IN1(n198), .IN2(n212), .QN(N62) );
  INVX0 U287 ( .IN(in_a[7]), .QN(n212) );
  INVX0 U288 ( .IN(in_b[7]), .QN(n198) );
endmodule

