`timescale 1ns / 1ps

module watch_dp (
    input        clk,
    input        p_rst,
    input        i_sec,
    input        i_minute,
    input        i_hour,
    output [6:0] o_msec,
    output [5:0] o_sec,
    output [5:0] o_minute,
    output [4:0] o_hour
);

    wire w_tick_100hz;
    wire w_tick_60msec;
    wire w_tick_60sec;
    wire w_tick_60minute;

    time_counter_watch #(  // msec
        .BIT_WIDTH (7),
        .TIME_COUNT(100),
        .RESET_NUM (0)
    ) U_MSEC_COUNTER_WATCH (
        .clk(clk),
        .p_rst(p_rst),
        .i_tick(w_tick_100hz),
        .i_sec(i_sec),
        .i_minute(1'b0),
        .i_hour(1'b0),
        .o_time(o_msec),
        .o_tick(w_tick_60msec)
    );

    time_counter_watch #(  // sec
        .BIT_WIDTH (6),
        .TIME_COUNT(60),
        .RESET_NUM (0)
    ) U_SEC_COUNTER_WATCH (
        .clk(clk),
        .p_rst(p_rst),
        .i_tick(w_tick_60msec),
        .i_sec(1'b0),
        .i_minute(i_minute),
        .i_hour(1'b0),
        .o_time(o_sec),
        .o_tick(w_tick_60sec)
    );

    time_counter_watch #(  // minute
        .BIT_WIDTH (6),
        .TIME_COUNT(60),
        .RESET_NUM (0)
    ) U_MINUTE_COUNTER_WATCH (
        .clk(clk),
        .p_rst(p_rst),
        .i_tick(w_tick_60sec),
        .i_sec(1'b0),
        .i_minute(1'b0),
        .i_hour(i_hour),
        .o_time(o_minute),
        .o_tick(w_tick_60minute)
    );

    time_counter_watch #(  // hour
        .BIT_WIDTH (5),
        .TIME_COUNT(24),
        .RESET_NUM (12)
    ) U_HOUR_COUNTER_WATCH (
        .clk(clk),
        .p_rst(p_rst),
        .i_tick(w_tick_60minute),
        .i_sec(1'b0),
        .i_minute(1'b0),
        .i_hour(1'b0),
        .o_time(o_hour),
        .o_tick()
    );

    tick_gen_100hz_watch U_TICK_GEN_100Hz_WATCH (
        .clk(clk),
        .p_rst(p_rst),
        .o_tick_100hz(w_tick_100hz)
    );

endmodule

module time_counter_watch #(
    parameter BIT_WIDTH = 7,
    TIME_COUNT = 100,
    RESET_NUM = 12
) (
    input                  clk,
    input                  p_rst,
    input                  i_tick,
    input                  i_sec,
    input                  i_minute,
    input                  i_hour,
    output [BIT_WIDTH-1:0] o_time,
    output                 o_tick
);

    reg [$clog2(TIME_COUNT)-1:0] count_reg, count_next;
    reg tick_reg, tick_next;
    assign o_time = count_reg;
    assign o_tick = tick_reg;

    always @(posedge clk, posedge p_rst) begin
        if (p_rst) begin
            count_reg <= RESET_NUM;
            tick_reg  <= 1'b0;
        end else begin
            count_reg <= count_next;
            tick_reg  <= tick_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        tick_next  = 1'b0;
            if (i_sec | i_minute | i_hour) begin
                tick_next = 1'b1;
            end
            if (i_tick) begin
                if (count_reg == TIME_COUNT - 1) begin
                    count_next = 0;
                    tick_next  = 1'b1;
                end else begin
                    count_next = count_reg + 1;
                    tick_next  = 1'b0;
                end
            end
        end

endmodule

module tick_gen_100hz_watch (
    input  clk,
    input  p_rst,
    output o_tick_100hz
);
    parameter FCOUNT = 100_000_000 / 100;
    reg [$clog2(FCOUNT)-1:0] r_counter;
    reg r_tick_100hz;
    reg r_runstop;
    assign o_tick_100hz = r_tick_100hz;

    always @(posedge clk, posedge p_rst) begin
        if (p_rst) begin
            r_counter <= 0;
            r_tick_100hz <= 1'b0;
        end else begin
            if (r_counter == FCOUNT - 1) begin
                r_counter <= 0;
                r_tick_100hz <= 1'b1;
            end else begin
                r_counter <= r_counter + 1;
                r_tick_100hz <= 1'b0;
            end
        end
    end
endmodule
