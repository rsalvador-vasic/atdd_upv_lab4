#-------------------------------------------------------------------------------
# Info and path setup
#-------------------------------------------------------------------------------

if {[file exists /proc/cpuinfo]} {
    sh grep "model name" /proc/cpuinfo
    sh grep "cpu MHz"    /proc/cpuinfo
}

puts "Hostname : [info hostname]"

set DESIGN  "MV_Demo"
set DATE [clock format [clock seconds] -format "%b%d-%T"] 
set OUTPUTS_PATH ./results
set REPORTS_PATH ./reports

#-------------------------------------------------------------------------------
# Attributes
#-------------------------------------------------------------------------------
set_db information_level 3
set_db remove_assigns true 
set_db ignore_preserve_in_tiecell_insertion true

set_db lp_power_unit mW
set_db lp_insert_clock_gating true
set_db lp_power_analysis_effort high
set_db leakage_power_effort medium

set_db hdl_array_naming_style %s_%d

#-------------------------------------------------------------------------------
# Library setup
#-------------------------------------------------------------------------------
set_db information_level 1

create_library_domain { ls_default_wc ls_4p5_wc ls_1p62_swc ls_1p08_wc_m40 }

# Domain A (incl. IO and RAM)
set_db [get_db library_domains ls_default_wc] .library { \
        ../pdk/xt018/diglibs/D_CELLS_HD/v4_2/liberty_LP5MOS/v4_2_0/PVT_1_80V_range/D_CELLS_HD_LP5MOS_slow_1_62V_125C.lib \
        ../pdk/xt018/diglibs/D_CELLS_HDMV/v2_1/liberty_LP5MOS/v2_1_0/PVT_1_80V_1_80V_range/D_CELLS_HDMV_LP5MOS_slow_1_62V_1_62V_125C.lib \
        ../pdk/xt018/diglibs/D_CELLS_HDMV/v2_1/liberty_LP5MOS/v2_1_0/PVT_LS5VD_1_80V_5_00V_range/D_CELLS_HDMV_LS5VD_LP5MOS_slow_1_62V_4_50V_125C.lib \
        ../pdk/xt018/diglibs/D_CELLS_HDMV/v2_1/liberty_LP5MOS/v2_1_0/PVT_LSU5V_1_80V_5_00V_range/D_CELLS_HDMV_LSU5V_LP5MOS_slow_1_62V_4_50V_125C.lib \
        ../pdk/xt018/diglibs/D_CELLS_HDMV/v2_1/liberty_LP5MOS/v2_1_0/PVT_LSU_1_80V_1_20V_range/D_CELLS_HDMV_LSU_LP5MOS_slow_1_62V_1_08V_125C.lib \
        ../pdk/xt018/diglibs/IO_CELLS_F5V/v2_3/liberty_UPF_LP5MOS/v2_3_0/PVT_1_80V_5_00V_range/IO_CELLS_F5V_LP5MOS_UPF_slow_1_62V_4_50V_125C.lib \
        ../pdk/xt018/spram/XSPRAMLP_96X16_M8TA/v4_0_2/liberty_UPF_LP5MOS/XSPRAMLP_96X16_M8TA_UPF_slow_1_62V_125C.lib }

# Domain B
set_db [get_db library_domains ls_4p5_wc] .library { \
        ../liberty/D_CELLS_5V_LP5MOS_MOS5_slow_4_50V_125C.lib.gz } 

# Domain C
set_db [get_db library_domains ls_1p62_swc] .library { \
        ../pdk/xt018/diglibs/D_CELLS_HD/v4_2/liberty_LP5MOS/v4_2_0/PVT_1_80V_range/D_CELLS_HD_LP5MOS_slow_1_62V_125C.lib \
        ../pdk/xt018/diglibs/D_CELLS_HDMV/v2_1/liberty_LP5MOS/v2_1_0/PVT_1_80V_1_80V_range/D_CELLS_HDMV_LP5MOS_slow_1_62V_1_62V_125C.lib \
        ../pdk/xt018/diglibs/D_CELLS_HDMV/v2_1/liberty_LP5MOS/v2_1_0/PVT_LS5VD_1_80V_5_00V_range/D_CELLS_HDMV_LS5VD_LP5MOS_slow_1_62V_4_50V_125C.lib \
        ../pdk/xt018/diglibs/D_CELLS_HDMV/v2_1/liberty_LP5MOS/v2_1_0/PVT_LSUTS_1_80V_1_20V_range/D_CELLS_HDMV_LSUTS_LP5MOS_slow_1_62V_1_08V_125C.lib }

