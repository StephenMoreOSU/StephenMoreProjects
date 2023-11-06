module counter #(parameter N=8)
					(input logic clk, reset,
					 input logic en,
					 output logic [N-1:0]q,
					 output logic cout
					 );
	always_ff@(posedge clk, posedge reset)
	begin
		if(reset) q<= 0;
		else if(en) q<= q + 1;
	end
	assign cout = q[N-1];
endmodule
