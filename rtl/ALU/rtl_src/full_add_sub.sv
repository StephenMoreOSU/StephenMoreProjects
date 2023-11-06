module full_add_sub #(
    parameter WIDTH=8)
    (input [WIDTH-1:0] a_in,
    input [WIDTH-1:0] b_in,
    input sel,
    output logic [WIDTH-1:0] sum_diff,
    output logic c_out 
    );

    always_comb
	begin
		if (sel)
        	{c_out,sum_diff} = a_in - b_in;
		else
			{c_out,sum_diff} = a_in + b_in;        
	end
endmodule
