`timescale 1ns/1ns
//include file with constrained random values
`include "rtl_src/bus.sv"
module tb; //testbench module 
//declare integer variables
integer input_file, output_file, random_file, comparison_file;
integer i;

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
    a_in='x;
    b_in='x;
    start=1'b0;
    reset_n <= 0;
    #(CYCLE * 1.5) reset_n = 1'b1; //reset for 1.5 clock cycles
end

//cg_out cgi_out = new; //covergroup instantiation
//cg_in cgi_ain = new;
//cg_fsmtrans cgi_fsm = new;
Bus cts = new;

gcd gcd_0(.*); //instantiate the gcd unit

initial begin
  #(CYCLE*4);  //delay after reset
  
  $display("INPUT FROM \"input_data\" ASCII FILE");
  while(! $feof(input_file))
  begin 
    void'($fscanf(input_file,"%d %d", a_in, b_in));
    //signal start
    start=1'b1;
    #(CYCLE);
    start=1'b0;
    while(done != 1'b1) #(CYCLE);
    $display ("a_in=%d\tb_in=%d\tresult=%d", a_in, b_in, result);
    #(CYCLE*2); //2 cycle delay between trials
  end
  
  $display("RANDOMIZED INPUTS");
  repeat(100)
  if(cts.randomize() == 1)
  begin
    //$display("a_in=%d b_in=%d", cts.a_in, cts.b_in);
    /*input_file = $fopen("input_data", "wb");
    if(input_file==0)
      $display("ERROR: CANNOT OPEN random-outputs.txt")
    else
      $fdisplay()
      */
    //  end
    a_in=cts.a_in;
    b_in=cts.b_in;
    start=1'b1;
    #(CYCLE);
    start=1'b0;
    while(done != 1'b1) #(CYCLE);
    $display ("a_in=%d\tb_in=%d\tresult=%d", a_in, b_in, result);
    $fdisplay(random_file,"%d %d %d", a_in, b_in, result);
    #(CYCLE*2); //2 cycle delay between trials
  end


  $fclose(input_file);
  input_file = $fopen("input_data", "rb");
  if (input_file==0) begin 
    $display("ERROR : CAN NOT OPEN input_file"); 
  end
  
  $display("INPUT FROM \"input_data\" ASCII FILE\nCOMPARING GCD RESULTS WITH SOFTWARE");
  while(! $feof(input_file)) 
  begin 
    void'($fscanf(input_file,"%d %d", a_in, b_in));
    //signal start
    start=1'b1;
    #(CYCLE);
    start=1'b0;
    while(done != 1'b1) #(CYCLE);
    $display ("a_in=%d\tb_in=%d\tresult=%d", a_in, b_in, result);
    /********TESTBENCH GCD COMPARISON**********/
    x = a_in;
    y = b_in;
    //$display("x:%d y:%d", x, y);
    while(x != y)
    begin
      if(x > y)
        x = x-y;
      else
        y = y-x;
    end
    //$display("behavioral result:%d",x);
    if(x == result)
    begin
      $fdisplay(comparison_file, "a_in b_in match");
      $fdisplay(comparison_file, "%d %d gcd: %d behavioral: %d", a_in, b_in, result, x);
    end
    #(CYCLE*2); //2 cycle delay between trials
  end
$stop;
$fclose(input_file);
$fclose(random_file);
$fclose(output_file);
$fclose(comparison_file);
end

endmodule
