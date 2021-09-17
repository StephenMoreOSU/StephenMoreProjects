# alu_test.do

#add wave -position insertpoint  \
#sim:/alu/in_a \
#sim:/alu/in_b \
#sim:/alu/opcode \
#sim:/alu/alu_out \
#sim:/alu/alu_zero \
#sim:/alu/alu_carry
# C_ADD
force -freeze sim:/alu/opcode 4'h1 0
force -freeze sim:/alu/in_a 8'h0f 0
force -freeze sim:/alu/in_b 8'hf0 0
run 100
force -freeze sim:/alu/in_a 8'h00 0
force -freeze sim:/alu/in_b 8'h00 0
run 100
force -freeze sim:/alu/in_a 8'hff 0
force -freeze sim:/alu/in_b 8'h01 0
run 100
force -freeze sim:/alu/in_b 8'hff 0
run 100
force -freeze sim:/alu/in_a 8'hxx 0
force -freeze sim:/alu/in_b 8'hff 0
run 100
force -freeze sim:/alu/in_a 8'hzz 0
force -freeze sim:/alu/in_b 8'hff 0
run 100
# C_SUB
force -freeze sim:/alu/opcode 8'h2 0
run 100
force -freeze sim:/alu/in_a 8'hff 0
force -freeze sim:/alu/in_b 8'h0f 0
run 100
force -freeze sim:/alu/in_a 8'h00 0
force -freeze sim:/alu/in_b 8'h00 0
run 100
force -freeze sim:/alu/in_a 8'hff 0
force -freeze sim:/alu/in_b 8'h01 0
run 100
force -freeze sim:/alu/in_a 8'h0f 0
force -freeze sim:/alu/in_b 8'hff 0
run 100
force -freeze sim:/alu/in_a 8'hxx 0
force -freeze sim:/alu/in_b 8'hff 0
run 100
force -freeze sim:/alu/in_a 8'hzz 0
force -freeze sim:/alu/in_b 8'hff 0
run 100
# C_INC
force -freeze sim:/alu/opcode 8'h3 0
force -freeze sim:/alu/in_a 8'h00 0
run 100
force -freeze sim:/alu/in_a 8'hff 0
run 100
force -freeze sim:/alu/in_a 8'h0f 0
run 100
force -freeze sim:/alu/in_a 8'hxx 0
run 100
force -freeze sim:/alu/in_a 8'hzz 0
run 100
# C_DEC
force -freeze sim:/alu/opcode 8'h4 0
force -freeze sim:/alu/in_a 8'hff 0
run 100
force -freeze sim:/alu/in_a 8'h00 0
run 100
force -freeze sim:/alu/in_a 8'h0f 0
run 100
force -freeze sim:/alu/in_a 8'hxx 0
run 100
force -freeze sim:/alu/in_a 8'hzz 0
run 100
# C_OR
force -freeze sim:/alu/opcode 8'h5 0
force -freeze sim:/alu/in_a 8'h0f 0
force -freeze sim:/alu/in_b 8'hf0 0
run 100
force -freeze sim:/alu/in_a 8'h00 0
force -freeze sim:/alu/in_b 8'h00 0
run 100
force -freeze sim:/alu/in_a 8'hff 0
force -freeze sim:/alu/in_b 8'h01 0
run 100
force -freeze sim:/alu/in_b 8'hff 0
run 100
force -freeze sim:/alu/in_a 8'hxx 0
force -freeze sim:/alu/in_b 8'hff 0
run 100
force -freeze sim:/alu/in_a 8'hzz 0
force -freeze sim:/alu/in_b 8'hff 0
run 100
# C_AND
force -freeze sim:/alu/opcode 8'h6 0
force -freeze sim:/alu/in_a 8'h0f 0
force -freeze sim:/alu/in_b 8'hf0 0
run 100
force -freeze sim:/alu/in_a 8'h00 0
force -freeze sim:/alu/in_b 8'h00 0
run 100
force -freeze sim:/alu/in_a 8'hff 0
force -freeze sim:/alu/in_b 8'h01 0
run 100
force -freeze sim:/alu/in_b 8'hff 0
run 100
force -freeze sim:/alu/in_a 8'hxx 0
force -freeze sim:/alu/in_b 8'hff 0
run 100
force -freeze sim:/alu/in_a 8'hzz 0
force -freeze sim:/alu/in_b 8'hff 0
run 100
# C_XOR
force -freeze sim:/alu/opcode 8'h7 0
force -freeze sim:/alu/in_a 8'h0f 0
force -freeze sim:/alu/in_b 8'hf0 0
run 100
force -freeze sim:/alu/in_a 8'h00 0
force -freeze sim:/alu/in_b 8'h00 0
run 100
force -freeze sim:/alu/in_a 8'hff 0
force -freeze sim:/alu/in_b 8'h01 0
run 100
force -freeze sim:/alu/in_b 8'hff 0
run 100
force -freeze sim:/alu/in_a 8'hxx 0
force -freeze sim:/alu/in_b 8'hff 0
run 100
force -freeze sim:/alu/in_a 8'hzz 0
force -freeze sim:/alu/in_b 8'hff 0
run 100
# C_SHR
force -freeze sim:/alu/opcode 8'h8 0
force -freeze sim:/alu/in_a 8'hff 0
run 100
force -freeze sim:/alu/in_a 8'h00 0
run 100
force -freeze sim:/alu/in_a 8'h0f 0
run 100
force -freeze sim:/alu/in_a 8'hxx 0
run 100
force -freeze sim:/alu/in_a 8'hzz 0
run 100
# C_SHL
force -freeze sim:/alu/opcode 8'h9 0
force -freeze sim:/alu/in_a 8'hff 0
run 100
force -freeze sim:/alu/in_a 8'h00 0
run 100
force -freeze sim:/alu/in_a 8'h0f 0
run 100
force -freeze sim:/alu/in_a 8'hxx 0
run 100
force -freeze sim:/alu/in_a 8'hzz 0
run 100
# C_ONESCOMP
force -freeze sim:/alu/opcode 8'ha 0
force -freeze sim:/alu/in_a 8'hff 0
run 100
force -freeze sim:/alu/in_a 8'h00 0
run 100
force -freeze sim:/alu/in_a 8'h0f 0
run 100
force -freeze sim:/alu/in_a 8'hxx 0
run 100
force -freeze sim:/alu/in_a 8'hzz 0
run 100
# C_TWOSCOMP
force -freeze sim:/alu/opcode 8'hb 0
force -freeze sim:/alu/in_a 8'hff 0
run 100
force -freeze sim:/alu/in_a 8'h00 0
run 100
force -freeze sim:/alu/in_a 8'h0f 0
run 100
force -freeze sim:/alu/in_a 8'hxx 0
run 100
force -freeze sim:/alu/in_a 8'hzz 0
run 100