#50 MHz board input clock
create_clock -period 20 [get_ports clk_clk]

#for enhancing USB BlasterII to be reliable at 25MHz
create_clock -name {altera_reserved_tck} -period 40 {altera_reserved_tck}
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdi]
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tms]
set_output_delay -clock altera_reserved_tck 3 [get_ports altera_reserved_tdo]

# FPGA IO port constraints
set_false_path -from * -to [get_ports {led_export[*]}]

# create unused clock constraints 
create_clock -period "1 MHz" {get_ports hps_io_hps_io_i2c0_inst_SCL}
create_clock -period "48 MHz" {get_ports hps_io_hps_io_usb1_inst_CLK}
