#!/bin/csh

ln -s /cadence_pdk/xfab/XKIT/x_all/cadence/XFAB_Digital_MultiVoltage_RefKit-cadence/v1_1_1/tcl/ tcl
ln -s /cadence_pdk/xfab/XKIT/x_all/cadence/XFAB_Digital_MultiVoltage_RefKit-cadence/v1_1_1/src/ src
ln -s /cadence_pdk/xfab/XKIT/x_all/cadence/XFAB_Digital_MultiVoltage_RefKit-cadence/v1_1_1/pdk/ pdk
ln -s /cadence_pdk/xfab/XKIT/x_all/cadence/XFAB_Digital_MultiVoltage_RefKit-cadence/v1_1_1/verilog/ verilog
ln -s /cadence_pdk/xfab/XKIT/x_all/cadence/XFAB_Digital_MultiVoltage_RefKit-cadence/v1_1_1/liberty/ liberty
ln -s /cadence_pdk/xfab/XKIT/x_all/cadence/XFAB_Digital_MultiVoltage_RefKit-cadence/v1_1_1/virtuoso/ virtuoso


mkdir xcelium conformal genus innovus xcelium/work xcelium/work_lib xcelium/work_sub

cp /cadence_pdk/xfab/XKIT/x_all/cadence/XFAB_Digital_MultiVoltage_RefKit-cadence/v1_1_1/xcelium/cds.lib xcelium/


echo "INCLUDE ../virtuoso/xt018.lib"         >  local/cds.lib
echo "INCLUDE ../virtuoso/xt018_combine.lib" >> local/cds.lib 
echo "DEFINE XSPRAMLP_96X16_M8TA ../virtuoso/XSPRAMLP_96X16_M8TA" >> local/cds.lib
echo "DEFINE MV_Demo $PWD/innovus/MV_Demo" >> local/cds.lib

