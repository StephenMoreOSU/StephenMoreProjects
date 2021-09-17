`timescale 1ns/1ps


module glitchless_tb();
    parameter fullcycle = 0.5;
    //inputs
    logic go, ws, clk, reset_n;
    //outputs
    logic rd, ds;

    glitchless dut(
        .go         (go),
        .ws         (ws),
        .clk        (clk),
        .reset_n    (reset_n),
        .rd         (rd),
        .ds         (ds)
    );

    //reset_n logic
    initial
    begin
        reset_n = 1'b0;
        #(fullcycle*1.1) reset_n = 1'b1;
    end
    
    //go, ws logic
    initial 
    begin
        go = 1'b0;
        ws = 1'b0;
        //wait for 2 cycles then offset by small portion of cycle
        #(fullcycle*(2 + 0.1)) go = 1'b1;
        #(fullcycle) {ws,go} = 2'b10;
    end

    //clk logic
    initial
    begin
        clk = 1'b1;
        forever #(fullcycle/2) clk = 1'b1^clk;
    end


endmodule