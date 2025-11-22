`timescale 1ns / 1ps

module select_sel_pc (
    input  clk,    
    input  rst,
    input   digit,
    input  sel_a,  
    input  sel_m,    
    input  sw,     
    output o_mod1,
    output o_digit 
);

    reg sel_m_dly, sel_a_dly, sw_dly, digit_dly;
    reg r_mod1, r_digit;

    wire sel_a_posedge = ~sel_a_dly & sel_a;
    wire sel_a_negedge = sel_a_dly & ~sel_a;
    wire sel_m_posedge = ~sel_m_dly & sel_m;
    wire sel_m_negedge = sel_m_dly & ~sel_m;
    wire sw_posedge = ~sw_dly & sw;
    wire sw_negedge = sw_dly & ~sw;
    wire digit_posedge = ~digit_dly & digit;
    wire digit_negedge = digit_dly & ~digit;

    assign o_mod1  = r_mod1;
    assign o_digit = r_digit;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sel_m_dly <= 1'b0;
            sel_a_dly <= 1'b0;
            sw_dly <= 1'b0;
            digit_dly <= 1'b0;
            r_mod1 <= 1'b0;
            r_digit <= 1'b0;
        end else begin
            sel_m_dly <= sel_m;
            sel_a_dly <= sel_a;
            sw_dly <= sw;
            digit_dly <= digit;
            if (sel_m_posedge ||sel_m_negedge|| sw_posedge || sw_negedge) begin
                r_mod1 <= ~r_mod1;
            end
            if (sel_a_posedge ||sel_a_negedge|| digit_negedge || digit_posedge) begin
                r_digit <= ~r_digit;
            end
        end
    end

endmodule
