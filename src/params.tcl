#set script_dir [file dirname [file normalize [info script]]]

set ::env(CLOCK_PERIOD) "20"
set ::env(CLOCK_PORT) "wb_clk_i"
set ::env(DESIGN_IS_CORE) "0"
set ::env(FP_PDN_CORE_RING) "0"
set ::env(GLB_RT_MAXLAYER) "5"
set ::env(DIODE_INSERTION_STRATEGY) "2"

set ::env(VDD_NETS) [list {vccd1}]
set ::env(GND_NETS) [list {vssd1}]
#set ::env(VDD_NETS) [list {vccd1} {vccd2} {vdda1} {vdda2}]
#set ::env(GND_NETS) [list {vssd1} {vssd2} {vssa1} {vssa2}]

#set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg