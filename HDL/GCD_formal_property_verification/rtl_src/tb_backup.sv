`timescale 1ns/1ns
//include file with constrained random values
`include "rtl_src/rng.sv"
module tb; //testbench module 
//declare integer variables
integer input_file, output_file, random_file, comparison_file;
integer i;
integer flag1=0;
integer flag2=0;
//behavioral integer variables
integer x,y;

parameter CYCLE = 100; 
reg clk, reset_n;
reg start, done;
reg [31:0] a_in, b_in; 
reg [31:0] result;


//clock generation for write clock
initial begin
  clk <= 0; 
  forever #(CYCLE/2) clk = ~clk;
end


//release of reset_n relative to two clocks
initial begin
  //open all needed files
  input_file = $fopen("input_data", "rb");
  if (input_file==0) begin 
    $display("ERROR : CAN NOT OPEN input_file"); 
  end
  output_file = $fopen("output_data", "wb");
  if (output_file==0) begin 
    $display("ERROR : CAN NOT OPEN output_file"); 
  end
  random_file = $fopen("random-outputs.txt", "wb");
  if (random_file==0) begin 
    $display("ERROR : CAN NOT OPEN random-outputs.txt"); 
  end
  comparison_file = $fopen("comparison.rpt", "wb");
  if (random_file==0) begin 
    $display("ERROR : CAN NOT OPEN comparison.rpt"); 
  end
  //init gcd
  a_in='x;
  b_in='x;
  start=1'b0;
  reset_n <= 0;
  #(CYCLE * 1.5) reset_n = 1'b1; //reset for 1.5 clock cycles
end

//instantiate class for random number generation
RNG cts = new;
gcd gcd_0(.*); //instantiate the gcd unit

initial begin
  #(CYCLE*4);  //delay after reset
  /******************BEGIN PART 2***********************/
  $display("INPUT FROM \"input_data\" ASCII FILE");
  //read through file until NULL
  while(! $feof(input_file))
  begin 
    void'($fscanf(input_file,"%d %d", a_in, b_in));
    i=0;
    //signal start
    start=1'b1;
    #(CYCLE);
    start=1'b0;
    while(done != 1'b1)
    begin
      #(CYCLE);
      //$display("i=%d",i);
      if(i==2 && flag1 == 0)
      begin
        reset_n = 0;
        #(CYCLE);
        reset_n = 1;
        flag1 = 1;
        $display("RESET TRIGGERED DURING SUBT");
        break;
      end
      if(i==3 && flag2 == 0)
      begin
        reset_n = 0;
        #(CYCLE);
        reset_n = 1;
        flag2 = 1;
        $display("RESET TRIGGERED DURING SWAP");
        break;
      end
      i=i+1;
    end
    i=0;
    $display ("a_in=%d\tb_in=%d\tresult=%d", a_in, b_in, result);
    #(CYCLE*2); //2 cycle delay between trials
  end
$stop;
$fclose(input_file);
$fclose(random_file);
$fclose(output_file);
$fclose(comparison_file);
end

endmodule
