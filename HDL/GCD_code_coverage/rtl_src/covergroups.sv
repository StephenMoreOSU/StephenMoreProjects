covergroup cg_out @(posedge tb.clk);
    cp_sr: coverpoint tb.gcd_0.gcd_ctrl_0.swap_registers;
    cp_done: coverpoint tb.gcd_0.gcd_ctrl_0.done_flag;
    cp_both: cross cp_sr, cp_done;
endgroup

covergroup cg_ain @(posedge tb.clk);
    cp_result: coverpoint tb.gcd_0.a_in {
        bins tiny = {[0:5]};
        bins big = {2100000};
    }
endgroup

covergroup cg_fsmtrans @(posedge tb.clk);
    cp_b: coverpoint tb.gcd_0.gcd_ctrl_0.ps {
        bins rr = (2'h1 => 2'h2);
        illegal_bins bad_trans = (2'h3 => 2'h1);
    }
endgroup
