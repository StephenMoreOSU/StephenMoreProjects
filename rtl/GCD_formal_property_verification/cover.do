coverage exclude -srcfile tb.sv
run -all
coverage report -details -file func-pre-coverage.rpt
coverage report -file s.rpt

exit
