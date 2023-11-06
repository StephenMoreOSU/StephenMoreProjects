module gcd(	input [31:0] a_in,          //operand a
			input [31:0] b_in,          //operand b
			input start,                //validates the input data
			input reset_n,              //reset
			input clk,                  //clock
			input clck,                 //slower clock  			
			output reg [31:0] result,  //output of GCD engine
			output reg done);          //validates output value

	logic			registers_equal		;
	logic			register_a_smaller	;
	logic			swap_registers		;
	logic			subtract_registers	;
	logic			done_flag			;
	logic			[31:0]	register_b			;
	logic 			register_b_equal;

	//register_b
	always_ff @(posedge clck, negedge reset_n) begin
		if (~reset_n)					register_b <= 0;
		else if (start)					register_b <= b_in;
		else if (swap_registers)		register_b <= result;
	end

	//result
	//result resets when reset is asserted (on nedege reset_n)
	always_ff @(posedge clk, negedge reset_n) begin 
		if (~reset_n)					result <= 0;
		else if (start) result <= a_in;
		else if (swap_registers)		result <= register_b;
		else if (subtract_registers)	result <= result - register_b;
	end

	//done
	always_ff @(posedge clk, negedge reset_n) begin
		if (~reset_n)					done <= 0;
		else if (done_flag)				done <= 1;
		else							done <= 0;
	end

	assign registers_equal		= (result == register_b);
	assign register_a_smaller	= (result < register_b);
	assign register_b_equal 	= (register_b == b_in);

	gcd_ctrl gcd_ctrl_0(
		.start					,
		.reset_n				,
		.clk(clck)					,
		.registers_equal		,
		.register_a_smaller		,
		.swap_registers			,
		.subtract_registers		,
		.done_flag				);

	`ifdef FORMAL
		//formal verification block
		always @(posedge clk) begin
			//assert((result == 0 && reset_n == 0) || (result != 0 && reset_n != 0));
			//if reset_n is asserted the result must be 0
			if(~reset_n)
				assert(result == 0);
		end
	`endif

endmodule
