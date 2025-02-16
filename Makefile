sim:
	cd xcelium; \
	xrun -sv \
	../pdk/xt018/diglibs/D_CELLS_HDMV/v2_1/verilog/v2_1_0/VLG_PRIMITIVES.v \
	../verilog/D_CELLS_5V.v \
	../pdk/xt018/diglibs/D_CELLS_HD/v4_2/verilog/v4_2_0/D_CELLS_HD.v \
	../pdk/xt018/diglibs/D_CELLS_HDLL/v1_2/verilog/v1_2_1/D_CELLS_HDLL.v \
	../pdk/xt018/diglibs/D_CELLS_HDMV/v2_1/verilog/v2_1_0/D_CELLS_HDMV.v \
	../pdk/xt018/diglibs/IO_CELLS_F5V/v2_3/verilog/v2_3_0/IO_CELLS_F5V_UPF.v \
	../pdk/xt018/spram/XSPRAMLP_96X16_M8TA/v4_0_2/verilog/XSPRAMLP_96X16_M8TA.v \
	../src/mult.v ../src/add.v ../src/signature.v ../src/pipeline.v \
	../src/MV_Demo.v \
	../local/MV_Demo_core.v \
	../local/tb_MV_Demo.v \
	../local/icg_box.sv \
	-access +wc \
	-nowarn CUVWSP -nowarn SDFNCAP -nowarn SDFNL1 -nowarn SDFNDP \
	-notimingchecks \
	-input ../tcl/xcelium_gen_vcd_presyn.tcl \
	+define+presyn

sim_upf:
	cd xcelium; \
	xrun -sv \
	../pdk/xt018/diglibs/D_CELLS_HDMV/v2_1/verilog/v2_1_0/VLG_PRIMITIVES.v \
	../verilog/D_CELLS_5V.v \
	../pdk/xt018/diglibs/D_CELLS_HD/v4_2/verilog/v4_2_0/D_CELLS_HD.v \
	../pdk/xt018/diglibs/D_CELLS_HDLL/v1_2/verilog/v1_2_1/D_CELLS_HDLL.v \
	../pdk/xt018/diglibs/D_CELLS_HDMV/v2_1/verilog/v2_1_0/D_CELLS_HDMV.v \
	../pdk/xt018/diglibs/IO_CELLS_F5V/v2_3/verilog/v2_3_0/IO_CELLS_F5V_UPF.v \
	../pdk/xt018/spram/XSPRAMLP_96X16_M8TA/v4_0_2/verilog/XSPRAMLP_96X16_M8TA.v \
	../src/mult.v ../src/add.v ../src/signature.v ../src/pipeline.v \
	../src/MV_Demo.v \
	../local/MV_Demo_core.v \
	../local/tb_MV_Demo.v \
	../local/icg_box.sv \
	-access +wc \
	-nowarn CUVWSP -nowarn SDFNCAP -nowarn SDFNL1 -nowarn SDFNDP \
	-notimingchecks \
	-input ../tcl/xcelium_gen_vcd_presyn.tcl \
	+define+presyn \
	+define+upf_sim \
	-logfile xmelab_postsyn.log \
	-lps_dut_top tb_MV_Demo.MV_Demo \
	-lps_1801 ../local/MV_Demo.upf \
	-lps_verbose 3 \
	-lps_dbc \
	-lps_lib_mfile ../src/cdb_file_list.txt

syn:
	cd genus; \
	genus -wait 60 -no_gui -overwrite -file ../local/MV_Demo_synth.tcl -lic_startup_options Joules_RTL_Power


pnr:
	cd innovus; \
	innovus -wait 180 -files ../local/MV_Demo_PuR.tcl
