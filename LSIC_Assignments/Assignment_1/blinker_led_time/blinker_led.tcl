# TCL for 1-Second LED Blinker

# Create project
project_new blinker -overwrite

# Device
set_global_assignment -name FAMILY "MAX 10"
set_global_assignment -name DEVICE 10M50DAF484C7G

# Source file
set_global_assignment -name VERILOG_FILE blinker_led.v

# Top entity
set_global_assignment -name TOP_LEVEL_ENTITY blinker_led

# Pin assignments for DE10-Lite
set_location_assignment PIN_P11 -to clk
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to clk

set_location_assignment PIN_B8 -to rst_n
set_instance_assignment -name IO_STANDARD "3.3-V SCHMITT TRIGGER" -to rst_n

set_location_assignment PIN_A8 -to led
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to led

# Compile
load_package flow
execute_flow -compile

project_close