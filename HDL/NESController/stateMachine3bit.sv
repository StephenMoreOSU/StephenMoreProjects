module stateMachine3bit(input logic clk, reset,
						  output logic [2:0]state
						  );
logic [2:0] stateNext;
	//State machine
	always_ff @(posedge clk, posedge reset)
		begin
			if(reset) state <= 0;
			else state <= stateNext;
		end
	//stateNext comb logic
	always_comb
		begin
			case(state)
				0:		stateNext = 1;
				1:		stateNext = 2;
				2:		stateNext = 3;
				3:		stateNext = 4;
				4:		stateNext = 5;
				5:		stateNext = 6;
				6:		stateNext = 7;
				7:		stateNext = 0;
				default: stateNext = 0;
			endcase
		end
endmodule