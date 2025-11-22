`timescale 1ns / 1ps

module stopwatch (
    input        clk,
    input        rst,
    input        Btn_L,
    input        Btn_R,
    input        Btn_U,
    input        Btn_D,
    input        k_start,//s
    input        k_stop,//t
    input        k_clear,//c
    input        k_hour_p,//H
    input        k_min_p,
    input        k_sec_p,
    input  [1:0] sel,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);
    wire [6:0] w_msec_sw, w_msec_w;
    wire [5:0] w_sec_sw, w_sec_w;
    wire [5:0] w_min_sw, w_min_w;
    wire [4:0] w_hour_sw, w_hour_w;
    wire w_stop, w_clear, w_run;
    wire [23:0] i_time;
    // wire w_plus, w_minus, w_digit_increase, w_mode_reset;
    // wire w_btn_plus,w_btn_minus;
    wire w_btn_d,w_btn_l,w_btn_r,w_btn_u;
 
    butten_debounce U_btn_db_left (
        .clk  (clk),
        .rst  (rst),
        .i_btn(Btn_L),
        .o_btn(w_btn_l)
    );

    butten_debounce U_btn_db_right (
        .clk  (clk),
        .rst  (rst),
        .i_btn(Btn_R),
        .o_btn(w_btn_r)
    );

    butten_debounce U_btn_db_up (
        .clk  (clk),
        .rst  (rst),
        .i_btn(Btn_U),
        .o_btn(w_btn_u)
    );

    butten_debounce U_btn_db_down (
        .clk  (clk),
        .rst  (rst),
        .i_btn(Btn_D),
        .o_btn(w_btn_d)
    );
    
    stopwatch_dp U_sw_dp (
        .clk    (clk),
        .rst    (rst),
        .i_run  (w_run),
        .i_clear(w_clear),
        .i_stop (w_stop),
        .msec   (w_msec_sw),
        .sec    (w_sec_sw),
        .min    (w_min_sw),
        .hour   (w_hour_sw)
    );
    stopwatch_cu U_SW_CU (
        .clk    (clk),
        .rst    (rst),
        .i_stop (w_btn_d | k_stop),
        .i_run  (w_btn_r | k_start),
        .i_clear(w_btn_l | k_clear),
        .o_run  (w_run),
        .o_clear(w_clear),
        .o_stop (w_stop)

    );

    watch_dp u_watch_dp (
        .clk     (clk),
        .p_rst   (rst),
        .i_sec   (w_btn_d | k_sec_p),
        .i_minute(w_btn_l | k_min_p),
        .i_hour  (w_btn_u | k_hour_p),
        .o_msec  (w_msec_w),
        .o_sec   (w_sec_w),
        .o_minute(w_min_w),
        .o_hour  (w_hour_w)
    );

    select_w_sw U_sel (
        .sel_i_time_sw({w_hour_sw, w_min_sw, w_sec_sw, w_msec_sw}),
        .sel_i_time_w ({w_hour_w, w_min_w, w_sec_w, w_msec_w}),
        .sel          (sel[1]),
        .i_time       (i_time)
    );

    fnd_controller U_fnd_cntl (
        .clk     (clk),
        .reset   (rst),
        .sel     (sel[0]),
        .i_time  (i_time),
        .fnd_data(fnd_data),
        .fnd_com (fnd_com)
    );



endmodule


