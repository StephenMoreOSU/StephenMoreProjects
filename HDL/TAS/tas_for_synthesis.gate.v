/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : L-2016.03-SP2
// Date      : Sun May 17 21:18:48 2020
/////////////////////////////////////////////////////////////


module tas_DW01_add_0 ( A, B, CI, SUM, CO );
  input [10:0] A;
  input [10:0] B;
  output [10:0] SUM;
  input CI;
  output CO;
  wire   n1, n2, n3;
  wire   [10:1] carry;

  FADDX1 U1_6 ( .A(A[6]), .B(B[6]), .CI(carry[6]), .CO(carry[7]), .S(SUM[6])
         );
  FADDX1 U1_5 ( .A(A[5]), .B(B[5]), .CI(carry[5]), .CO(carry[6]), .S(SUM[5])
         );
  FADDX1 U1_4 ( .A(A[4]), .B(B[4]), .CI(carry[4]), .CO(carry[5]), .S(SUM[4])
         );
  FADDX1 U1_3 ( .A(A[3]), .B(B[3]), .CI(carry[3]), .CO(carry[4]), .S(SUM[3])
         );
  FADDX1 U1_2 ( .A(A[2]), .B(B[2]), .CI(carry[2]), .CO(carry[3]), .S(SUM[2])
         );
  FADDX1 U1_7 ( .A(A[7]), .B(B[7]), .CI(carry[7]), .CO(carry[8]), .S(SUM[7])
         );
  FADDX1 U1_1 ( .A(A[1]), .B(B[1]), .CI(n1), .CO(carry[2]), .S(SUM[1]) );
  XOR2X1 U1 ( .IN1(n3), .IN2(A[10]), .Q(SUM[10]) );
  XOR2X1 U2 ( .IN1(B[0]), .IN2(A[0]), .Q(SUM[0]) );
  XOR2X1 U3 ( .IN1(carry[8]), .IN2(A[8]), .Q(SUM[8]) );
  XOR2X1 U4 ( .IN1(n2), .IN2(A[9]), .Q(SUM[9]) );
  AND2X1 U5 ( .IN1(B[0]), .IN2(A[0]), .Q(n1) );
  AND2X1 U6 ( .IN1(carry[8]), .IN2(A[8]), .Q(n2) );
  AND2X1 U7 ( .IN1(n2), .IN2(A[9]), .Q(n3) );
endmodule


module tas_DW01_add_1 ( A, B, CI, SUM, CO );
  input [10:0] A;
  input [10:0] B;
  output [10:0] SUM;
  input CI;
  output CO;
  wire   n1, n2, n3;
  wire   [10:1] carry;

  FADDX1 U1_6 ( .A(A[6]), .B(B[6]), .CI(carry[6]), .CO(carry[7]), .S(SUM[6])
         );
  FADDX1 U1_5 ( .A(A[5]), .B(B[5]), .CI(carry[5]), .CO(carry[6]), .S(SUM[5])
         );
  FADDX1 U1_4 ( .A(A[4]), .B(B[4]), .CI(carry[4]), .CO(carry[5]), .S(SUM[4])
         );
  FADDX1 U1_3 ( .A(A[3]), .B(B[3]), .CI(carry[3]), .CO(carry[4]), .S(SUM[3])
         );
  FADDX1 U1_2 ( .A(A[2]), .B(B[2]), .CI(carry[2]), .CO(carry[3]), .S(SUM[2])
         );
  FADDX1 U1_7 ( .A(A[7]), .B(B[7]), .CI(carry[7]), .CO(carry[8]), .S(SUM[7])
         );
  FADDX1 U1_1 ( .A(A[1]), .B(B[1]), .CI(n1), .CO(carry[2]), .S(SUM[1]) );
  XOR2X1 U1 ( .IN1(n3), .IN2(A[10]), .Q(SUM[10]) );
  XOR2X1 U2 ( .IN1(B[0]), .IN2(A[0]), .Q(SUM[0]) );
  AND2X1 U3 ( .IN1(B[0]), .IN2(A[0]), .Q(n1) );
  XOR2X1 U4 ( .IN1(carry[8]), .IN2(A[8]), .Q(SUM[8]) );
  XOR2X1 U5 ( .IN1(n2), .IN2(A[9]), .Q(SUM[9]) );
  AND2X1 U6 ( .IN1(carry[8]), .IN2(A[8]), .Q(n2) );
  AND2X1 U7 ( .IN1(n2), .IN2(A[9]), .Q(n3) );
endmodule


