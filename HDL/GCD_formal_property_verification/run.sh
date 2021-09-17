#!/bin/sh
vlog src/tb.sv src/gcd*.sv -cover sbcef +cover=f +acc=f 
vsim tb -c -coverage -do cover.do
# vsim tb -c -coverage -fsmdebug -do "run -all; coverage report -file coverage.rpt"

