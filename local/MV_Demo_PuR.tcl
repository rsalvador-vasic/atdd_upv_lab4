# ----------------------------------------------------------
# Custom variables
# ----------------------------------------------------------
set libName "MV_Demo"
set cellName "MV_Demo"
set refLibs [list D_CELLS_HD D_CELLS_5V D_CELLS_HDLL D_CELLS_HDMV IO_CELLS_F5V XSPRAMLP_96X16_M8TA]
set verilogFile "../genus/results/${cellName}.v"
set upfFile "../genus/results/${cellName}.upf"
set scanDef "../genus/results/${cellName}.scan.def"
set ioFile "../src/${cellName}.io"
set mmmcFile "../tcl/${cellName}_mmmc.tcl"
set powerNets [list VDD VDDOR vdd_A vdd_B vddsw_C vdd_D]
set groundNets [list GND]
set lefTechFileMap "../pdk/xt018/cadence/v9_0/QRC_pvs/v9_0_1/XT018_1231/QRC-Max/xx018_lef_qrc.map"
set streamOutMap "../src/xx018_streamout.map"

# ----------------------------------------------------------
# Definition of Innovus variables
# ----------------------------------------------------------
setOaxMode -compressLevel 0
setOaxMode -allowBitConnection true
setOaxMode -allowTechUpdate false
setOaxMode -updateMode true
#setGenerateViaMode -auto true
setOaxMode -pinPurpose true
setDesignMode -process 180
setViaGenMode -symmetrical_via_only true

# ----------------------------------------------------------
# Globals
# ----------------------------------------------------------
set_table_style -no_frame_fix_width
set_global timing_report_enable_auto_column_width true
setMultiCpuUsage -localCpu 4

# ----------------------------------------------------------
# Import and initialization of design
# ----------------------------------------------------------
set init_oa_design_lib      $libName
set init_top_cell           $cellName
set init_oa_ref_lib 	    $refLibs
set init_verilog            $verilogFile
set init_io_file            $ioFile
set init_mmmc_file          $mmmcFile
set init_pwr_net            $powerNets
set init_gnd_net            $groundNets
set init_abstract_view      abstract
set init_layout_view        layout
set init_remove_assigns     1
init_design

# ----------------------------------------------------------
# Save initialization
# ----------------------------------------------------------
saveDesign -cellview [list $libName $cellName layout_00_init]


# ----------------------------------------------------------
# Read and commit power intent
# ----------------------------------------------------------
read_power_intent -1801 $upfFile
commit_power_intent -keepRows -powerDomain -power_switch

verifyPowerDomain

# ----------------------------------------------------------
# Add physical shapes to new P/G pins
# ----------------------------------------------------------

createPGPin GND -dir input -net GND -geom {MET1 543.0 68.12 553.0 78.12}
createPGPin VDD -dir input -net VDD -geom {MET1 371.0 68.12 381.0 78.12}
createPGPin VDDOR -dir input -net VDDOR -geom {MET1 801.0 68.12 811.0 78.12}
createPGPin vdd_A -dir input -net vdd_A -geom {MET1 457.0 931.88 467.0 941.88}
createPGPin vdd_B -dir input -net vdd_B -geom {MET1 715.0 931.88 725.0 941.88}
createPGPin vdd_D -dir input -net vdd_D -geom {MET1 715.0 68.12 725.0 78.12}

# ----------------------------------------------------------
# Add labels to pins for later LVS
# ----------------------------------------------------------
foreach term [ dbGet top.terms ] {

    set name [ lindex [ dbGet $term.name ] 0 ]
    # substitute [] by <> for usage of labels in Virtuoso
    #set vName [ regsub -all {\]} [ regsub -all {\[} [ lindex $name 0 ] < ] > ]

    set layer  [ dbGet $term.layer.name ]
    set points [ dbGet $term.pt ]

    add_text -label $name -layer $layer -oaPurpose "TEXT" -pt $points

}