module tas_DW01_add_2 ( A, B, CI, SUM, CO );
  input [10:0] A;
  input [10:0] B;
  output [10:0] SUM;
  input CI;
  output CO;
  wire   n1, n2, n3;
  wire   [10:1] carry;

  FADDX1 U1_6 ( .A(A[6]), .B(B[6]), .CI(carry[6]), .CO(carry[7]), .S(SUM[6])
         );
  FADDX1 U1_5 ( .A(A[5]), .B(B[5]), .CI(carry[5]), .CO(carry[6]), .S(SUM[5])
         );
  FADDX1 U1_4 ( .A(A[4]), .B(B[4]), .CI(carry[4]), .CO(carry[5]), .S(SUM[4])
         );
  FADDX1 U1_3 ( .A(A[3]), .B(B[3]), .CI(carry[3]), .CO(carry[4]), .S(SUM[3])
         );
  FADDX1 U1_2 ( .A(A[2]), .B(B[2]), .CI(carry[2]), .CO(carry[3]), .S(SUM[2])
         );
  FADDX1 U1_7 ( .A(A[7]), .B(B[7]), .CI(carry[7]), .CO(carry[8]), .S(SUM[7])
         );
  FADDX1 U1_1 ( .A(A[1]), .B(B[1]), .CI(n1), .CO(carry[2]), .S(SUM[1]) );
  NAND2X0 U1 ( .IN1(n2), .IN2(A[9]), .QN(n3) );
  XNOR2X1 U2 ( .IN1(n3), .IN2(A[10]), .Q(SUM[10]) );
  XOR2X1 U3 ( .IN1(B[0]), .IN2(A[0]), .Q(SUM[0]) );
  AND2X1 U4 ( .IN1(B[0]), .IN2(A[0]), .Q(n1) );
  XOR2X1 U5 ( .IN1(carry[8]), .IN2(A[8]), .Q(SUM[8]) );
  XOR2X1 U6 ( .IN1(n2), .IN2(A[9]), .Q(SUM[9]) );
  AND2X1 U7 ( .IN1(carry[8]), .IN2(A[8]), .Q(n2) );
endmodule


module tas_DW01_add_3 ( A, B, CI, SUM, CO );
  input [10:0] A;
  input [10:0] B;
  output [10:0] SUM;
  input CI;
  output CO;
  wire   n1, n2, n3;
  wire   [10:1] carry;

  FADDX1 U1_6 ( .A(A[6]), .B(B[6]), .CI(carry[6]), .CO(carry[7]), .S(SUM[6])
         );
  FADDX1 U1_5 ( .A(A[5]), .B(B[5]), .CI(carry[5]), .CO(carry[6]), .S(SUM[5])
         );
  FADDX1 U1_4 ( .A(A[4]), .B(B[4]), .CI(carry[4]), .CO(carry[5]), .S(SUM[4])
         );
  FADDX1 U1_3 ( .A(A[3]), .B(B[3]), .CI(carry[3]), .CO(carry[4]), .S(SUM[3])
         );
  FADDX1 U1_2 ( .A(A[2]), .B(B[2]), .CI(carry[2]), .CO(carry[3]), .S(SUM[2])
         );
  FADDX1 U1_7 ( .A(A[7]), .B(B[7]), .CI(carry[7]), .CO(carry[8]), .S(SUM[7])
         );
  FADDX1 U1_1 ( .A(A[1]), .B(B[1]), .CI(n1), .CO(carry[2]), .S(SUM[1]) );
  XOR2X1 U1 ( .IN1(n3), .IN2(A[10]), .Q(SUM[10]) );
  XOR2X1 U2 ( .IN1(B[0]), .IN2(A[0]), .Q(SUM[0]) );
  XOR2X1 U3 ( .IN1(carry[8]), .IN2(A[8]), .Q(SUM[8]) );
  XOR2X1 U4 ( .IN1(n2), .IN2(A[9]), .Q(SUM[9]) );
  AND2X1 U5 ( .IN1(B[0]), .IN2(A[0]), .Q(n1) );
  AND2X1 U6 ( .IN1(carry[8]), .IN2(A[8]), .Q(n2) );
  AND2X1 U7 ( .IN1(n2), .IN2(A[9]), .Q(n3) );
endmodule


