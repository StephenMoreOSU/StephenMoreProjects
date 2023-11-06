# //  ModelSim SE-64 10.5 Feb 12 2016 Linux 3.10.0-1062.9.1.el7.x86_64
# //
# //  Copyright 1991-2016 Mentor Graphics Corporation
# //  All Rights Reserved.
# //
# //  ModelSim SE-64 and its associated documentation contain trade
# //  secrets and commercial or financial information that are the property of
# //  Mentor Graphics Corporation and are privileged, confidential,
# //  and exempt from disclosure under the Freedom of Information Act,
# //  5 U.S.C. Section 552. Furthermore, this information
# //  is prohibited from disclosure under the Trade Secrets Act,
# //  18 U.S.C. Section 1905.
# //
# vsim alu 
# Start time: 18:19:00 on Apr 16,2020
# ** Note: (vsim-3812) Design is being optimized...
# Loading sv_std.std
# Loading work.alu(fast)

add wave -position insertpoint  \
sim:/alu/in_a \
sim:/alu/in_b \
sim:/alu/opcode \
sim:/alu/alu_out \
sim:/alu/alu_zero \
sim:/alu/alu_carry
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