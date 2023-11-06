module glitchless( output rd, ds,
        input go, ws, clk, reset_n);

//state encoding outputs | present state
// ds rd | ps[1] ps[0]
    enum reg [3:0]{
        IDLE = 4'b00_00,
        READ = 4'b01_01,
        DLY = 4'b01_10,
        DONE = 4'b10_11
    } no_glitch_ns, no_glitch_ps;

    always_ff @(posedge clk, negedge reset_n)
        if (!reset_n)    no_glitch_ps <= IDLE;
        else             no_glitch_ps <= no_glitch_ns;
    always_comb begin
        unique case (no_glitch_ps)
            IDLE :  if (go)     no_glitch_ns = READ;
                    else        no_glitch_ns = IDLE;
            READ :              no_glitch_ns = DLY;
            DLY :   if (!ws)    no_glitch_ns = DONE;
                    else        no_glitch_ns = READ;
            DONE :              no_glitch_ns = IDLE;
        endcase
    end
    assign {ds,rd} = no_glitch_ps[3:2];
endmodule