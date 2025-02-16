`timescale 1ns/10ps

module tb_MV_Demo ;

    parameter     ram_init_file = "../src/XSPRAMLP_96X16_M8TA.initFile";

    wire [4:0]    res_da;
    wire          scan_out;

    reg           rst, control, clk, scan_enable, scan_in,
                  shutoff, test_mode, status;

    `ifdef presyn
    	parameter tracefileName = "wave_presyn.trc";
    `endif

    `ifdef postsyn
    	parameter tracefileName = "wave_postsyn.trc";
    `endif

    `ifdef postlayout_fast
    	parameter tracefileName = "wave_postlayout_fast.trc";
    `endif

    `ifdef postlayout_slow
    	parameter tracefileName = "wave_postlayout_slow.trc";
    `endif

    integer       tracefile;

    MV_Demo MV_Demo (.res_da(res_da), .rst(rst), .clk(clk), .control(control),
                     .scan_enable(scan_enable), .scan_in(scan_in), .scan_out(scan_out),
                     .shutoff(shutoff), .test_mode(test_mode));
initial begin
    $shm_open(,1);
    $shm_probe("ACTM");
end

initial begin
`ifdef upf_sim
    `ifdef presyn
        status=$supply_on("tb_MV_Demo.MV_Demo.VDD", 1.62);
        status=$supply_on("tb_MV_Demo.MV_Demo.VDDOR", 4.50);
        status=$supply_on("tb_MV_Demo.MV_Demo.vdd_A", 1.62);
        status=$supply_on("tb_MV_Demo.MV_Demo.vdd_B", 4.50);
        status=$supply_on("tb_MV_Demo.MV_Demo.vdd_D", 1.08);
        status=$supply_on("tb_MV_Demo.MV_Demo.GND", 0.0);
    `endif


    `ifdef postsyn
        $sdf_annotate ("../genus/results/MV_Demo.sdf", MV_Demo, , "sdf.log", "MAXIMUM");
        status=$supply_on("tb_MV_Demo.MV_Demo.VDD", 1.62);
        status=$supply_on("tb_MV_Demo.MV_Demo.VDDOR", 4.50);
        status=$supply_on("tb_MV_Demo.MV_Demo.vdd_A", 1.62);
        status=$supply_on("tb_MV_Demo.MV_Demo.vdd_B", 4.50);
        status=$supply_on("tb_MV_Demo.MV_Demo.vdd_D", 1.08);
        status=$supply_on("tb_MV_Demo.MV_Demo.GND", 0.0);
    `endif

    `ifdef postlayout_fast
        $sdf_annotate ("../innovus/MV_Demo_pm1.sdf", MV_Demo, , "sdf.log", "MINIMUM");
        status=$supply_on("tb_MV_Demo.MV_Demo.VDD", 1.62);
        status=$supply_on("tb_MV_Demo.MV_Demo.VDDOR", 4.50);
        status=$supply_on("tb_MV_Demo.MV_Demo.vdd_A", 1.62);
        status=$supply_on("tb_MV_Demo.MV_Demo.vdd_B", 4.50);
        status=$supply_on("tb_MV_Demo.MV_Demo.vdd_D", 1.08);
        status=$supply_on("tb_MV_Demo.MV_Demo.GND", 0.0);
    `endif

    `ifdef postlayout_slow
        $sdf_annotate ("../innovus/MV_Demo_pm1.sdf", MV_Demo, , "sdf.log", "MAXIMUM");
        status=$supply_on("tb_MV_Demo.MV_Demo.VDD", 1.62);
        status=$supply_on("tb_MV_Demo.MV_Demo.VDDOR", 4.50);
        status=$supply_on("tb_MV_Demo.MV_Demo.vdd_A", 1.62);
        status=$supply_on("tb_MV_Demo.MV_Demo.vdd_B", 4.50);
        status=$supply_on("tb_MV_Demo.MV_Demo.vdd_D", 1.08);
        status=$supply_on("tb_MV_Demo.MV_Demo.GND", 0.0);
    `endif

`endif

    tracefile = $fopen(tracefileName, "w");
    $fdisplay(tracefile,"@nodes");
    $fdisplay(tracefile,"rst clk control shutoff scan_enable scan_in scan_out res_da[4:0]");

end

initial begin

            $fdisplay(tracefile,"@data");
            $fdisplay(tracefile,"%d %d %d %d %d %d %d  %d %d %d %d %d // %t",
                  rst, clk, control, shutoff, scan_enable, scan_in, scan_out,
                  res_da[4], res_da[3], res_da[2], res_da[1], res_da[0], $realtime);

            $readmemh(ram_init_file, tb_MV_Demo.MV_Demo.core.RAM.sub1.RAM_matrix);
            rst          = 1'b0;
            control      = 1'b0;
            clk          = 1'b0;
            shutoff      = 1'b0;
            test_mode    = 1'b0;
            scan_enable  = 1'b0;
            scan_in      = 1'b0;

    #120    rst          = 1'b1;
    #480    control      = 1'b1;

end

always begin

    #10     if (control == 1) clk = 1'b0;
            $fdisplay(tracefile,"%d %d %d %d %d %d %d  %d %d %d %d %d // %t",
                  rst, clk, control, shutoff, scan_enable, scan_in, scan_out,
                  res_da[4], res_da[3], res_da[2], res_da[1], res_da[0], $realtime);
    #2      if (control == 1) clk = 1'b1;
    #15     if (control == 1) clk = 1'b0;
    #3      if (control == 1) clk = 1'b0;

end

always begin

    #8400   shutoff      = 1'b1;
    #8400   shutoff      = 1'b0;

end

always begin

    #54000  $stop ;
    #18000  $finish ;

end

endmodule
