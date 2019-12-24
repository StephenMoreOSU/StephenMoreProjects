module TopLevelPS2 (input logic ps2_data,
                    input logic ps2_clk,
                    input logic clk,
                    output logic [7:0] ps2_code,
                    output logic ps2_code_new
                   );
    logic dataDebounceIn;
    logic ps2ClkDebounceIn;
    logic debounceDataResult;
    logic debouncePS2ClkResult;
    logic [10:0]shiftRegOut;
    logic [7:0]ps2RegData; /* shiftRegOut [8:1]*/
    logic error;
    logic errorEnable;
    logic IdleCounterOut;
    sync dataSync(
        .clk(clk),
        .d(ps2_data),
        .q(dataDebounceIn)
    );
    sync ps2ClkSync(
        .clk(clk),
        .d(ps2_clk),
        .q(ps2ClkDebounceIn)
    );
	 /* USE DEBOUNCE LOGIC FOR REAL APPLICATION */
	 /*
    Debounce debounceData(
        .button(dataDebounceIn),
        .clk(clk),
        .result(debounceDataResult)
    );
    Debounce debouncePS2Clk(
        .button(ps2ClkDebounceIn),
        .clk(clk),
        .result(debouncePS2ClkResult)
    );
	 */
	 assign debounceDataResult = dataDebounceIn;
	 assign debouncePS2ClkResult = ps2ClkDebounceIn;

    shiftReg #(11) PS2ShiftReg(
        .clk(!debouncePS2ClkResult),
        .sin(debounceDataResult),
        .q(shiftRegOut)
    );
    ErrorCheckLogic ErrorCheck(
        .inputData(shiftRegOut),
        .error(error)
    );
	 /*
    IdleCounter countCheck(
            .SCLR(!debouncePS2ClkResult),
            .clk(clk),
            .INC(!IdleCounterOut),
            .compared(IdleCounterOut)
    );
	 /*
    /*

    (input logic SCLR,
                    input logic clk,
                    input logic INC,
                    output logic compare
                    );
    /**/
    assign errorEnable = (error /*&& IdleCounterOut*/);
    assign ps2RegData = shiftRegOut[8:1];
    always_ff @(posedge clk)
    begin
        ps2_code_new <= errorEnable;
        if(errorEnable)
        begin
             ps2_code <= ps2RegData;
        end
    end
endmodule