foreach term [ dbGet top.pgTerms ] {

    set name   [ dbGet $term.name ]
    # substitute [] by <> for usage of labels in Virtuoso
    #set vName [ regsub -all {\]} [ regsub -all {\[} [ lindex $name 0 ] < ] > ]

    set layer  [ dbGet $term.layer.name ]
    set points [ dbGet $term.pt ]

    add_text -label $name -layer $layer -oaPurpose "TEXT" -pt $points

}

# ----------------------------------------------------------
# Read IO file, define floorplan, add IO filler
# ----------------------------------------------------------
setFPlanMode -forcedDefaultTechSite core_hd

floorPlan -flip s \
          -b   0.00   0.00 1010.00 1010.00 \
             160.00 160.00  850.00  850.00 \
             334.88 206.08  797.44  797.44 \
          -noSnapToGrid

loadIoFile $ioFile

addIoFiller -cell FILLER100F FILLER84F FILLER50F FILLER40F FILLER20F FILLER10F FILLER05F FILLER03F FILLER02F \
            -prefix IOFILLER -logic -deriveConnectivity

# ----------------------------------------------------------
# Placement of IPs and power switch cells, power domains
# ----------------------------------------------------------
create_relative_floorplan -place core/RAM \
                          -ref_type core_boundary \
                          -orient MY90 \
                          -horizontal_edge_separate {1 18.53 1} \
                          -vertical_edge_separate {0 -52.825 2}

modifyPowerDomainAttr D_B -box 558.88 528.64 797.44 797.44 \
    -rsExts 50 34 44 50 -mingaps 50 34 44 50 -rowFlip second

modifyPowerDomainAttr D_C -box 334.88 206.08 583.20 492.80 \
    -rsExts 34 50 50 44 -mingaps 34 50 50 44 -rowFlip second

modifyPowerDomainAttr D_D -box 627.20 206.08 797.44 492.80 \
    -rsExts 34 50 44 50 -mingaps 34 50 44 50 -rowFlip second

addPowerSwitch -column -powerDomain D_C -enablePinIn E -horizontalPitch 252 \
    -enableNetOut shuton_out_BC -enableNetIn core/i_D_C_shuton -enablePinOut EO \
    -globalSwitchCellName SWIVBHD1OHD -connectBottomSwitchEnablePins LtoR \
    -switchModuleInstance  "core/Domain_C" -leftOffset 114 \
    -orientation R0 -snapToNearest -noDoubleHeightCheck

# ----------------------------------------------------------
# Save floorplan layout
# ----------------------------------------------------------
saveDesign -cellview [list $libName $cellName layout_01_fplan]


# ----------------------------------------------------------
# Special route
# ----------------------------------------------------------
source ../tcl/${cellName}_SRoute.tcl

sroute -connect { blockPin padPin corePin floatingStripe } -verbose \
    -layerChangeRange { MET1 METTP } -allowJogging 1 -allowLayerChange 1 \
    -crossoverViaLayerRange {MET1 METTP} -targetViaLayerRange { MET1 METTP } \
    -deleteExistingRoutes -padPinPortConnect { allPort allGeom } \
    -blockPinTarget stripe \
    -nets { GND }

sroute -connect { padPin corePin blockPin floatingStripe } -verbose \
    -layerChangeRange { MET1 METTP } -allowJogging 1 -allowLayerChange 1 \
    -crossoverViaLayerRange {MET1 METTP} -targetViaLayerRange { MET1 METTP } \
    -deleteExistingRoutes -padPinPortConnect { allPort allGeom } \
    -nets { vdd_A }

sroute -connect { padPin corePin floatingStripe } -verbose \
    -layerChangeRange { MET1 METTP } -allowJogging 1 -allowLayerChange 1 \
    -crossoverViaLayerRange {MET1 METTP} -targetViaLayerRange { MET1 METTP } \
    -deleteExistingRoutes -padPinPortConnect { allPort allGeom } \
    -nets { vdd_B }

