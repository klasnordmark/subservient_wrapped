set script_dir [file dirname [file normalize [info script]]]

set ::env(CLOCK_PERIOD) "25"
set ::env(CLOCK_PORT) "wb_clk_i"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)
set ::env(DESIGN_IS_CORE) "0"
#set ::env(FP_PDN_CORE_RING) "0"
set ::env(GLB_RT_MAXLAYER) "5"
set ::env(DIODE_INSERTION_STRATEGY) "3"
#set ::env(GLB_RT_MAX_DIODE_INS_ITERS) "5"

#set ::env(FP_SIZING) absolute
#set ::env(DIE_AREA) "0 0 700 700"
set ::env(SYNTH_MAX_FANOUT) 10

set ::env(FP_CORE_UTIL) 30
set ::env(PL_TARGET_DENSITY) [ expr ($::env(FP_CORE_UTIL)+5) / 100.0 ]

set ::env(VDD_NETS) [list {vccd1}]
set ::env(GND_NETS) [list {vssd1}]

set ::env(RUN_CVC) 0

#set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg
