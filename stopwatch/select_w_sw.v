`timescale 1ns / 1ps


module select_w_sw(
    input [23:0] sel_i_time_sw,
    input [23:0] sel_i_time_w,
    input sel,
    output [23:0] i_time
    ); 

    reg [23:0] r_i_time;

    assign i_time = r_i_time;

    always @(*) begin
        case (sel)
            1'b0: r_i_time = sel_i_time_sw; 
            1'b1: r_i_time = sel_i_time_w;
            default: r_i_time = sel_i_time_sw; 
        endcase
    end
endmodule
