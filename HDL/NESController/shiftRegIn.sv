module shiftRegIn(input logic clk, reset, sin,
					  output logic [7:0] buttonsActive,
					  output logic sout,
					  output logic [2:0] state);				  
	stateMachine3bit FSM(
		.clk(clk),
		.reset(reset),
		.state(state),
		);
	//Condition at every clock falling edge. This condition tranfers the data from sin to the buttons.
	always_ff @(negedge clk)
		begin 
			if(state == 7) sout <= 1;
			else sout <= 0;
			if(state != 0 && state != 7)
					buttonsActive <= {buttonsActive[6:0], sin};
		end
endmodule