sroute -connect { padPin corePin floatingStripe } -verbose \
    -layerChangeRange { MET1 METTP } -allowJogging 1 -allowLayerChange 1 \
    -crossoverViaLayerRange {MET1 METTP} -targetViaLayerRange { MET1 METTP } \
    -deleteExistingRoutes -padPinPortConnect { allPort allGeom } \
    -nets { vdd_D }

sroute -connect { corePin floatingStripe } -verbose \
    -layerChangeRange { MET1 METTP } -allowJogging 1 -allowLayerChange 1 \
    -crossoverViaLayerRange {MET1 METTP} -targetViaLayerRange { MET1 METTP } \
    -deleteExistingRoutes -nets { vddsw_C }

# ----------------------------------------------------------
# Save layout with special/power routes
# ----------------------------------------------------------
saveDesign -cellview [list $libName $cellName layout_02_sroute]


# ----------------------------------------------------------
# Expand path groups
# ----------------------------------------------------------
createBasicPathGroups -expanded

# ----------------------------------------------------------
# Check timing constraints and design
# Check timing in preplace mode
# ----------------------------------------------------------
check_timing -verbose
checkDesign -all

# ----------------------------------------------------------
# Import of scan chains
# ----------------------------------------------------------
defIn $scanDef

# ----------------------------------------------------------
# Mode settings
# ----------------------------------------------------------
setPlaceMode -place_global_place_io_pins false \
             -place_global_reorder_scan true

setNanoRouteMode -drouteUseMultiCutViaEffort high \
                 -routeInsertAntennaDiode true \
                 -routeAntennaCellName "ANTENNACELLN2HD ANTENNACELLN2_5V ANTENNACELLN2HDLL"

setOptMode  -fixDRC true \
            -fixFanoutLoad true \
            -timeDesignCompressReports false \
            -usefulSkew true \
            -enableDataToDataChecks true

# ----------------------------------------------------------
# Placement
# ----------------------------------------------------------
place_opt_design

setTieHiLoMode -cell {{LOGIC0HD LOGIC1HD} {LOGIC0HDLL LOGIC1HDLL} {LOGIC0_5V LOGIC1_5V}} \
               -prefix TIEHL_ -maxFanout 20 -maxDistance 200

addTieHiLo -cell "LOGIC0HD   LOGIC1HD"   -powerDomain D_A
addTieHiLo -cell "LOGIC0_5V  LOGIC1_5V"  -powerDomain D_B
addTieHiLo -cell "LOGIC0HD   LOGIC1HD"   -powerDomain D_C
addTieHiLo -cell "LOGIC0HDLL LOGIC1HDLL" -powerDomain D_D

checkPlace -ignoreOutOfCore ${cellName}.checkPlace

# ----------------------------------------------------------
# Save placed layout
# ----------------------------------------------------------
saveDesign -cellview [list $libName $cellName layout_03_place]


# ----------------------------------------------------------
# Clock tree synthesis
# ----------------------------------------------------------
timeDesign -preCTS
timeDesign -preCTS -hold

delete_ccopt_clock_tree_spec
create_ccopt_clock_tree_spec -file ccopt.spec

source ccopt.spec

set_ccopt_property allow_resize_of_dont_touch_cells false

ccopt_design -cts

optDesign -postCTS -setup -hold

# ----------------------------------------------------------
# Save layout with clocktree
# ----------------------------------------------------------
saveDesign -cellview [list $libName $cellName layout_04_cts]


# ----------------------------------------------------------
# Route design and optimization
# ----------------------------------------------------------
setAnalysisMode -analysisType onChipVariation -cppr both

setPathGroupOptions in2reg -slackAdjustment -0.2

setPGPinUseSignalRoute RTV*:vdde LSH*:vdde ELS*:vdde AWO*:vdde SWI*:vdde

verifyPowerDomain -gconn -place -place_rpt verifyPowerDomain.rpt

remove_assigns -buffering

add_ndr -name width_x3 -width {MET1:MET3 0.8 METTP 1.2} -hard_spacing

