`timescale 1ns / 1ps

module stopwatch_cu (
    input  clk,
    input  rst,
    input  i_stop,
    input  i_run,
    input  i_clear,
    output o_run,
    output o_clear,
    output o_stop

);

    // state define 
    parameter STOP = 2'b00, RUN = 2'b01, CLEAR = 2'b10;
    reg [1:0] c_state, n_state;
    reg run_reg, run_next;
    reg clear_reg, clear_next;
    reg stop_reg, stop_next;

    assign o_run   = run_reg;
    assign o_clear = clear_reg;
    assign o_stop  = stop_reg;

    // state register SL
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state   <= STOP;
            run_reg   <= 1'b0;
            clear_reg <= 1'b0;
            stop_reg  <= 1'b0;
        end else begin
            c_state   <= n_state;
            run_reg   <= run_next;
            clear_reg <= clear_next;
            stop_reg  <= stop_next;
        end
    end

    // next combinational logic
    always @(*) begin
        n_state = c_state;
        run_next = run_reg;
        clear_next = clear_reg;
        stop_next = stop_reg;
            case (c_state)
                STOP: begin
                    // moore output
                    clear_next = 1'b0;
                    run_next= 1'b0;
                    stop_next = 1'b1;
                    // next state 
                    if (i_run) begin
                        n_state = RUN;
                    end else if (i_clear) begin
                        n_state = CLEAR;
                    end
                end
                RUN: begin
                    run_next = 1'b1;
                    clear_next = 1'b0;
                    stop_next = 1'b0;
                    if (i_stop) begin
                        n_state = STOP;
                    end else if (i_clear) begin
                        n_state = CLEAR;
                    end
                end
                CLEAR: begin
                    run_next = 1'b0;
                    clear_next = 1'b1;
                    stop_next = 1'b0;
                    n_state = STOP;
                end
            endcase
        end
    //output logic


endmodule

