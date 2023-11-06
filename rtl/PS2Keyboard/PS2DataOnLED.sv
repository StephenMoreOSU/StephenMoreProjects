module PS2dataOnLED(input logic regReset,
					  input logic load,
					  input logic clk,
					  output logic [7:0]ledOut
					  );
	logic delayedClock;
	logic [10:0]testData = 11'b00000111111;
	logic ps2Data;
	counter #(23) delayCount(
		.clk(clk),
		.en(1),
		.cout(delayedClk)
	);
	
	/*
	input logic ps2_data,
                    input logic ps2_clk,
                    input logic clk,
                    output logic [7:0] ps2_code,
                    output logic ps2_code_new
	*/
	
	shiftReg #(11) shiftIn(
		.reset(regReset),
		.load(load),
		.d(testData),
		.clk(delayedClk),
		.sout(ps2Data)
	);
		
	TopLevelPS2 PS2(
		.ps2_clk(delayedClk),
		.clk(clk),
		.ps2_code(ledOut)
	);
	
	
endmodule