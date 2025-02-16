// Multi voltage demo design

module MV_Demo_core (res_da, rst, clk, control, scan_enable, scan_in, scan_out, shutoff, test_mode);

    output  [4:0]   res_da;
    output          scan_out;

    input           rst, control, clk, scan_enable,
                    shutoff, test_mode, scan_in;

    reg             reg_steu0, reg_steu1, reg_steu2, reg_steu3;
    reg             reg_r1_control, reg_D_C_onwork,
                    reg_D_C_store, reg_D_C_shuton, cp_bd;

    wire            clk_i, rst_i, control_a, control_dc, control_dbd,
                    i_D_C_store, i_D_C_shuton, i_D_C_onwork,
                    reg_steuVar1, reg_steuVar2, reg_steuVar3, p_NULL,
                    TD_C_onwork, TD_C_store, TD_C_shuton;

    wire    [4:0]   res_da, res_db, res_dc, res_dd,
                    koeff_da_to_db, koeff_da_to_dc, koeff_da_to_dd,
                    koeff_db_to_da, koeff_db_to_dc, koeff_db_to_dd,
                    koeff_dc_to_da, koeff_dc_to_db, koeff_dc_to_dd,
                    koeff_dd_to_da, koeff_dd_to_db, koeff_dd_to_dc,
                    koeff_dd_to_db_ov_da,
                    koeff_dc_to_da_ram, koeff_dc_to_db_ram,
                    koeff_dc_to_dd_ram;

    wire    [15:0]  ram_q;
    wire    [5:0]   d_adr;

    // add schmitt trigger on asynchronous nets (clock and reset)
    STEHDX1 sm_trig1 (.A(clk), .Q(clk_i));
    STEHDX1 sm_trig2 (.A(rst), .Q(rst_i));

    always @(posedge clk_i or negedge rst_i) begin
        if (~rst_i) reg_r1_control = 0;
        else reg_r1_control = control;
    end

    always @(posedge clk_i or negedge rst_i) begin
        if (~rst_i) cp_bd = 0;
        else cp_bd = ~cp_bd;
    end

    assign  control_a   = test_mode |  reg_r1_control;
    assign  control_dc  = test_mode | (reg_r1_control & reg_D_C_onwork);
    assign  control_dbd = test_mode | (reg_r1_control & cp_bd);


    logic b_clk;
    logic c_clk;
    logic d_clk;

    logic b_clk_en;
    logic c_clk_en;
    logic d_clk_en;
    logic c_rst_n;

    logic dom_c_isolate;
    logic dom_c_retain;
    logic dom_c_pg_rst_n;
    logic dom_c_switch_en;


/////////////////////////////////////////////////////////////////////////////////
//
//  Start of Lab4
//

// Remove and connect as per Lab4
//always_comb b_clk = clk_i;
//always_comb c_clk = clk_i;
//always_comb d_clk = clk_i;

//always_comb b_clk_en = 1'b1;
//always_comb c_clk_en = 1'b1;
//always_comb d_clk_en = 1'b1;
//always_comb dom_c_pg_rst_n = 1;







typedef enum logic [8:0] {
  ACT0    = 9'b111_1_1_0_0_00,       // All active after POR and after PM3
  ACT1    = 9'b111_1_1_0_0_01,       // All active after PM1
  ACT2    = 9'b111_1_1_0_0_10,       // All active after PM2
  PM1     = 9'b011_1_1_0_0_00,       // stop B
  PM2     = 9'b001_1_1_0_0_00,       // stop B,D
  PM3_CG  = 9'b000_1_1_0_0_00,       // stop B,D,C
  PM3_ISO = 9'b000_1_1_0_1_00,       // stop B,D,C . Assert Isolation
  PM3_RET = 9'b000_1_1_1_1_00,       // stop B,D,C . Assert Isolation, Assert retention
  PM3_RES = 9'b000_1_0_1_1_00,       // stop B,D,C . Assert Isolation, Assert retention, Assert reset
  PM3_OFF = 9'b000_0_0_1_1_00        // stop B,D,C . Assert Isolation, Assert retention, Assert reset, PG Switch OFF
} state_e;

state_e state, next;


logic enter_sleep;
logic exit_sleep;
logic shutoff_d1;

