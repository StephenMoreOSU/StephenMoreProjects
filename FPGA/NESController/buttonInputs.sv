module buttonInputs(input logic clk, reset,
						input logic [7:0] nextInput,
						output logic [7:0]Input
						);
	always_ff @(posedge clk, posedge reset)
		begin 
			if(reset) Input <= 0;
			else Input <= nextInput;
		end
endmodule