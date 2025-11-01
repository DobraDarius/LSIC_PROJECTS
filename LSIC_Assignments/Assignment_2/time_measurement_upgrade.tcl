# TCL for 1-Second LED Blinker

# Create project
project_new blinker -overwrite

# Device
set_global_assignment -name FAMILY "MAX 10"
set_global_assignment -name DEVICE 10M50DAF484C7G

# Source file
set_global_assignment -name VERILOG_FILE blinker_led_upgrade.v

# Top entity
set_global_assignment -name TOP_LEVEL_ENTITY blinker_led

# Pin assignments for DE10-Lite
set_location_assignment PIN_P11 -to clk
set_location_assignment PIN_B8 -to rst_n
set_location_assignment PIN_C10 -to start_stop
set_location_assignment PIN_C11 -to pause

#LEDs specific pins
set_location_assignment PIN_A8 -to led[0]
set_location_assignment PIN_A9 -to led[1]
set_location_assignment PIN_A10 -to led[2]
set_location_assignment PIN_B10 -to led[3]
set_location_assignment PIN_D13 -to led[4]
set_location_assignment PIN_C13 -to led[5]
set_location_assignment PIN_E14 -to led[6]
set_location_assignment PIN_D14 -to led[7]

# Compile
load_package flow
execute_flow -compile

project_close