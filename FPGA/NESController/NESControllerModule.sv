module NESControllerModule(
					 input logic clk_10MHz,
					 input logic reset,
					 input logic NESdata,
					 output logic latchWire,
					 output logic NESClk,
					 output logic [7:0] ButtonLED,
					 output logic [2:0] stateWire
					 );
					 
	logic fullReg;
	logic [7:0] buttonsActive;
	
	/*counter #(23)clkDelayCounter(
		.clk(clk_10MHz),
		.reset(reset_n),
		.enable(1),
		.q(clock_divided)
		);*/
	shiftRegIn NESRegIn(
		.clk(clk_10MHz),
		.sin(NESdata),
		.reset(reset),
		.buttonsActive(buttonsActive),
		.sout(fullReg),
		.state(stateWire)
		);
		
	buttonInputs buttons(
		.clk(fullReg),
		.reset(reset),
		.nextInput(buttonsActive),
		.Input(ButtonLED)
		);
		
	clockControl NESClock(
		.clk(clk_10MHz),
		.reset(reset),
		.setClk(NESClk)
		);
	latch NESLatch(
		.clk(clk_10MHz),
		.reset(reset),
		.latchVal(latchWire)
		);
	
	endmodule