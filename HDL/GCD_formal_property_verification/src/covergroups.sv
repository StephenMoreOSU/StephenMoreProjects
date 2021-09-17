
covergroup cg_fsm @(posedge tb.clk);
  cp_ps: coverpoint tb.gcd_0.gcd_ctrl_0.ps;
  cp_ns: coverpoint tb.gcd_0.gcd_ctrl_0.ns;
endgroup


covergroup cg_result @(posedge tb.clk);
  cp_result: coverpoint tb.result {
    bins tiny        = {[0:500]};
    bins artisanal   = {[1000:2000], [4000:6000]};
    bins jumbo       = { 7000, 8000, 8001};
  }
endgroup

covergroup cg_fsmtrans @(posedge tb.clk);
  cp_b : coverpoint tb.gcd_0.gcd_ctrl_0.ps {
	illegal_bins bad_trans = (2'h3 => 2'h1);
  }
endgroup  