setNanoRouteMode -reset
setNanoRouteMode -drouteUseMultiCutViaEffort high \
                 -drouteUseMinSpacingForBlockage false \
                 -dbViaWeight { *_beo 4 *_eo 3 *_C* 5 *_C*_beo 9 *_C*_eo 7 }

routePGPinUseSignalRoute -nets { vdd_A vdd_B vddsw_C vdd_D } -maxFanout 2 -nonDefaultRule width_x3

setNanoRouteMode -reset
setNanoRouteMode -drouteUseMultiCutViaEffort high \
                 -drouteUseMinSpacingForBlockage false \
                 -routeInsertAntennaDiode true \
                 -routeAntennaCellName "ANTENNACELLN2HD ANTENNACELLN2_5V ANTENNACELLN2HDLL" \
                 -dbViaWeight { *_beo 4 *_eo 3 *_C* 5 *_C*_beo 9 *_C*_eo 7 }

routeDesign

optDesign -postRoute -setup -hold

pdi report_design

# ----------------------------------------------------------
# Add fillers
# ----------------------------------------------------------
setFillerMode -add_fillers_with_drc false
addFiller -prefix FILLCAP_DA -cell DECAP25HD DECAP15HD DECAP10HD DECAP7HD DECAP5HD DECAP3HD -powerDomain D_A
addFiller -prefix FILL_DA -cell FEED25HD FEED15HD FEED10HD FEED7HD FEED5HD FEED3HD FEED2HD FEED1HD -powerDomain D_A
          
addFiller -prefix FILLCAP_DB -cell DECAP25_5V DECAP15_5V DECAP10_5V DECAP7_5V DECAP5_5V -powerDomain D_B
addFiller -prefix FILL_DB -cell FEED25_5V FEED15_5V FEED10_5V FEED7_5V FEED5_5V FEED3_5V FEED2_5V FEED1_5V -powerDomain D_B

addFiller -prefix FILLCAP_DC -cell DECAP25HD DECAP15HD DECAP10HD DECAP7HD DECAP5HD DECAP3HD -powerDomain D_C
addFiller -prefix FILL_DC -cell FEED25HD FEED15HD FEED10HD FEED7HD FEED5HD FEED3HD FEED2HD FEED1HD -powerDomain D_C

addFiller -prefix FILLCAP_DD -cell DECAP25HDLL DECAP15HDLL DECAP10HDLL DECAP7HDLL DECAP5HDLL DECAP3HDLL -powerDomain D_D
addFiller -prefix FILL_DD -cell FEED25HDLL FEED15HDLL FEED10HDLL FEED7HDLL FEED5HDLL FEED3HDLL FEED2HDLL FEED1HDLL -powerDomain D_D

# ----------------------------------------------------------
# Save routed layout
# ----------------------------------------------------------
saveDesign -cellview [list $libName $cellName layout_05_route]


# ----------------------------------------------------------
# Signoff extraction and timing
# ----------------------------------------------------------
setExtractRCMode -engine postRoute \
                 -effortLevel signoff \
                 -qrcRunMode sequential \
                 -useQrcOAInterface true \
                 -lefTechFileMap $lefTechFileMap

extractRC

timeDesign -signOff -reportOnly
timeDesign -signOff -hold -reportOnly

# ----------------------------------------------------------
# Verification
# ----------------------------------------------------------
verifyConnectivity -report verifyConn.rpt
verify_drc -report verifyDrc.rpt
verifyProcessAntenna -report verifyProcessAnt.rpt

# ----------------------------------------------------------
# Data export (exclude CORNERF for later PVS-LVS)
# ----------------------------------------------------------
saveNetlist ${cellName}.v -excludeLeafCell \
    -excludeCellInst { CORNERF FILLER100F FILLER84F FILLER50F FILLER40F FILLER20F FILLER10F FILLER05F FILLER03F FILLER02F }
