module full_adder #(
    parameter WIDTH=8)
    (input [WIDTH-1:0] a_in,
    input [WIDTH-1:0] b_in,
    input c_in,
    output logic [WIDTH-1:0] sum,
    output logic c_out);

    assign {c_out,sum} = a_in + b_in + c_in;

endmodule
