module inc #(
    parameter WIDTH=8)
    (input [WIDTH-1:0] a_in,
    output logic [WIDTH-1:0] a_inc,
    output logic c_out
    );

    assign {c_out,a_inc} = a_in + 1;
endmodule