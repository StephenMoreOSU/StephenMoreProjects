module gcd  #(parameter WIDTH = 32)
            (input [WIDTH-1:0] a_in,         //operand a
            input [WIDTH-1:0] b_in,         //operand b
            input start,                    //validates input data
            input reset_n,                  //reset
            input clk,                      //clock
            output reg [WIDTH-1:0] result,  //output of GCD engine
            output reg done                 //validates output value
            );

    //present/next state enums
    enum logic [1:0]{
        IDLE = 2'b00,
        RUNNING = 2'b01,
        DONE = 2'b10
    } present_state, next_state;

    //declare gcd variables
    logic [WIDTH-1:0] remainder;
    logic [WIDTH-1:0] currentA,currentB,nextA,nextB;
    logic gcd_done;

    //assign outputs to comb logic elements
    assign result = currentA;
    assign done = gcd_done;

    always_ff @(posedge clk, negedge reset_n)
    begin
        //create synchronous active low reset
        if (!reset_n)    
            present_state <= IDLE; // if reset is low bring state to IDLE
        else
        begin             
            //load next values into present values
            present_state <= next_state;
            currentA <= nextA;
            currentB <= nextB;
        end
    end

    always_comb 
    begin
        unique case (present_state)
            IDLE :
            begin
                //every idle cycle update nextA and nextB with current a_in, b_in input values
                nextA = a_in;
                nextB = b_in;
                //if start is high go to RUNNING state next cycle
                if (start)
                begin
                    next_state = RUNNING;
                end
                else
                    //if start is low keep looping in IDLE
                    next_state = IDLE;
            end
            RUNNING :   
            begin 
                //get remainder from current A and B
                remainder = currentA % currentB;
                //load currentB value into nextA, remainder from calculation into nextB
                //this allows for recursive nature of algorithm in hardware
                nextA = currentB;
                nextB = remainder;
                //if remainder from operation is 0 on all bits (ie when the remainder is non zero), keep looping in RUNNING
                if (remainder != '0)    
                    next_state = RUNNING;
                else
                    //if remainder = 0 (gcd is found), set next state to DONE        
                    next_state = DONE;
            end
            DONE :              
            begin
                //unconditionally go to IDLE state
                next_state = IDLE;
            end
            //catch all other unexpected cases and bring to IDLE
            default:  next_state = IDLE;  
        endcase
    end
    //if the present state is in DONE state set done to high
    //this combinational logic is done outside of the case statement to prevent synthesizing a latch
    always_comb
    begin
        if(present_state == DONE)
            gcd_done = 1;
        else
            gcd_done = 0;
    end
endmodule