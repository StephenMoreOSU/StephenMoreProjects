#!/bin/bash
vlog rtl_src/tb.sv
vlog rtl_src/gcd*.sv -cover sbcef +cover=f +acc=f
vsim tb -c -coverage -fsmdebug -do cover.do
