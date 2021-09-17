class RNG;
rand bit[31:0] a_in;
rand bit[31:0] b_in;
//constraint word_align {addr[1:0]==2'b0;}
//constraint low_addr {addr <= 500; addr >= 10;}
constraint ain_bounds {a_in <= 32'hfffff; a_in >= 32'h1;}
constraint bin_bounds {b_in <= 32'hfffff; b_in >= 32'h1;}
endclass