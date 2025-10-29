# TCL for Millisecond Counter with 7-Segment Display

# Create project
project_new ms_counter_7seg -overwrite

# Device
set_global_assignment -name FAMILY "MAX 10"
set_global_assignment -name DEVICE 10M50DAF484C7G

# Source file
set_global_assignment -name VERILOG_FILE ms_counter_7seg.v

# Top entity
set_global_assignment -name TOP_LEVEL_ENTITY ms_counter_7seg

# ====================
# PIN ASSIGNMENTS
# ====================

# Clock
set_location_assignment PIN_P11 -to clk
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to clk

# Reset button
set_location_assignment PIN_B8 -to rst_n
set_instance_assignment -name IO_STANDARD "3.3-V SCHMITT TRIGGER" -to rst_n

# ====================
# 7-SEGMENT DISPLAYS (using HEX3-HEX0)
# ====================

# HEX0 (rightmost) - Ones digit
set_location_assignment PIN_C14 -to HEX0[0]
set_location_assignment PIN_E15 -to HEX0[1]
set_location_assignment PIN_C15 -to HEX0[2]
set_location_assignment PIN_C16 -to HEX0[3]
set_location_assignment PIN_E16 -to HEX0[4]
set_location_assignment PIN_D17 -to HEX0[5]
set_location_assignment PIN_C17 -to HEX0[6]

# HEX1 - Tens digit
set_location_assignment PIN_C18 -to HEX1[0]
set_location_assignment PIN_D18 -to HEX1[1]
set_location_assignment PIN_E18 -to HEX1[2]
set_location_assignment PIN_B16 -to HEX1[3]
set_location_assignment PIN_A17 -to HEX1[4]
set_location_assignment PIN_A18 -to HEX1[5]
set_location_assignment PIN_B17 -to HEX1[6]

# HEX2 - Hundreds digit
set_location_assignment PIN_B20 -to HEX2[0]
set_location_assignment PIN_A20 -to HEX2[1]
set_location_assignment PIN_B19 -to HEX2[2]
set_location_assignment PIN_A21 -to HEX2[3]
set_location_assignment PIN_B21 -to HEX2[4]
set_location_assignment PIN_C22 -to HEX2[5]
set_location_assignment PIN_B22 -to HEX2[6]

# HEX3 (leftmost) - Thousands digit
set_location_assignment PIN_F21 -to HEX3[0]
set_location_assignment PIN_E22 -to HEX3[1]
set_location_assignment PIN_E21 -to HEX3[2]
set_location_assignment PIN_C19 -to HEX3[3]
set_location_assignment PIN_C20 -to HEX3[4]
set_location_assignment PIN_D19 -to HEX3[5]
set_location_assignment PIN_E17 -to HEX3[6]

# I/O Standards for 7-segment
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to "HEX0[*]"
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to "HEX1[*]"
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to "HEX2[*]"
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to "HEX3[*]"

# ====================
# LEDS
# ====================
set_location_assignment PIN_A8 -to "LEDR[0]"
set_location_assignment PIN_A9 -to "LEDR[1]"
set_location_assignment PIN_A10 -to "LEDR[2]"
set_location_assignment PIN_B10 -to "LEDR[3]"
set_location_assignment PIN_D13 -to "LEDR[4]"
set_location_assignment PIN_C13 -to "LEDR[5]"
set_location_assignment PIN_E14 -to "LEDR[6]"
set_location_assignment PIN_D14 -to "LEDR[7]"
set_location_assignment PIN_A11 -to "LEDR[8]"
set_location_assignment PIN_B11 -to "LEDR[9]"
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to "LEDR[*]"

# ====================
# COMPILATION
# ====================
load_package flow
execute_flow -compile

project_close