# Domain D
set_db [get_db library_domains ls_1p08_wc_m40] .library { \
        ../pdk/xt018/diglibs/D_CELLS_HDLL/v1_2/liberty_LP5MOS/v1_2_1/PVT_1_20V_range/D_CELLS_HDLL_LP5MOS_slow_1_08V_m40C.lib \
        ../pdk/xt018/diglibs/D_CELLS_HDMV/v2_1/liberty_LP5MOS/v2_1_0/PVT_LSD_1_20V_1_80V_range/D_CELLS_HDMV_LSD_LP5MOS_slow_1_08V_1_62V_m40C.lib \
        ../pdk/xt018/diglibs/D_CELLS_HDMV/v2_1/liberty_LP5MOS/v2_1_0/PVT_LS5VD_1_20V_5_00V_range/D_CELLS_HDMV_LS5VD_LP5MOS_slow_1_08V_4_50V_m40C.lib }

set_db information_level 3

set_db lef_library { ../pdk/xt018/cadence/v9_0/techLEF/v9_0_1/xt018_xx31_HD_MET3_METMID.lef \
                     ../pdk/xt018/diglibs/D_CELLS_HD/v4_2/LEF/v4_2_0/xt018_D_CELLS_HD.lef \
                     ../pdk/xt018/diglibs/D_CELLS_5V/v5_1/LEF/v5_1_0/xt018_D_CELLS_5V.lef \
                     ../pdk/xt018/diglibs/D_CELLS_HDLL/v1_2/LEF/v1_2_1/xt018_D_CELLS_HDLL.lef \
                     ../pdk/xt018/diglibs/D_CELLS_HDMV/v2_1/LEF/v2_1_0/xt018_D_CELLS_HDMV.lef \
                     ../pdk/xt018/diglibs/IO_CELLS_F5V/v2_3/LEF/v2_3_1/xt018_1231_MET3_METMID_IO_CELLS_F5V.lef \
                     ../pdk/xt018/spram/XSPRAMLP_96X16_M8TA/v4_0_2/xt018_1231_LP5MOS_MET3_METMID/LEF/XSPRAMLP_96X16_M8TA.lef }

set_db cap_table_file { ../pdk/xt018/cadence/v9_0/capTbl/v9_0_1/xt018_xx31_MET3_METMID_typ.capTbl }

set_db [get_db lib_cells *LGC* *LSGC* *LSOGC*] .avoid false

#------------------------------------------------------------------------------- 
# Read design
#-------------------------------------------------------------------------------
read_hdl -sv {  \
    ../src/add.v \
    ../src/mult.v \
    ../src/signature.v \
    ../src/pipeline.v \
    ../local/MV_Demo_core.v \
    ../local/icg_box.sv \
    ../src/MV_Demo.v }

elaborate ${DESIGN}

check_design -all



#------------------------------------------------------------------------------- 
# Set Joules Power Analysis
#-------------------------------------------------------------------------------
#set_db lp_enable_jls_sdb_flow 1
set_db power_engine joules

read_stimulus -file ../xcelium/waves.shm \
             -start 0.0 \
             -end   70000.0

propagate_activity 


#------------------------------------------------------------------------------- 
# Power intent
#-------------------------------------------------------------------------------
read_power_intent -1801 ../src/MV_Demo.upf -module ${DESIGN}
apply_power_intent -design ${DESIGN} -module MV_Demo -summary


#Joules power analysis
set_db power_engine joules

##verify_power_structure -all -license lpgxl -lp_only -detail -pre_synthesis > \
##                        $REPORTS_PATH/${DESIGN}_verify_power_structure_presyn.rpt

set_db [get_db power_domains D_A] .library_domain ls_default_wc
set_db [get_db power_domains D_B] .library_domain ls_4p5_wc
set_db [get_db power_domains D_C] .library_domain ls_1p62_swc
set_db [get_db power_domains D_D] .library_domain ls_1p08_wc_m40

#-------------------------------------------------------------------------------
# Mode and constraints
#-------------------------------------------------------------------------------
create_mode -name pm1 -default -design ${DESIGN}

read_sdc ../src/MV_Demo.sdc -mode pm1

check_timing_intent

#-------------------------------------------------------------------------------
# Define cost groups (clock-clock, clock-output, input-clock, input-output)
#-------------------------------------------------------------------------------
if {[llength [all::all_seqs]] > 0} { 
    define_cost_group -name I2C -design $DESIGN
    define_cost_group -name C2O -design $DESIGN
    define_cost_group -name C2C -design $DESIGN
    path_group -from [all_registers] -to [all_registers] -group C2C -name C2C -mode pm1
    path_group -from [all_registers] -to [all_outputs] -group C2O -name C2O -mode pm1
    path_group -from [all_inputs] -to [all_registers] -group I2C -name I2C -mode pm1
}

define_cost_group -name I2O -design $DESIGN
path_group -from [all_inputs]  -to [all_outputs] -group I2O -name I2O -mode pm1

foreach cg [get_db cost_groups *] {
    report_timing -mode pm1 -cost_group [list $cg] >> $REPORTS_PATH/${DESIGN}_timing_presyn.rpt
}

