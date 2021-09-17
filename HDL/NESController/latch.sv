module latch(input logic clk, reset,
				output logic latchVal
				);
	//Make the same state machine for the latch as used in the RegisterIN
	logic [2:0] state;
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
	//logic for LatchVal
	assign latchVal = (state == 0);
endmodule 