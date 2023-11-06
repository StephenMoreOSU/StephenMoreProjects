module ErrorCheckLogic (input logic [10:0]inputData,
                        output logic error
                        );
    assign error = !(!inputData[0] && inputData[10] && (inputData[9] ^ inputData[8] ^ inputData[7]
    ^ inputData[6] ^ inputData[5] ^ inputData[4] ^ inputData[3]
    ^ inputData[2] ^ inputData[1]));
endmodule