#-------------------------------------------------------------------------------
# DFT
#-------------------------------------------------------------------------------
set_db dft_scan_style muxed_scan
set_db dft_prefix DFT_
set_db dft_identify_test_signals true
set_db dft_identify_internal_test_clocks false
set_db use_scan_seqs_for_non_dft true
set_db design:$DESIGN .dft_lockup_element_type preferred_edge_sensitive
set_db design:$DESIGN .dft_mix_clock_edges_in_scan_chains true
set_db design:$DESIGN .lp_clock_gating_control_point precontrol
set_db design:$DESIGN .lp_clock_gating_min_flops 4

define_dft test_clock   -name clk core/clk
define_dft shift_enable -name scan_enable -active high core/scan_enable
define_dft test_mode    -name test_mode   -scan_shift -active high core/test_mode
define_dft scan_chain   -name scan_f      -sdi core/scan_in -sdo core/scan_out

set_db design:$DESIGN .lp_power_optimization_weight 0.5
set_db design:$DESIGN .max_leakage_power 0.0
set_db design:$DESIGN .max_dynamic_power 500
set_db design:$DESIGN .lp_clock_gating_test_signal test_mode

#-------------------------------------------------------------------------------
# Synthesize to generic
#-------------------------------------------------------------------------------
commit_power_intent
syn_gen

report_dp                   > $REPORTS_PATH/${DESIGN}_datapath_generic.rpt
check_dft_rules             > $REPORTS_PATH/${DESIGN}_dft_rules.rpt
report_scan_registers       > $REPORTS_PATH/${DESIGN}_scan_register.rpt
report_clock_gating -detail > $REPORTS_PATH/${DESIGN}_clock_gating_bf_map.rpt

set numDFTviolations [check_dft_rules]
if {$numDFTviolations > "0"} {
    report_dft_violations > $REPORTS_PATH/${DESIGN}_dft_violations_before_fixing_intermed.rpt
    fix_dft_violations -async_reset -async_set -clock -test_control test_mode
    check_dft_rules       > $REPORTS_PATH/${DESIGN}_dft_rules_after_fixing_intermed.rpt
}

#-------------------------------------------------------------------------------
# Synthesize to gates
#-------------------------------------------------------------------------------
syn_map

connect_scan_chains -chains scan_f \
    -elements { hinst:MV_Demo/core \
                hinst:MV_Demo/core/Domain_B \
                hinst:MV_Demo/core/Domain_C \
                hinst:MV_Demo/core/Domain_D }

commit_power_intent
##verify_power_structure -all -license lpgxl -lp_only -detail -post_synthesis > \
##                        ${REPORTS_PATH}/${DESIGN}_verify_power_structure_postsyn.rpt
                    
report_scan_chains          > $REPORTS_PATH/${DESIGN}_dft_chain.rpt
report_clock_gating -detail > $REPORTS_PATH/${DESIGN}_clock_gating.rpt

set_db ui_respects_preserve false
set_db use_tiehilo_for_const unique

delete_unloaded_undriven -all -force_bit_blast $DESIGN

set all_regs [all_registers]
path_adjust -from $all_regs -to $all_regs -delay -5000 -name PA_C2C -mode pm1

syn_opt

delete_obj [get_db exceptions -if {.name == *PA*}]

# Joules compute power
compute_power -by_rail

#-------------------------------------------------------------------------------
# Reporting and export
#-------------------------------------------------------------------------------
report power_intent_instances -detail  > $REPORTS_PATH/${DESIGN}_low_power_cells.rpt
report_gates -power                    > $REPORTS_PATH/${DESIGN}_gates_power.rpt
report_area                            > $REPORTS_PATH/${DESIGN}_area.rpt
report_qor                             > $REPORTS_PATH/${DESIGN}_qor.rpt
report_power -header -unit mW -format %.3f -by_hierarchy > $REPORTS_PATH/${DESIGN}_report_power_hier.rpt
report_power -header -unit mW -format %.3f -by_hierarchy -by_rail> $REPORTS_PATH/${DESIGN}_report_power_hier_rail.rpt
report_power -header -unit mW -format %.3f -by_category > $REPORTS_PATH/${DESIGN}_report_power_by_category.rpt
foreach cg [get_db cost_groups *] {
    report_timing -mode pm1 -cost_group [list $cg] >> $REPORTS_PATH/${DESIGN}_timing_final.rpt
}

check_dft_rules             > $REPORTS_PATH/${DESIGN}_dft_rules_after_synth.rpt
write_design -basename $OUTPUTS_PATH/${DESIGN}
    
write_sdc -mode pm1 -exclude "set_ideal_network set_dont_use group_path \
                              set_max_dynamic_power set_max_leakage_power \
                              set_units set_operating_conditions" > $OUTPUTS_PATH/${DESIGN}.pm1.sdc
                              
write_scandef > $OUTPUTS_PATH/${DESIGN}.scan.def
write_sdf -timescale ns -edges check_edge -delimiter "/" \
          -setuphold merge_when_paired \
          -recrem merge_when_paired > $OUTPUTS_PATH/${DESIGN}.sdf
          
report_messages -all -warning -error

exit