always_comb b_clk_en = state[8];
always_comb d_clk_en = state[7];
always_comb c_clk_en = state[6];

always_comb dom_c_isolate   = state[2];
always_comb dom_c_retain    = state[3];
always_comb dom_c_pg_rst_n  = state[4];
always_comb dom_c_switch_en = state[5];

always_comb c_rst_n = test_mode ? rst_i : rst_i && dom_c_pg_rst_n;


always_ff @ (posedge clk_i or negedge rst_i)
  if(!rst_i) shutoff_d1 <= 1'b0;
  else       shutoff_d1 <= shutoff;
  

always_comb enter_sleep =  shutoff && !shutoff_d1;
always_comb exit_sleep  = !shutoff &&  shutoff_d1;


always_ff @ (posedge clk_i or negedge rst_i)
  if(!rst_i)
    state <= ACT0;
  else begin
    case (state)
      ACT0   : state <= enter_sleep ? PM1     : ACT0;
      PM1    : state <= exit_sleep  ? ACT1    : PM1;
      ACT1   : state <= enter_sleep ? PM2     : ACT1;
      PM2    : state <= exit_sleep  ? ACT2    : PM2;
      ACT2   : state <= enter_sleep ? PM3_CG  : ACT2;
      PM3_CG : state <= shutoff     ? PM3_ISO : ACT0;
      PM3_ISO: state <= shutoff     ? PM3_RET : PM3_CG;
      PM3_RET: state <= shutoff     ? PM3_RES : PM3_ISO;
      PM3_RES: state <= shutoff     ? PM3_OFF : PM3_RET;
      PM3_OFF: state <= exit_sleep  ? PM3_RES : PM3_OFF;
    endcase
  end
    


