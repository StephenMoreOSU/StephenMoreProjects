#!/bin/bash
vlog rtl_src/*.sv
vlog rtl_src/gcd*.sv -cover sbcef +cover=f +acc=f
vsim tb -novopt -c -coverage -do cover.do