saveNetlist ${cellName}_phys.v -excludeLeafCell \
    -excludeCellInst { CORNERF FILLER100F FILLER84F FILLER50F FILLER40F FILLER20F FILLER10F FILLER05F FILLER03F FILLER02F } \
    -includePhysicalCell { ANTENNACELLN2HD DECAP25HD DECAP15HD DECAP10HD DECAP7HD DECAP5HD DECAP3HD \
                           ANTENNACELLN2_5V DECAP25_5V DECAP15_5V DECAP10_5V DECAP7_5V DECAP5_5V \
                           ANTENNACELLN2HDLL DECAP25HDLL DECAP15HDLL DECAP10HDLL DECAP7HDLL DECAP5HDLL DECAP3HDLL }
saveNetlist ${cellName}_phys_pg.v -excludeLeafCell -includePowerGround \
    -excludeCellInst { CORNERF FILLER100F FILLER84F FILLER50F FILLER40F FILLER20F FILLER10F FILLER05F FILLER03F FILLER02F } \
    -includePhysicalCell { ANTENNACELLN2HD DECAP25HD DECAP15HD DECAP10HD DECAP7HD DECAP5HD DECAP3HD \
                           ANTENNACELLN2_5V DECAP25_5V DECAP15_5V DECAP10_5V DECAP7_5V DECAP5_5V \
                           ANTENNACELLN2HDLL DECAP25HDLL DECAP15HDLL DECAP10HDLL DECAP7HDLL DECAP5HDLL DECAP3HDLL }

set dbgLefDefOutVersion 5.8
defOut -floorplan -routing ${cellName}.def

rcOut -view av_wc  -spef ${cellName}_wc.spef 
rcOut -view av_typ -spef ${cellName}_typ.spef 
rcOut -view av_bc  -spef ${cellName}_bc.spef 

write_sdf -setuphold merge_always \
          -recrem merge_always -version 3.0 \
          -min_view av_bc -max_view av_wc -typ_view av_typ \
          -target_application verilog ${cellName}_pm1.sdf
    
write_power_intent -1801 ${cellName}.upf

streamOut ${cellName}.gds.gz -mapFile $streamOutMap -dieAreaAsBoundary -outputMacros \
    -merge { ../pdk/xt018/diglibs/D_CELLS_HD/v4_2/gds_cdl/v4_2_0/gds/xt018_D_CELLS_HD.gds \
             ../pdk/xt018/diglibs/D_CELLS_HD/v4_2/gds_cdl/v4_2_0/gds/xt018_xx31_MET3_METMID_D_CELLS_HD_mprobe.gds \
             ../pdk/xt018/diglibs/D_CELLS_5V/v5_1/gds_cdl/v5_1_0/gds/xt018_D_CELLS_5V.gds \
             ../pdk/xt018/diglibs/D_CELLS_5V/v5_1/gds_cdl/v5_1_0/gds/xt018_xx31_MET3_METMID_D_CELLS_5V_mprobe.gds \
             ../pdk/xt018/diglibs/D_CELLS_HDLL/v1_2/gds_cdl/v1_2_2/gds/xt018_D_CELLS_HDLL.gds \
             ../pdk/xt018/diglibs/D_CELLS_HDLL/v1_2/gds_cdl/v1_2_2/gds/xt018_xx31_MET3_METMID_D_CELLS_HDLL_mprobe.gds \
             ../pdk/xt018/diglibs/D_CELLS_HDMV/v2_1/gds_cdl/v2_1_0/gds/xt018_D_CELLS_HDMV.gds \
             ../pdk/xt018/diglibs/IO_CELLS_F5V/v2_3/gds_cdl/v2_3_2/gds/xt018_1231_MET3_METMID_IO_CELLS_F5V.gds \
             ../virtuoso/XSPRAMLP_96X16_M8TA_frame.gds }

reportIsolation
reportShifter
reportPowerSwitch -outFile MV_Demo.powerswitch.rpt

#run_pvs_drc_rules ../src/pvsdrc.pvl -gds_file MV_Demo.gds.gz -work_directory ./layoutverification/pvs_drc/MV_Demo

# ----------------------------------------------------------
# Save signoff layout with RC database
# ----------------------------------------------------------
saveDesign -cellview [list $libName $cellName layout_06_signoff] -rc


exit
