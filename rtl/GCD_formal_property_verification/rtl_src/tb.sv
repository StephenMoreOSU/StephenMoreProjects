`timescale 1ns/1ns
`include "GCDInput.sv"
`include "covergroups.sv"

module tb; 

integer input_file, output_file, in, out;
integer i;

parameter CYCLE = 100; 
parameter CYCLE2 = 101; 

reg clk, clck, reset_n;
reg start, done;
reg [31:0] a_in, b_in; 
reg [31:0] result;

GCDInput gcdpair = new; 

//clock generation for write clock
initial begin
  clk <= 0; 
  forever #(CYCLE/2) clk = ~clk;
end
initial begin 
  clck <= 0;
  forever #(CYCLE2/2) clck = ~clck; 
end

initial begin
    input_file  = $fopen("input.data", "rb");

    if (input_file==0) begin 
      $display("ERROR : CAN NOT OPEN input_file"); 
    end
    output_file = $fopen("output.data", "wb");
    if (output_file==0) begin 
      $display("ERROR : CAN NOT OPEN output_file"); 
    end
    a_in='x;
    b_in='x;
    start=1'b0;
    reset_n <= 0;
    #(CYCLE * 1.5) reset_n = 1'b1; //reset for 1.5 clock cycles
end


cg_result cgi_result     = new;
cg_fsm    cgi_fsm        = new;
cg_fsmtrans cgi_fsmtrans = new; 

gcd gcd_0(.*); //instantiate the gcd unit

initial begin

  // Read inputs from input.data file 
  $display(" --- Reading from file ---");
  #(CYCLE*4);  //delay after reset
  while(! $feof(input_file)) begin 
   $fscanf(input_file,"%d %d", a_in, b_in);
   start=1'b1;
   #(CYCLE);
   start=1'b0;
   while(done != 1'b1) #(CYCLE);
   $display ("a_in=%d   b_in=%d   result=%d", a_in, b_in, result);
   #(CYCLE*2); //2 cycle delay between trials
  end
  $fclose(input_file);


  // Generate inputs at random
  $display("Generating random inputs"); 
  repeat (10) 
	if (gcdpair.randomize() == 1) begin
		$display("Rand a_in = %d, b_in = %d, sum=%d", gcdpair.a_in, gcdpair.b_in, gcdpair.a_in+gcdpair.b_in);
               	a_in = gcdpair.a_in;
		b_in = gcdpair.b_in;
		start = 1'b1;
		#(CYCLE);
		start = 1'b0;
		while(done !=1'b1) #(CYCLE);
        end
	else
		$display("Randomization of pair failed");

   $stop;

end

endmodule
