`timescale 1ns/1ns

module gcd_tb; //testbench module 

integer input_file, output_file, in, out;
integer i;

parameter CYCLE = 100; 
parameter WIDTH = 32;
// declare signals clk, reset_n, start, done
//inputs
logic clk, reset_n, start, done;
//declare input numbers a_in and b_in of appropriate width, and output number result
logic [WIDTH-1:0] a_in, b_in, result;


//create a clock clk with period CYCLE 
initial
begin
  clk = 1'b1;
  forever #(CYCLE/2) clk = ~clk;
end

//release of reset_n relative to two clocks
initial begin
    input_file  = $fopen("input_data", "rb");
    if (input_file==0) begin 
      $display("ERROR : CAN NOT OPEN input_file"); 
    end
    output_file = $fopen("output_data", "wb");
    if (output_file==0) begin 
      $display("ERROR : CAN NOT OPEN output_file"); 
    end
    // initalize a_in, b_in to 'x, initialize start to 1
    a_in = 'x;
    b_in = 'x;
    start = 1;
    //start the design in reset mode then de-assert the reset after 1.5 clock cycles
    reset_n = 0;
    #(CYCLE*(1.5)) reset_n = 1;
end

//instantiate the gcd unit and connect its ports
gcd dut(
  .a_in     (a_in),
  .b_in     (b_in),
  .start    (start),
  .reset_n  (reset_n),
  .clk      (clk),
  .result   (result),
  .done     (done)
);

function string get_time();
  int fp;
  //stores time/date to system_time
  void'($system("date +%X--%x > system_time"));
  fp = $fopen("system_time", "r");
  void'($fscanf(fp, "%s", get_time));
  $fclose(fp);
  void'($system("rm -f system_time"));
endfunction

initial begin

  #(CYCLE*4);  //delay after reset
  while(! $feof(input_file)) begin 
   void'($fscanf(input_file,"%d %d", a_in, b_in));
   start=1'b1;
   #(CYCLE);
   start=1'b0;
   while(done != 1'b1) #(CYCLE);
   // display the current time, the values of the input numbers and the result
   $display("System Time: %s",get_time());
   $display("a_in=\t%d\tb_in=\t%d\tresult=\t%d\n", a_in, b_in, result);
   $fdisplay(output_file,"a_in=\t%d\tb_in=\t%d\tresult=\t%d", a_in, b_in, result);
   #(CYCLE*2); //2 cycle delay between trials
  end
$stop;
$fclose(input_file);
end

endmodule
