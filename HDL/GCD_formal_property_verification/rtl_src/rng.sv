class RNG;
//This class instantiates two random 32 bit numbers from 'h1 to 'hfffff 
rand bit[31:0] a_in;
rand bit[31:0] b_in;
//declare constraints on both variables
constraint ain_bounds {a_in <= 500;}
constraint bin_bounds {b_in >= 0;}
constraint added_bounds {a_in + b_in == 500;}
endclass