icg_box u_icg_b_clk(
  .E   (b_clk_en),
  .CLK (clk_i), 
  .TE  (1'b0),
  .GCLK(b_clk));
 
icg_box u_icg_c_clk(
  .E   (c_clk_en),
  .CLK (clk_i), 
  .TE  (1'b0),
  .GCLK(c_clk));

icg_box u_icg_d_clk(
  .E   (d_clk_en),
  .CLK (clk_i), 
  .TE  (1'b0),
  .GCLK(d_clk));


//  End of Lab 4
//
/////////////////////////////////////////////////////////////////////////////////




    always @(posedge clk_i or negedge rst_i) begin
        if (~rst_i) reg_steu0 <= 0;
        else reg_steu0 <= shutoff;
    end

    always @(posedge clk_i or negedge rst_i) begin
        if (~rst_i) reg_steu1 <= 0;
        else reg_steu1 <= reg_steu0;
    end

    always @(posedge clk_i or negedge rst_i) begin
        if (~rst_i) reg_steu2 <= 0;
        else reg_steu2 <= reg_steu1;
    end

    always @(posedge clk_i or negedge rst_i) begin
        if (~rst_i) reg_steu3 <= 0;
        else reg_steu3 <= reg_steu2;
    end

    assign reg_steuVar1  = ~(reg_steu0 | reg_steu1 | reg_steu2 | reg_steu3);
    assign reg_steuVar2  = ~((reg_steu1 & ~reg_steu3) | (~reg_steu1 & reg_steu2) | (reg_steu1 & reg_steu2));
    assign reg_steuVar3  = ~(reg_steu0 & reg_steu1 & reg_steu2 & reg_steu3);

    always @(posedge clk_i or negedge rst_i) begin
        if (~rst_i) reg_D_C_onwork <= 1;
        else reg_D_C_onwork <= reg_steuVar1;
    end

    always @(posedge clk_i or negedge rst_i) begin
        if (~rst_i) reg_D_C_store <= 1;
        else reg_D_C_store <= reg_steuVar2;
    end

    always @(posedge clk_i or negedge rst_i) begin
        if (~rst_i) reg_D_C_shuton <= 1;
        else reg_D_C_shuton <= reg_steuVar3;
    end

    assign TD_C_onwork = test_mode | reg_D_C_onwork;
    assign TD_C_store  = test_mode | reg_D_C_store;
    assign TD_C_shuton = test_mode | reg_D_C_shuton;

    BUHDX2  buffer1 (.A (TD_C_onwork), .Q (i_D_C_onwork));
    BUHDX2  buffer2 (.A (TD_C_store),  .Q (i_D_C_store));
    BUHDX2  buffer3 (.A (TD_C_shuton), .Q (i_D_C_shuton));

    pipeline Domain_A (.res (res_da), .clk (clk_i), .rst (rst_i), .control (control_a),
                       .koeff_out_1 (koeff_da_to_db), .koeff_out_2 (koeff_da_to_dc),
                       .koeff_out_3 (koeff_da_to_dd), .koeff_in_1  (koeff_db_to_da),
                       .koeff_in_2  (koeff_dc_to_da_ram), .koeff_in_3  (koeff_dd_to_da));

    pipeline Domain_B (.res (res_db), .clk (clk_i), .rst (rst_i), .control (control_dbd),
                       .koeff_out_1 (koeff_db_to_da), .koeff_out_2 (koeff_db_to_dc),
                       .koeff_out_3 (koeff_db_to_dd), .koeff_in_1  (koeff_da_to_db),
                       .koeff_in_2  (koeff_dc_to_db_ram), .koeff_in_3  (koeff_dd_to_db_ov_da));

    pipeline Domain_C (.res (res_dc), .clk (clk_i), .rst (c_rst_n), .control (control_dc),
                       .koeff_out_1 (koeff_dc_to_da), .koeff_out_2 (koeff_dc_to_db),
                       .koeff_out_3 (koeff_dc_to_dd), .koeff_in_1  (koeff_da_to_dc),
                       .koeff_in_2  (koeff_db_to_dc), .koeff_in_3  (koeff_dd_to_dc));

    pipeline Domain_D (.res (res_dd), .clk (clk_i), .rst (rst_i), .control (control_dbd),
                       .koeff_out_1 (koeff_dd_to_da), .koeff_out_2 (koeff_dd_to_db),
                       .koeff_out_3 (koeff_dd_to_dc), .koeff_in_1  (koeff_da_to_dd),
                       .koeff_in_2  (koeff_db_to_dd), .koeff_in_3  (koeff_dc_to_dd_ram));

    // add buffer for data transfer from Block D (1.2V) to Block B (5.0V) over Block A (1.8V)
    BUHDX2      b_ov_0    (.A (koeff_dd_to_db[0]), .Q (koeff_dd_to_db_ov_da[0]));
    BUHDX2      b_ov_1    (.A (koeff_dd_to_db[1]), .Q (koeff_dd_to_db_ov_da[1]));
    BUHDX2      b_ov_2    (.A (koeff_dd_to_db[2]), .Q (koeff_dd_to_db_ov_da[2]));
    BUHDX2      b_ov_3    (.A (koeff_dd_to_db[3]), .Q (koeff_dd_to_db_ov_da[3]));
    BUHDX2      b_ov_4    (.A (koeff_dd_to_db[4]), .Q (koeff_dd_to_db_ov_da[4]));

    DLY1HDX0   r_adr_0 (.A (res_da[0]), .Q (d_adr[0]));
    DLY1HDX0   r_adr_1 (.A (res_da[1]), .Q (d_adr[1]));
    DLY1HDX0   r_adr_2 (.A (res_da[2]), .Q (d_adr[2]));
    DLY1HDX0   r_adr_3 (.A (res_da[3]), .Q (d_adr[3]));
    DLY1HDX0   r_adr_4 (.A (res_db[4]), .Q (d_adr[4]));
    DLY1HDX0   r_adr_5 (.A (res_db[0]), .Q (d_adr[5]));

    XSPRAMLP_96X16_M8TA RAM (.Q (ram_q), .D ({1'b0, koeff_dc_to_dd, koeff_dc_to_db, koeff_dc_to_da}),
                             .A ({1'b0,{6{1'b1}} & d_adr}), .CLK (clk_i), .CEn (1'b0),
                             .WEn (~i_D_C_onwork));

    assign  koeff_dc_to_da_ram = ~i_D_C_store ? {5{1'b1}} & ram_q [4:0]   : koeff_dc_to_da;
    assign  koeff_dc_to_db_ram = ~i_D_C_store ? {5{1'b1}} & ram_q [9:5]   : koeff_dc_to_db;
    assign  koeff_dc_to_dd_ram = ~i_D_C_store ? {5{1'b1}} & ram_q [14:10] : koeff_dc_to_dd;

endmodule
