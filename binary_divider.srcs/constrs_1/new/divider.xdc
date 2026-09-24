# Define a 1 GHz clock on your main clock pin
create_clock -name sys_clk -period 1.000 [get_ports clk]