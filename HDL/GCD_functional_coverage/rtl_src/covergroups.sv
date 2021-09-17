//starting HMK7 covergroups
/*

The reason why I have to comment out the cross group in my cg_fsm_ctrl covergroup to get 100% coverage
is because crossing coverpoints means that every combination of those coverpoints has been covered.
The transitions from:

SUBT to DONE
SWAP to DONE

will never occur in normal operation unless a reset_n signal is asserted while
the present state is SUBT or SWAP.

In addition to these two cases there is also the case in which the present and next states
are not both the same state at the same time. It makes sense as to why this would
be an aspect which is by the nature of the design impossible to get 100% code coverage.


*/
/****************CG 1*********************/
covergroup cg_fsm_ctrl @(posedge tb.clk);
    //covering present state, next state, cross
    cp_ps: coverpoint tb.gcd_0.gcd_ctrl_0.ps;
    cp_ns: coverpoint tb.gcd_0.gcd_ctrl_0.ns;
    cp_pns: cross cp_ps, cp_ns;
endgroup
/****************CG 2*********************/
covergroup cg_out @(posedge tb.clk);
    //handling result and done flag
    cp_result: coverpoint tb.gcd_0.result{
        bins bin1 = {[0:500]};
        bins bin2 = {[1000:2000]};
        bins bin3 = {[7000:8000]};
        bins bin4 = {5000};
    }
    cp_done: coverpoint tb.gcd_0.gcd_ctrl_0.done_flag;
endgroup
/****************CG 3*********************/
covergroup cg_fsmtrans @(posedge tb.clk);
    cp_trans: coverpoint tb.gcd_0.gcd_ctrl_0.ps {
        //declare transition from DONE to SUBT illegal
        illegal_bins bad_trans = (2'h3 => 2'h1);
    }
endgroup