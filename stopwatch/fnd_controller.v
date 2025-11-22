`timescale 1ns / 1ps

module fnd_controller (
    input clk,
    input reset,
    input sel,
    input [23:0] i_time,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);
    wire [3:0] w_bcd,w_bcd_msec_sec,w_bcd_min_hour, w_msec_digit_1, w_msec_digit_10;
    wire [3:0] w_sec_digit_1, w_sec_digit_10;
    wire [3:0] w_min_digit_1, w_min_digit_10;
    wire [3:0] w_hour_digit_1, w_hour_digit_10;
    wire [1:0] w_sel;
    wire [3:0] w_dot_data;
    wire w_clk_1khz;

    digit_splitter #(
        .BIT_WIDTH(7)
    ) u_msec_ds (
        .counter_data(i_time[6:0]),
        .digit_1(w_msec_digit_1),
        .digit_10(w_msec_digit_10)
    );

    digit_splitter #(
        .BIT_WIDTH(6)
    ) u_sec_ds (
        .counter_data(i_time[12:7]),
        .digit_1(w_sec_digit_1),
        .digit_10(w_sec_digit_10)
    );

    digit_splitter #(
        .BIT_WIDTH(6)
    ) u_min_ds (
        .counter_data(i_time[18:13]),
        .digit_1(w_min_digit_1),
        .digit_10(w_min_digit_10)
    );

    digit_splitter #(
        .BIT_WIDTH(5)
    ) u_hour_ds (
        .counter_data(i_time[23:19]),
        .digit_1(w_hour_digit_1),
        .digit_10(w_hour_digit_10)
    );

    comparator_msec u_comp_msec(
    .msec(i_time[6:0]),
    .dot_data(w_dot_data)
);
    mux_8x1 u_mux_msec_sec (
        .digit_1(w_msec_digit_1),
        .digit_10(w_msec_digit_10),
        .digit_100(w_sec_digit_1),
        .digit_1000(w_sec_digit_10),
        .digit_5(4'hf),
        .digit_6(4'hf),
        .digit_7(w_dot_data),
        .digit_8(4'hf),
        .sel(w_sel),
        .bcd(w_bcd_msec_sec)
    );

    mux_8x1 u_mux_min_hour (
        .digit_1(w_min_digit_1),
        .digit_10(w_min_digit_10),
        .digit_100(w_hour_digit_1),
        .digit_1000(w_hour_digit_10),
        .digit_5(4'hf),
        .digit_6(4'hf),
        .digit_7(w_dot_data),
        .digit_8(4'hf),
        .sel(w_sel),
        .bcd(w_bcd_min_hour)
    );

    mux_2x1 U_2x1_mux (
        .sel(sel),
        .msec_sec(w_bcd_msec_sec),
        .min_hour(w_bcd_min_hour),
        .bcd(w_bcd)
    );

    decoder_2x4 u_de_2x4 (
        .sel(w_sel[1:0]),
        .fnd_com(fnd_com)
    );

    bcd_decoder u_bcd_decoder (
        .bcd(w_bcd),
        .fnd_data(fnd_data)
    );

    clk_div_1khz u_div_clk (
        .clk(clk),
        .reset(reset),
        .o_clk_1khz(w_clk_1khz)
    );
    counter_8 u_counter (
        .clk  (w_clk_1khz),
        .reset(reset),
        .sel  (w_sel)
    );


endmodule

module comparator_msec (
    input [6:0] msec,
    output [3:0] dot_data
);
    
    assign dot_data = (msec<50) ? 4'hf : 4'he;

endmodule
module mux_2x1 (
    input sel,
    input [3:0] msec_sec,
    input [3:0] min_hour,
    output [3:0] bcd
);
    reg [3:0] bcd_reg;

    assign bcd = bcd_reg;

    always @(*) begin
        case (sel)
            1'b0: bcd_reg = msec_sec;
            1'b1: bcd_reg = min_hour;
            default: bcd_reg = msec_sec;
        endcase
    end


endmodule

module decoder_2x4 (
    input  [1:0] sel,
    output [3:0] fnd_com
);
    assign fnd_com = (sel == 2'b00 ) ? 4'b1110:
                     (sel == 2'b01 ) ? 4'b1101:
                     (sel == 2'b10 ) ? 4'b1011:
                     (sel == 2'b11 ) ? 4'b0111:4'b1111;//우선순위가 생김 case 문은 안생김

endmodule

module bcd_decoder (
    input [3:0] bcd,
    output reg [7:0] fnd_data
);

    always @(bcd) begin// 항상 괄호안에 있는 값(sensitivity list)에 변화가 있으면 동작 없으면 유지 = LUT
        case (bcd)
            4'b0000: fnd_data = 8'hC0;  //0
            4'b0001: fnd_data = 8'hF9;  //1
            4'b0010: fnd_data = 8'hA4;  //2
            4'b0011: fnd_data = 8'hB0;  //3
            4'b0100: fnd_data = 8'h99;  //4
            4'b0101: fnd_data = 8'h92;  //5
            4'b0110: fnd_data = 8'h82;  //6
            4'b0111: fnd_data = 8'hF8;  //7
            4'b1000: fnd_data = 8'h80;  //8
            4'b1001: fnd_data = 8'h90;  //9
            4'b1010: fnd_data = 8'h88;  //a
            4'b1011: fnd_data = 8'h83;  //b
            4'b1100: fnd_data = 8'hC6;  //c
            4'b1101: fnd_data = 8'hA1;  //d
            4'b1110: fnd_data = 8'hff;  //e -> dot on
            4'b1111: fnd_data = 8'hff;  //f -> dot off
            default: fnd_data = 8'hff;
        endcase
    end  //always 출력 fnd_data -> 무조건 출력의 data_type은 reg타입이여야 한다

endmodule

module mux_8x1 (
    input [3:0] digit_1,
    input [3:0] digit_10,
    input [3:0] digit_100,
    input [3:0] digit_1000,
    input [3:0] digit_5,
    input [3:0] digit_6,
    input [3:0] digit_7, //-> dot on
    input [3:0] digit_8,
    input [1:0] sel,
    output [3:0] bcd //reg type으로 선언 하지 않아도 로직에서 차이 없음
);
    reg [3:0] r_bcd;

    assign bcd = r_bcd;

    always @(*) begin
        case (sel)
            2'b00:   r_bcd = digit_1;
            2'b01:   r_bcd = digit_10;
            2'b10:   r_bcd = digit_100;
            2'b11:   r_bcd = digit_1000;
            3'b100:   r_bcd = digit_5;
            3'b101:   r_bcd = digit_6;
            3'b110:   r_bcd = digit_7;
            3'b111:   r_bcd = digit_8;
            default: r_bcd = digit_1;
        endcase
    end

endmodule

module digit_splitter #(
    parameter BIT_WIDTH = 7
) (
    input [BIT_WIDTH-1:0] counter_data,
    output [3:0] digit_1,
    output [3:0] digit_10
);
    assign digit_1  = counter_data % 10;
    assign digit_10 = (counter_data / 10) % 10;


endmodule

module counter_8 (
    input        clk,
    input        reset,
    output [1:0] sel
);
    reg [1:0] counter;
    assign sel = counter;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            //initial 
            counter <= 0;
        end else begin
            //operation
            counter <= counter + 1;
        end
    end
endmodule

module clk_div_1khz (
    input  clk,
    input  reset,
    output o_clk_1khz
);

    reg [$clog2(100000)-1:0] r_counter;  //clog로 몇비트가 필요한지 계산 후 저장(참고 베릴로그에서 지원하는 함수)
    reg r_clk_1khz;

    assign o_clk_1khz = r_clk_1khz;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter  <= 0;
            r_clk_1khz <= 1'b0;
        end else begin
            if (r_counter == 100000 - 1) begin
                r_counter  <= 0;
                r_clk_1khz <= 1'b1;
            end else begin
                r_counter  <= r_counter + 1;
                r_clk_1khz <= 1'b0;
            end
        end
    end
endmodule