module tas ( clk_50, clk_2, reset_n, serial_data, data_ena, ram_wr_n, ram_data, 
        ram_addr );
  output [7:0] ram_data;
  output [10:0] ram_addr;
  input clk_50, clk_2, reset_n, serial_data, data_ena;
  output ram_wr_n;
  wire   rx_buffer_bit, N119, N120, N137, N138, N139, N140, N141, N142, N143,
         N144, N145, N146, N147, N153, N154, N155, N156, N157, N158, N159,
         N160, N161, N162, N163, N169, N170, N171, N172, N173, N174, N175,
         N176, N177, N178, N179, N185, N186, N187, N188, N189, N190, N191,
         N192, N193, N194, N195, N328, N329, N330, N331, N332, N333, N334,
         N335, N336, N337, N338, N339, N340, N341, N342, N343, N344, N345,
         N346, N347, N348, N349, N350, N351, N352, N353, N354, N355, N356,
         N357, N358, N359, n95, n96, n97, n98, n99, n100, n101, n102, n106,
         n107, n108, n109, n110, n111, n112, n113, n114, n115, n116, n117,
         n118, n119, n120, n121, n122, n123, n124, n125, n126, n127, n128,
         n129, n130, n131, n132, n133, n134, n135, n136, n137, n138, n139,
         n140, n141, n142, n152, n153, n154, n155, n156, n157, n158, n159,
         n160, n161, n162, n163, n164, n165, n166, n167, n168, n169, n170,
         n171, n172, n173, n174, n175, n176, n177, n178, n179, n180, n181,
         n182, n183, n184, n185, n186, n187, n188, n189, n190, n191, n192,
         n193, n194, n195, n196, n197, n198, n199, n200, n201, n202, n203,
         n204, n205, n206, n207, n208, n209, n210, n211, n212, n213, n214,
         n215, n216, n217, n218, n219, n220, n221, n222, n223, n224, n225,
         n226, n227, n228, n229, n230, n231, n232, n233, n234, n235, n236,
         n237, n238, n239, n240, n241, n242, n243, n244, n245, n246, n247,
         n248, n249, n250;
  wire   [1:0] rx_present_state;
  wire   [2:0] p_byte_count;
  wire   [1:0] rx_next_state;
  wire   [2:0] n_byte_count;
  wire   [7:0] rx_second_order_buffer;
  wire   [2:0] byte_analysis_next_state;
  wire   [10:0] p_accumulator;
  wire   [10:0] n_accumulator;
  wire   [7:0] packet_avg_temp;
  assign ram_data[7] = packet_avg_temp[7];
  assign ram_data[6] = packet_avg_temp[6];
  assign ram_data[5] = packet_avg_temp[5];
  assign ram_data[4] = packet_avg_temp[4];
  assign ram_data[3] = packet_avg_temp[3];
  assign ram_data[2] = packet_avg_temp[2];
  assign ram_data[1] = packet_avg_temp[1];
  assign ram_data[0] = packet_avg_temp[0];

  tas_DW01_add_0 add_298_aco ( .A(p_accumulator), .B({1'b0, 1'b0, 1'b0, N359, 
        N358, N357, N356, N355, N354, N353, N352}), .CI(1'b0), .SUM({N195, 
        N194, N193, N192, N191, N190, N189, N188, N187, N186, N185}) );
  tas_DW01_add_1 add_286_aco ( .A(p_accumulator), .B({1'b0, 1'b0, 1'b0, N351, 
        N350, N349, N348, N347, N346, N345, N344}), .CI(1'b0), .SUM({N179, 
        N178, N177, N176, N175, N174, N173, N172, N171, N170, N169}) );
  tas_DW01_add_2 add_272_aco ( .A(p_accumulator), .B({1'b0, 1'b0, 1'b0, N343, 
        N342, N341, N340, N339, N338, N337, N336}), .CI(1'b0), .SUM({N163, 
        N162, N161, N160, N159, N158, N157, N156, N155, N154, N153}) );
  tas_DW01_add_3 add_258_aco ( .A(p_accumulator), .B({1'b0, 1'b0, 1'b0, N335, 
        N334, N333, N332, N331, N330, N329, N328}), .CI(1'b0), .SUM({N147, 
        N146, N145, N144, N143, N142, N141, N140, N139, N138, N137}) );
  DFFX1 \p_bit_index_reg[0]  ( .D(n141), .CLK(clk_50), .QN(n246) );
  DFFX1 \p_bit_index_reg[1]  ( .D(n140), .CLK(clk_50), .QN(n244) );
  DFFX1 \p_bit_index_reg[2]  ( .D(n139), .CLK(clk_50), .QN(n245) );
  DFFX1 ready_to_write_middle_buff_reg ( .D(n119), .CLK(clk_2), .Q(n168) );
  DFFARX1 \clk2_present_state_reg[0]  ( .D(n250), .CLK(clk_2), .RSTB(reset_n), 
        .Q(ram_wr_n), .QN(n106) );
  DFFARX1 \p_byte_count_reg[2]  ( .D(n_byte_count[2]), .CLK(clk_50), .RSTB(
        reset_n), .QN(n167) );
  DFFX1 ready_to_write_end_buff_reg ( .D(n118), .CLK(clk_2), .Q(n243) );
  DFFX1 rx_buffer_bit_reg ( .D(n142), .CLK(clk_50), .Q(rx_buffer_bit) );
  DFFX1 \rx_second_order_buffer_reg[7]  ( .D(n138), .CLK(clk_50), .Q(
        rx_second_order_buffer[7]), .QN(n160) );
  DFFX1 \rx_second_order_buffer_reg[5]  ( .D(n136), .CLK(clk_50), .Q(
        rx_second_order_buffer[5]), .QN(n159) );
  DFFX1 \rx_second_order_buffer_reg[4]  ( .D(n135), .CLK(clk_50), .Q(
        rx_second_order_buffer[4]), .QN(n152) );
  DFFX1 \rx_second_order_buffer_reg[3]  ( .D(n134), .CLK(clk_50), .Q(
        rx_second_order_buffer[3]), .QN(n155) );
  DFFX1 \rx_second_order_buffer_reg[0]  ( .D(n131), .CLK(clk_50), .Q(
        rx_second_order_buffer[0]), .QN(n153) );
  DFFASX1 \present_ram_addr_reg[5]  ( .D(n111), .CLK(clk_2), .SETB(reset_n), 
        .Q(ram_addr[5]), .QN(n157) );
  DFFASX1 \present_ram_addr_reg[6]  ( .D(n110), .CLK(clk_2), .SETB(reset_n), 
        .Q(ram_addr[6]), .QN(n169) );
  LATCHX1 \rx_serial_input_buffer_reg[7]  ( .CLK(1'b1), .D(N119), .Q(n102) );
  LATCHX1 \rx_serial_input_buffer_reg[6]  ( .CLK(1'b1), .D(N119), .Q(n101) );
  LATCHX1 \rx_serial_input_buffer_reg[5]  ( .CLK(1'b1), .D(N119), .Q(n100) );
  LATCHX1 \rx_serial_input_buffer_reg[4]  ( .CLK(1'b1), .D(N119), .Q(n99) );
  LATCHX1 \rx_serial_input_buffer_reg[3]  ( .CLK(1'b1), .D(N119), .Q(n98) );
  LATCHX1 \rx_serial_input_buffer_reg[2]  ( .CLK(1'b1), .D(N119), .Q(n97) );
  LATCHX1 \rx_serial_input_buffer_reg[1]  ( .CLK(1'b1), .D(N119), .Q(n96) );
  LATCHX1 \rx_serial_input_buffer_reg[0]  ( .CLK(1'b1), .D(N119), .Q(n95) );
  DFFARX1 \rx_present_state_reg[1]  ( .D(rx_next_state[1]), .CLK(clk_50), 
        .RSTB(reset_n), .Q(rx_present_state[1]), .QN(n164) );
  DFFARX1 \byte_analysis_present_state_reg[0]  ( .D(
        byte_analysis_next_state[0]), .CLK(clk_50), .RSTB(reset_n), .Q(n248), 
        .QN(n156) );
  DFFX1 \rx_second_order_buffer_reg[6]  ( .D(n137), .CLK(clk_50), .Q(
        rx_second_order_buffer[6]), .QN(n154) );
  DFFX1 \rx_second_order_buffer_reg[2]  ( .D(n133), .CLK(clk_50), .Q(
        rx_second_order_buffer[2]), .QN(n161) );
  DFFX1 \rx_second_order_buffer_reg[1]  ( .D(n132), .CLK(clk_50), .Q(
        rx_second_order_buffer[1]), .QN(n162) );
  DFFASX1 \present_ram_addr_reg[10]  ( .D(n117), .CLK(clk_2), .SETB(reset_n), 
        .Q(ram_addr[10]) );
  DFFASX1 \present_ram_addr_reg[3]  ( .D(n113), .CLK(clk_2), .SETB(reset_n), 
        .Q(ram_addr[3]), .QN(n166) );
  DFFASX1 \present_ram_addr_reg[1]  ( .D(n115), .CLK(clk_2), .SETB(reset_n), 
        .Q(ram_addr[1]), .QN(n165) );
  DFFASX1 \present_ram_addr_reg[8]  ( .D(n108), .CLK(clk_2), .SETB(reset_n), 
        .Q(ram_addr[8]) );
  DFFASX1 \present_ram_addr_reg[4]  ( .D(n112), .CLK(clk_2), .SETB(reset_n), 
        .Q(ram_addr[4]) );
  DFFASX1 \present_ram_addr_reg[2]  ( .D(n114), .CLK(clk_2), .SETB(reset_n), 
        .Q(ram_addr[2]) );
  DFFARX1 \p_byte_count_reg[0]  ( .D(n_byte_count[0]), .CLK(clk_50), .RSTB(
        reset_n), .Q(p_byte_count[0]) );
  DFFARX1 \byte_analysis_present_state_reg[1]  ( .D(
        byte_analysis_next_state[1]), .CLK(clk_50), .RSTB(reset_n), .Q(n249), 
        .QN(n163) );
  DFFARX1 \p_byte_count_reg[1]  ( .D(n_byte_count[1]), .CLK(clk_50), .RSTB(
        reset_n), .Q(p_byte_count[1]) );
  DFFASX1 \present_ram_addr_reg[7]  ( .D(n109), .CLK(clk_2), .SETB(reset_n), 
        .Q(ram_addr[7]) );
  DFFASX1 \present_ram_addr_reg[0]  ( .D(n116), .CLK(clk_2), .SETB(reset_n), 
        .Q(ram_addr[0]) );
  DFFASX1 \present_ram_addr_reg[9]  ( .D(n107), .CLK(clk_2), .SETB(reset_n), 
        .Q(ram_addr[9]) );
  DFFX1 \p_accumulator_reg[10]  ( .D(n129), .CLK(clk_50), .Q(p_accumulator[10]) );
  DFFARX1 \rx_present_state_reg[0]  ( .D(rx_next_state[0]), .CLK(clk_50), 
        .RSTB(reset_n), .Q(rx_present_state[0]) );
  DFFX1 \p_accumulator_reg[1]  ( .D(n126), .CLK(clk_50), .Q(p_accumulator[1])
         );
  DFFX1 \p_accumulator_reg[2]  ( .D(n125), .CLK(clk_50), .Q(p_accumulator[2])
         );
  DFFX1 \p_accumulator_reg[3]  ( .D(n124), .CLK(clk_50), .Q(p_accumulator[3])
         );
  DFFX1 \p_accumulator_reg[4]  ( .D(n123), .CLK(clk_50), .Q(p_accumulator[4])
         );
  DFFX1 \p_accumulator_reg[5]  ( .D(n122), .CLK(clk_50), .Q(p_accumulator[5])
         );
  DFFX1 \p_accumulator_reg[6]  ( .D(n121), .CLK(clk_50), .Q(p_accumulator[6])
         );
  DFFX1 \p_accumulator_reg[7]  ( .D(n120), .CLK(clk_50), .Q(p_accumulator[7])
         );
  DFFX1 \p_accumulator_reg[0]  ( .D(n130), .CLK(clk_50), .Q(p_accumulator[0])
         );
  DFFX1 \p_accumulator_reg[9]  ( .D(n128), .CLK(clk_50), .Q(p_accumulator[9])
         );
  DFFX1 \p_accumulator_reg[8]  ( .D(n127), .CLK(clk_50), .Q(p_accumulator[8])
         );
  DFFARX1 \byte_analysis_present_state_reg[2]  ( .D(
        byte_analysis_next_state[2]), .CLK(clk_50), .RSTB(reset_n), .Q(n247), 
        .QN(n158) );
  DFFARX1 \packet_avg_temp_reg[7]  ( .D(n_accumulator[9]), .CLK(N120), .RSTB(
        reset_n), .Q(packet_avg_temp[7]) );
  DFFARX1 \packet_avg_temp_reg[6]  ( .D(n_accumulator[8]), .CLK(N120), .RSTB(
        reset_n), .Q(packet_avg_temp[6]) );
  DFFARX1 \packet_avg_temp_reg[5]  ( .D(n_accumulator[7]), .CLK(N120), .RSTB(
        reset_n), .Q(packet_avg_temp[5]) );
  DFFARX1 \packet_avg_temp_reg[4]  ( .D(n_accumulator[6]), .CLK(N120), .RSTB(
        reset_n), .Q(packet_avg_temp[4]) );
  DFFARX1 \packet_avg_temp_reg[3]  ( .D(n_accumulator[5]), .CLK(N120), .RSTB(
        reset_n), .Q(packet_avg_temp[3]) );
  DFFARX1 \packet_avg_temp_reg[2]  ( .D(n_accumulator[4]), .CLK(N120), .RSTB(
        reset_n), .Q(packet_avg_temp[2]) );
  DFFARX1 \packet_avg_temp_reg[1]  ( .D(n_accumulator[3]), .CLK(N120), .RSTB(
        reset_n), .Q(packet_avg_temp[1]) );
  DFFARX1 \packet_avg_temp_reg[0]  ( .D(n_accumulator[2]), .CLK(N120), .RSTB(
        reset_n), .Q(packet_avg_temp[0]) );
  AND3X1 U144 ( .IN1(rx_present_state[0]), .IN2(n164), .IN3(n170), .Q(
        rx_next_state[1]) );
  MUX21X1 U145 ( .IN1(data_ena), .IN2(n171), .S(rx_present_state[0]), .Q(
        rx_next_state[0]) );
  NOR2X0 U146 ( .IN1(rx_present_state[1]), .IN2(n170), .QN(n171) );
  NOR2X0 U147 ( .IN1(n172), .IN2(n245), .QN(n170) );
  MUX21X1 U148 ( .IN1(serial_data), .IN2(rx_buffer_bit), .S(n173), .Q(n142) );
  INVX0 U149 ( .IN(n174), .QN(n141) );
  MUX21X1 U150 ( .IN1(reset_n), .IN2(n175), .S(n246), .Q(n174) );
  MUX21X1 U151 ( .IN1(n176), .IN2(n177), .S(n244), .Q(n140) );
  NOR2X0 U152 ( .IN1(n246), .IN2(n175), .QN(n177) );
  AO21X1 U153 ( .IN1(n246), .IN2(rx_present_state[0]), .IN3(n173), .Q(n176) );
  MUX21X1 U154 ( .IN1(n178), .IN2(n179), .S(n245), .Q(n139) );
  NOR2X0 U155 ( .IN1(n172), .IN2(n175), .QN(n179) );
  NAND2X0 U156 ( .IN1(reset_n), .IN2(rx_present_state[0]), .QN(n175) );
  AO21X1 U157 ( .IN1(rx_present_state[0]), .IN2(n172), .IN3(n173), .Q(n178) );
  OR2X1 U158 ( .IN1(n244), .IN2(n246), .Q(n172) );
  MUX21X1 U159 ( .IN1(n102), .IN2(rx_second_order_buffer[7]), .S(n173), .Q(
        n138) );
  MUX21X1 U160 ( .IN1(n101), .IN2(rx_second_order_buffer[6]), .S(n173), .Q(
        n137) );
  MUX21X1 U161 ( .IN1(n100), .IN2(rx_second_order_buffer[5]), .S(n173), .Q(
        n136) );
  MUX21X1 U162 ( .IN1(n99), .IN2(rx_second_order_buffer[4]), .S(n173), .Q(n135) );
  MUX21X1 U163 ( .IN1(n98), .IN2(rx_second_order_buffer[3]), .S(n173), .Q(n134) );
  MUX21X1 U164 ( .IN1(n97), .IN2(rx_second_order_buffer[2]), .S(n173), .Q(n133) );
  MUX21X1 U165 ( .IN1(n96), .IN2(rx_second_order_buffer[1]), .S(n173), .Q(n132) );
  MUX21X1 U166 ( .IN1(n95), .IN2(rx_second_order_buffer[0]), .S(n173), .Q(n131) );
  MUX21X1 U167 ( .IN1(n180), .IN2(p_accumulator[0]), .S(n173), .Q(n130) );
  AO221X1 U168 ( .IN1(N137), .IN2(n181), .IN3(N185), .IN4(n247), .IN5(n182), 
        .Q(n180) );
  AO22X1 U169 ( .IN1(N169), .IN2(n183), .IN3(N153), .IN4(n184), .Q(n182) );
  MUX21X1 U170 ( .IN1(n185), .IN2(p_accumulator[10]), .S(n173), .Q(n129) );
  AO221X1 U171 ( .IN1(N147), .IN2(n181), .IN3(N195), .IN4(n247), .IN5(n186), 
        .Q(n185) );
  AO22X1 U172 ( .IN1(N179), .IN2(n183), .IN3(N163), .IN4(n184), .Q(n186) );
  MUX21X1 U173 ( .IN1(n_accumulator[9]), .IN2(p_accumulator[9]), .S(n173), .Q(
        n128) );
  AO221X1 U174 ( .IN1(N146), .IN2(n181), .IN3(n247), .IN4(N194), .IN5(n187), 
        .Q(n_accumulator[9]) );
  AO22X1 U175 ( .IN1(N178), .IN2(n183), .IN3(N162), .IN4(n184), .Q(n187) );
  MUX21X1 U176 ( .IN1(n_accumulator[8]), .IN2(p_accumulator[8]), .S(n173), .Q(
        n127) );
  AO221X1 U177 ( .IN1(N145), .IN2(n181), .IN3(N193), .IN4(n247), .IN5(n188), 
        .Q(n_accumulator[8]) );
  AO22X1 U178 ( .IN1(N177), .IN2(n183), .IN3(N161), .IN4(n184), .Q(n188) );
  MUX21X1 U179 ( .IN1(n189), .IN2(p_accumulator[1]), .S(n173), .Q(n126) );
  AO221X1 U180 ( .IN1(N138), .IN2(n181), .IN3(N186), .IN4(n247), .IN5(n190), 
        .Q(n189) );
  AO22X1 U181 ( .IN1(N170), .IN2(n183), .IN3(N154), .IN4(n184), .Q(n190) );
  MUX21X1 U182 ( .IN1(n_accumulator[2]), .IN2(p_accumulator[2]), .S(n173), .Q(
        n125) );
  AO221X1 U183 ( .IN1(N139), .IN2(n181), .IN3(N187), .IN4(n247), .IN5(n191), 
        .Q(n_accumulator[2]) );
  AO22X1 U184 ( .IN1(N171), .IN2(n183), .IN3(N155), .IN4(n184), .Q(n191) );
  MUX21X1 U185 ( .IN1(n_accumulator[3]), .IN2(p_accumulator[3]), .S(n173), .Q(
        n124) );
  AO221X1 U186 ( .IN1(N140), .IN2(n181), .IN3(N188), .IN4(n247), .IN5(n192), 
        .Q(n_accumulator[3]) );
  AO22X1 U187 ( .IN1(N172), .IN2(n183), .IN3(N156), .IN4(n184), .Q(n192) );
  MUX21X1 U188 ( .IN1(n_accumulator[4]), .IN2(p_accumulator[4]), .S(n173), .Q(
        n123) );
  AO221X1 U189 ( .IN1(N141), .IN2(n181), .IN3(N189), .IN4(n247), .IN5(n193), 
        .Q(n_accumulator[4]) );
  AO22X1 U190 ( .IN1(N173), .IN2(n183), .IN3(N157), .IN4(n184), .Q(n193) );
  MUX21X1 U191 ( .IN1(n_accumulator[5]), .IN2(p_accumulator[5]), .S(n173), .Q(
        n122) );
  AO221X1 U192 ( .IN1(N142), .IN2(n181), .IN3(N190), .IN4(n247), .IN5(n194), 
        .Q(n_accumulator[5]) );
  AO22X1 U193 ( .IN1(N174), .IN2(n183), .IN3(N158), .IN4(n184), .Q(n194) );
  MUX21X1 U194 ( .IN1(n_accumulator[6]), .IN2(p_accumulator[6]), .S(n173), .Q(
        n121) );
  AO221X1 U195 ( .IN1(N143), .IN2(n181), .IN3(N191), .IN4(n247), .IN5(n195), 
        .Q(n_accumulator[6]) );
  AO22X1 U196 ( .IN1(N175), .IN2(n183), .IN3(N159), .IN4(n184), .Q(n195) );
  MUX21X1 U197 ( .IN1(n_accumulator[7]), .IN2(p_accumulator[7]), .S(n173), .Q(
        n120) );
  AO221X1 U198 ( .IN1(N144), .IN2(n181), .IN3(N192), .IN4(n247), .IN5(n196), 
        .Q(n_accumulator[7]) );
  AO22X1 U199 ( .IN1(N176), .IN2(n183), .IN3(N160), .IN4(n184), .Q(n196) );
  MUX21X1 U200 ( .IN1(n197), .IN2(n168), .S(n173), .Q(n119) );
  NOR3X0 U201 ( .IN1(n198), .IN2(n158), .IN3(n199), .QN(n197) );
  MUX21X1 U202 ( .IN1(n168), .IN2(n243), .S(n173), .Q(n118) );
  INVX0 U203 ( .IN(reset_n), .QN(n173) );
  AO22X1 U204 ( .IN1(n200), .IN2(n201), .IN3(ram_addr[10]), .IN4(n202), .Q(
        n117) );
  OR2X1 U205 ( .IN1(n203), .IN2(ram_addr[9]), .Q(n202) );
  NOR2X0 U206 ( .IN1(ram_addr[9]), .IN2(ram_addr[10]), .QN(n200) );
  AO21X1 U207 ( .IN1(ram_addr[0]), .IN2(n204), .IN3(n205), .Q(n116) );
  XNOR2X1 U208 ( .IN1(n165), .IN2(n205), .Q(n115) );
  AO21X1 U209 ( .IN1(ram_addr[2]), .IN2(n206), .IN3(n207), .Q(n114) );
  NAND2X0 U210 ( .IN1(n205), .IN2(n165), .QN(n206) );
  NOR2X0 U211 ( .IN1(n204), .IN2(ram_addr[0]), .QN(n205) );
  XNOR2X1 U212 ( .IN1(n166), .IN2(n207), .Q(n113) );
  AO21X1 U213 ( .IN1(ram_addr[4]), .IN2(n208), .IN3(n209), .Q(n112) );
  NAND2X0 U214 ( .IN1(n207), .IN2(n166), .QN(n208) );
  NOR2X0 U215 ( .IN1(n204), .IN2(n210), .QN(n207) );
  XNOR2X1 U216 ( .IN1(n157), .IN2(n209), .Q(n111) );
  NAND2X0 U217 ( .IN1(n211), .IN2(n212), .QN(n110) );
  AO21X1 U218 ( .IN1(n209), .IN2(n157), .IN3(n169), .Q(n211) );
  AND2X1 U219 ( .IN1(n250), .IN2(n213), .Q(n209) );
  INVX0 U220 ( .IN(n204), .QN(n250) );
  XNOR2X1 U221 ( .IN1(ram_addr[7]), .IN2(n212), .Q(n109) );
  NAND2X0 U222 ( .IN1(n214), .IN2(n203), .QN(n108) );
  OAI21X1 U223 ( .IN1(n212), .IN2(ram_addr[7]), .IN3(ram_addr[8]), .QN(n214)
         );
  OR2X1 U224 ( .IN1(n215), .IN2(n204), .Q(n212) );
  XNOR2X1 U225 ( .IN1(ram_addr[9]), .IN2(n203), .Q(n107) );
  INVX0 U226 ( .IN(n201), .QN(n203) );
  NOR4X0 U227 ( .IN1(n215), .IN2(n204), .IN3(ram_addr[7]), .IN4(ram_addr[8]), 
        .QN(n201) );
  NAND2X0 U228 ( .IN1(n243), .IN2(n106), .QN(n204) );
  NAND3X0 U229 ( .IN1(n157), .IN2(n169), .IN3(n213), .QN(n215) );
  NOR3X0 U230 ( .IN1(ram_addr[3]), .IN2(ram_addr[4]), .IN3(n210), .QN(n213) );
  OR3X1 U231 ( .IN1(ram_addr[1]), .IN2(ram_addr[2]), .IN3(ram_addr[0]), .Q(
        n210) );
  AO22X1 U232 ( .IN1(n216), .IN2(n183), .IN3(n247), .IN4(n217), .Q(
        byte_analysis_next_state[2]) );
  OR2X1 U233 ( .IN1(n198), .IN2(n199), .Q(n217) );
  AO221X1 U234 ( .IN1(n249), .IN2(n218), .IN3(n219), .IN4(n181), .IN5(n184), 
        .Q(byte_analysis_next_state[1]) );
  INVX0 U235 ( .IN(n220), .QN(n219) );
  NAND2X0 U236 ( .IN1(n216), .IN2(n158), .QN(n218) );
  INVX0 U237 ( .IN(n221), .QN(n216) );
  AO221X1 U238 ( .IN1(n222), .IN2(n184), .IN3(n183), .IN4(n221), .IN5(n223), 
        .Q(byte_analysis_next_state[0]) );
  NAND2X0 U239 ( .IN1(n224), .IN2(n225), .QN(n223) );
  NAND2X0 U240 ( .IN1(n181), .IN2(n220), .QN(n225) );
  NOR2X0 U241 ( .IN1(n156), .IN2(n249), .QN(n181) );
  MUX21X1 U242 ( .IN1(n156), .IN2(n226), .S(n158), .Q(n224) );
  NAND4X0 U243 ( .IN1(n227), .IN2(n228), .IN3(n229), .IN4(n230), .QN(n226) );
  NOR4X0 U244 ( .IN1(n231), .IN2(n232), .IN3(n160), .IN4(n153), .QN(n230) );
  MUX21X1 U245 ( .IN1(n233), .IN2(n234), .S(n159), .Q(n232) );
  NAND3X0 U246 ( .IN1(rx_second_order_buffer[6]), .IN2(n161), .IN3(
        rx_second_order_buffer[1]), .QN(n234) );
  NAND3X0 U247 ( .IN1(n162), .IN2(n154), .IN3(rx_second_order_buffer[2]), .QN(
        n233) );
  AND3X1 U248 ( .IN1(n163), .IN2(n152), .IN3(n155), .Q(n229) );
  NOR2X0 U249 ( .IN1(n156), .IN2(n163), .QN(n183) );
  NOR2X0 U250 ( .IN1(n163), .IN2(n248), .QN(n184) );
  INVX0 U251 ( .IN(n235), .QN(n222) );
  NOR2X0 U252 ( .IN1(n160), .IN2(n198), .QN(N359) );
  NOR2X0 U253 ( .IN1(n154), .IN2(n198), .QN(N358) );
  NOR2X0 U254 ( .IN1(n159), .IN2(n198), .QN(N357) );
  NOR2X0 U255 ( .IN1(n152), .IN2(n198), .QN(N356) );
  NOR2X0 U256 ( .IN1(n155), .IN2(n198), .QN(N355) );
  NOR2X0 U257 ( .IN1(n161), .IN2(n198), .QN(N354) );
  NOR2X0 U258 ( .IN1(n162), .IN2(n198), .QN(N353) );
  NOR2X0 U259 ( .IN1(n153), .IN2(n198), .QN(N352) );
  NOR2X0 U260 ( .IN1(n160), .IN2(n221), .QN(N351) );
  NOR2X0 U261 ( .IN1(n154), .IN2(n221), .QN(N350) );
  NOR2X0 U262 ( .IN1(n159), .IN2(n221), .QN(N349) );
  NOR2X0 U263 ( .IN1(n152), .IN2(n221), .QN(N348) );
  NOR2X0 U264 ( .IN1(n155), .IN2(n221), .QN(N347) );
  NOR2X0 U265 ( .IN1(n161), .IN2(n221), .QN(N346) );
  NOR2X0 U266 ( .IN1(n162), .IN2(n221), .QN(N345) );
  NOR2X0 U267 ( .IN1(n153), .IN2(n221), .QN(N344) );
  NAND3X0 U268 ( .IN1(n231), .IN2(n228), .IN3(n_byte_count[2]), .QN(n221) );
  NOR2X0 U269 ( .IN1(n160), .IN2(n235), .QN(N343) );
  NOR2X0 U270 ( .IN1(n154), .IN2(n235), .QN(N342) );
  NOR2X0 U271 ( .IN1(n159), .IN2(n235), .QN(N341) );
  NOR2X0 U272 ( .IN1(n152), .IN2(n235), .QN(N340) );
  NOR2X0 U273 ( .IN1(n155), .IN2(n235), .QN(N339) );
  NOR2X0 U274 ( .IN1(n161), .IN2(n235), .QN(N338) );
  NOR2X0 U275 ( .IN1(n162), .IN2(n235), .QN(N337) );
  NOR2X0 U276 ( .IN1(n153), .IN2(n235), .QN(N336) );
  NAND3X0 U277 ( .IN1(n227), .IN2(n_byte_count[1]), .IN3(n_byte_count[0]), 
        .QN(n235) );
  NOR2X0 U278 ( .IN1(n160), .IN2(n220), .QN(N335) );
  NOR2X0 U279 ( .IN1(n154), .IN2(n220), .QN(N334) );
  NOR2X0 U280 ( .IN1(n159), .IN2(n220), .QN(N333) );
  NOR2X0 U281 ( .IN1(n152), .IN2(n220), .QN(N332) );
  NOR2X0 U282 ( .IN1(n155), .IN2(n220), .QN(N331) );
  NOR2X0 U283 ( .IN1(n161), .IN2(n220), .QN(N330) );
  NOR2X0 U284 ( .IN1(n162), .IN2(n220), .QN(N329) );
  NOR2X0 U285 ( .IN1(n153), .IN2(n220), .QN(N328) );
  NAND3X0 U286 ( .IN1(n231), .IN2(n227), .IN3(n_byte_count[1]), .QN(n220) );
  INVX0 U287 ( .IN(n_byte_count[0]), .QN(n231) );
  OA21X1 U288 ( .IN1(n158), .IN2(n199), .IN3(n236), .Q(N120) );
  INVX0 U289 ( .IN(n198), .QN(n236) );
  NAND3X0 U290 ( .IN1(n228), .IN2(n_byte_count[2]), .IN3(n_byte_count[0]), 
        .QN(n198) );
  MUX21X1 U291 ( .IN1(p_byte_count[0]), .IN2(n237), .S(n238), .Q(
        n_byte_count[0]) );
  INVX0 U292 ( .IN(n239), .QN(n237) );
  INVX0 U293 ( .IN(n227), .QN(n_byte_count[2]) );
  MUX21X1 U294 ( .IN1(n240), .IN2(n241), .S(n167), .Q(n227) );
  NAND3X0 U295 ( .IN1(n239), .IN2(n238), .IN3(p_byte_count[1]), .QN(n241) );
  AND2X1 U296 ( .IN1(p_byte_count[0]), .IN2(n238), .Q(n240) );
  INVX0 U297 ( .IN(n_byte_count[1]), .QN(n228) );
  XNOR2X1 U298 ( .IN1(n242), .IN2(p_byte_count[1]), .Q(n_byte_count[1]) );
  NAND2X0 U299 ( .IN1(n239), .IN2(n238), .QN(n242) );
  NOR2X0 U300 ( .IN1(n164), .IN2(rx_present_state[0]), .QN(n238) );
  OA21X1 U301 ( .IN1(n167), .IN2(p_byte_count[1]), .IN3(p_byte_count[0]), .Q(
        n239) );
  NAND2X0 U302 ( .IN1(n156), .IN2(n163), .QN(n199) );
  AND2X1 U303 ( .IN1(n164), .IN2(rx_buffer_bit), .Q(N119) );
endmodule

