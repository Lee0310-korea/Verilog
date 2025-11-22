`timescale 1ns / 1ps

module uart_tx (
    input        clk,
    input        rst,
    input        start_trigger,
    input  [7:0] tx_data,
    input        b_tick,
    output       tx,
    output       tx_busy
);

    localparam [2:0] IDLE = 3'b000, WAIT = 3'b001, START = 3'b010;
    localparam [2:0] BIT = 3'b011, STOP = 3'b100, SEVEN = 3'b111;

    reg [2:0] state, next;
    reg tx_reg, tx_next;
    reg tx_busy_reg, tx_busy_next;
    reg [2:0] bit_count_reg, bit_count_next;
    reg [7:0] data_reg, data_next;
    reg [3:0] b_tick_count_next, b_tick_count_reg;

    assign tx = tx_reg;
    assign tx_busy = tx_busy_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state            <= IDLE;
            tx_reg           <= 1'b1;
            bit_count_reg    <= 3'b000;
            data_reg         <= 8'h00;
            tx_busy_reg      <= 1'b0;
            b_tick_count_reg <= 4'b0000;
        end else begin
            state            <= next;
            tx_reg           <= tx_next;
            bit_count_reg    <= bit_count_next;
            data_reg         <= data_next;
            tx_busy_reg      <= tx_busy_next;
            b_tick_count_reg <= b_tick_count_next;
        end
    end

    always @(*) begin
        bit_count_next    = bit_count_reg;
        next              = state;
        tx_next           = tx_reg;
        data_next         = data_reg;
        tx_busy_next      = tx_busy_reg;
        b_tick_count_next = b_tick_count_reg;
        case (state)
            IDLE: begin
                tx_next = 1'b1;
                tx_busy_next = tx_busy_reg;
                if (start_trigger == 1'b1) begin
                    data_next = tx_data;
                    tx_busy_next = 1'b1;
                    next = WAIT;
                end
            end
            WAIT: begin
                if (b_tick == 1'b1) begin
                    b_tick_count_next = 0;
                    next = START;
                end
            end
            START: begin
                tx_next = 1'b0;
                if (b_tick == 1'b1) begin
                    if (b_tick_count_reg == 15) begin
                        b_tick_count_next = 0;
                        bit_count_next = 3'b000;
                        next = BIT;
                    end else begin
                        b_tick_count_next = b_tick_count_reg + 1;
                    end

                end
            end
            BIT: begin
                tx_next = data_reg[0];
                if (b_tick == 1'b1) begin
                    if (b_tick_count_reg == 15) begin
                        b_tick_count_next = 0;
                        if (bit_count_next == SEVEN) begin
                            bit_count_next = 0;
                            next = STOP;
                        end else begin
                            b_tick_count_next = 0;
                            bit_count_next = bit_count_reg + 1;
                            data_next = data_reg >> 1;
                        end
                    end else begin
                        b_tick_count_next = b_tick_count_reg + 1;
                    end
                end
            end
            STOP: begin
                tx_next = 1'b1;
                if (b_tick == 1'b1) begin
                    if (b_tick_count_reg == 15) begin
                        tx_busy_next = 1'b0;
                        next = IDLE;
                    end else begin
                        b_tick_count_next = b_tick_count_reg + 1;
                    end
                end
            end
            default: next = IDLE;
        endcase
    end
endmodule
