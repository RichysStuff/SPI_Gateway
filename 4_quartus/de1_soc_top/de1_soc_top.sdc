#**************************************************************
# Create Clock
#**************************************************************
create_clock -period 20 -name clk [get_ports {clk_50}]



#**************************************************************
# Set Input Delay
#**************************************************************
set_false_path -from key[*]
set_false_path -from sw[*]


#**************************************************************
# Set Output Delay
#**************************************************************
set_false_path -to hex*[*]
set_false_path -to ledr[*]
