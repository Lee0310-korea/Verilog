`timescale 1ns / 1ps

module cummand_cu (
    input        clk,
    input        rst,
    input        rx_trigger,
    input  [7:0] rx_fifo_data,
    output       o_start,
    output       o_stop,
    output       o_clear,
    output       o_hour_p,
    output       o_min_p,
    output       o_sec_p,
    output       o_sel_m,
    output       o_sel_a
);

    reg r_mode,r_digit;

    assign o_start  = ~rx_trigger && (rx_fifo_data == 8'h73); // 's'
    assign o_stop   = ~rx_trigger && (rx_fifo_data == 8'h74); // 't'
    assign o_clear  = ~rx_trigger && (rx_fifo_data == 8'h63); // 'c'
    assign o_hour_p = ~rx_trigger && (rx_fifo_data == 8'h48); // 'H'
    assign o_min_p  = ~rx_trigger && (rx_fifo_data == 8'h4D); // 'M'
    assign o_sec_p  = ~rx_trigger && (rx_fifo_data == 8'h53); // 'S'

    assign o_sel_m = r_mode;
    assign o_sel_a = r_digit; 

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r_mode  <= 1'b0;
            r_digit <= 1'b0;
        end else begin
            if (~rx_trigger) begin
                case (rx_fifo_data)
                    8'h6D: r_mode  <= ~r_mode;   // 'm'
                    8'h61: r_digit  <= ~r_digit; // 'a' 
                endcase
            end
        end
    end
endmodule
