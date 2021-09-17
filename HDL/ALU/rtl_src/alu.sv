module alu(
    input   [7:0]	in_a,			//input a
    input	[7:0]	in_b,			//input b
    input	[3:0]	opcode,		//opcode input
    output reg	[7:0]	alu_out,	//alu output
    output reg		alu_zero,	//logic '1' when alu_output [7:0] is 
    // all zeros
    output reg		alu_carry	//indicates a carry out from ALU 
    );
    parameter c_add = 4'h1;
    parameter c_sub = 4'h2;
    parameter c_inc = 4'h3;
    parameter c_dec = 4'h4;
    parameter c_or = 4'h5;
    parameter c_and = 4'h6;
    parameter c_xor = 4'h7;
    parameter c_shr = 4'h8;
    parameter c_shl = 4'h9;
    parameter c_onescomp = 4'ha;
    parameter c_twoscomp = 4'hb;

    //typedef enum logic[3:0] {c_add, c_sub, c_inc, c_dec, c_or, c_and, c_xor, c_shr, c_shl, c_onescomp, c_twoscomp} alu_op;
    //alu_op exe_op;
/*
    //add_sub inputs and outputs
    logic [7:0] in_a_add_sub, in_b_add_sub, out_add_sub;
    logic sel_add_sub, add_sub_carry;

    // inc inputs and outputs
    logic [7:0] in_a_inc, out_a_inc;
    logic out_c_inc;
    
    // dec inputs and outputs
    logic [7:0] in_a_dec, out_a_dec;
    logic out_c_dec;
*/
    //comp logic element
    logic [7:0] temp_onescomp;

    //ALU Result
    logic [7:0] alu_result;
    logic carry_out, zero_bit;

    assign alu_out = alu_result;
    assign alu_carry = carry_out;
    assign alu_zero = zero_bit;

/*    full_add_sub add_sub(
        .a_in       (in_a_add_sub),
        .b_in       (in_b_add_sub),
        .sel          (sel_add_sub),
        .sum_diff   (out_add_sub),
        .c_out      (add_sub_carry)
    );

    inc incr(
        .a_in       (in_a_inc),
        .a_inc      (out_a_inc),
        .c_out      (out_c_inc)
    );

    dec decr(
        .a_in       (in_a_dec),
        .a_dec      (out_a_dec),
        .c_out      (out_c_dec)
    );
*/
    always_comb
    begin
        unique case (opcode)
            c_add:
            begin
                {carry_out,alu_result} = in_a + in_b;
                /*
                //inputs
                sel_add_sub = 1'b0; //set select to 0 to choose add
                in_a_add_sub = in_a;
                in_b_add_sub = in_b;
                //outputs
                alu_result = out_add_sub;
                carry_out = add_sub_carry;
                */
            end
            c_sub:
            begin
                {carry_out,alu_result} = in_a - in_b;
            end
            c_inc:
            begin
                {carry_out,alu_result} = in_a + 1;
            end
            c_dec:
            begin
                {carry_out, alu_result} = in_a - 1;
            end
            c_or:
            begin
                //outputs
                alu_result = in_a|in_b;
                carry_out = 1'b0;
            end
            c_and:
            begin
                //outputs
                alu_result = in_a&in_b;
                carry_out = 1'b0;
            end
            c_xor:
            begin
                //outputs
                alu_result = in_a^in_b;
                carry_out = 1'b0;
            end
            c_shr:
            begin
                //outputs
                alu_result = in_a >> 1;
                carry_out = 1'b0;
            end
            c_shl:
            begin                  
                //outputs
                alu_result = in_a << 1;
                carry_out = in_a[7];
            end
            c_onescomp:
            begin
                //outputs
                alu_result = in_a^8'hff;
                carry_out = 1'b0;
            end
            c_twoscomp:
            begin
                //inputs
                temp_onescomp = in_a^8'hff;
                //inc inputs
                {carry_out,alu_result} = temp_onescomp + 1;
            end
        endcase
        if(alu_result == '0)
            zero_bit = 1;
        //ADDED THIS LINE FOR SIM
        //else if(^alu_result === 1'bx)
        //    zero_bit = alu_result;
        else
            zero_bit = 0;
    end
endmodule
