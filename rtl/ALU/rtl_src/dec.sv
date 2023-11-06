module dec #(
    parameter WIDTH=8)
    (input [WIDTH-1:0] a_in,
    output logic [WIDTH-1:0] a_dec,
    output logic c_out
    );


    always_comb
    begin
        {c_out,a_dec} = a_in - 1;
    end
endmodule