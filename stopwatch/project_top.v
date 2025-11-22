`timescale 1ns / 1ps

module project_top (
    input        clk,
    input        rst,
    input        rx,
    input        Btn_L,
    input        Btn_R,
    input        Btn_U,
    input        Btn_D,
    input  [1:0] sel,
    output       tx,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);

    wire [7:0] w_rx_data, w_cntl_data;
    wire w_rx_empty;
    wire w_start, w_stop, w_clear, w_hour_p, w_min_p, w_sec_p, w_mode, w_digit;
    wire w_btn_d, w_btn_l, w_btn_r, w_btn_u;
    wire w_sel_m,w_sel_a;
    wire [1:0] w_sw;
    wire sel_mode;
    wire sw_mode;
    wire digit_mode;

    stopwatch U_sw_w (
        .clk     (clk),
        .rst     (rst),
        .Btn_L   (Btn_L),
        .Btn_R   (Btn_R),
        .Btn_U   (Btn_U),
        .Btn_D   (Btn_D),
        .k_start (w_start),
        .k_stop  (w_stop),
        .k_clear (w_clear),
        .k_hour_p(w_hour_p),
        .k_min_p (w_min_p),
        .k_sec_p (w_sec_p),
        .sel     ({sel_mode,digit_mode}),
        .fnd_com (fnd_com),
        .fnd_data(fnd_data)
    );


    cummand_cu U_cmd (
        .clk(clk),
        .rst(rst),
        .rx_fifo_data(w_rx_data),
        .rx_trigger(w_rx_empty),
        .o_start(w_start),
        .o_stop(w_stop),
        .o_clear(w_clear),
        .o_hour_p(w_hour_p),
        .o_min_p(w_min_p),
        .o_sec_p(w_sec_p),
        .o_sel_m(w_sel_m),
        .o_sel_a(w_sel_a)
    );

    select_sel_pc U_mode_select (
        .clk(clk),
        .rst(rst),
        .sel_m(w_sel_m),
        .sel_a(w_sel_a),
        .sw(sel[1]),
        .digit(sel[0]),
        .o_mod1(sel_mode),
        .o_digit(digit_mode)
    );

    uart_top U_uart_top (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx(tx),
        .o_rx_data(w_rx_data),
        .rx_trigger(w_rx_empty)
    );

endmodule
