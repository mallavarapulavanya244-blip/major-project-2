// Major Project 2 - UART Design using Verilog
// UART Transmitter + Receiver + Top with Loopback

module uart_tx(
    input clk,
    input rst,
    input tx_start,
    input [7:0] tx_data,
    output reg tx,
    output reg tx_done
);
    parameter CLKS_PER_BIT = 104; // 9600 baud with 1MHz clk for simulation
    parameter IDLE = 0, START = 1, DATA = 2, STOP = 3;

    reg [1:0] state = IDLE;
    reg [7:0] clk_count = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] data_reg = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            tx <= 1'b1;
            tx_done <= 1'b0;
            clk_count <= 0;
            bit_index <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    tx_done <= 1'b0;
                    clk_count <= 0;
                    bit_index <= 0;
                    if (tx_start) begin
                        data_reg <= tx_data;
                        state <= START;
                    end
                end
                START: begin
                    tx <= 1'b0;
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        state <= DATA;
                    end
                end
                DATA: begin
                    tx <= data_reg[bit_index];
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        if (bit_index < 7)
                            bit_index <= bit_index + 1;
                        else begin
                            bit_index <= 0;
                            state <= STOP;
                        end
                    end
                end
                STOP: begin
                    tx <= 1'b1;
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        tx_done <= 1'b1;
                        state <= IDLE;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule

module uart_rx(
    input clk,
    input rst,
    input rx,
    output reg [7:0] rx_data,
    output reg rx_done
);
    parameter CLKS_PER_BIT = 104;
    parameter IDLE = 0, START = 1, DATA = 2, STOP = 3;

    reg [1:0] state = IDLE;
    reg [7:0] clk_count = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] data_reg = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            rx_data <= 0;
            rx_done <= 0;
            clk_count <= 0;
            bit_index <= 0;
        end else begin
            case (state)
                IDLE: begin
                    rx_done <= 1'b0;
                    clk_count <= 0;
                    bit_index <= 0;
                    if (rx == 1'b0) // Start bit detected
                        state <= START;
                end
                START: begin
                    // Wait for middle of start bit
                    if (clk_count == (CLKS_PER_BIT-1)/2) begin
                        if (rx == 1'b0) begin
                            clk_count <= 0;
                            state <= DATA;
                        end else begin
                            state <= IDLE;
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end
                DATA: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        data_reg[bit_index] <= rx;
                        if (bit_index < 7)
                            bit_index <= bit_index + 1;
                        else begin
                            bit_index <= 0;
                            state <= STOP;
                        end
                    end
                end
                STOP: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        rx_data <= data_reg;
                        rx_done <= 1'b1;
                        state <= IDLE;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule

module uart_top(
    input clk,
    input rst,
    input tx_start,
    input [7:0] tx_data,
    output [7:0] rx_data,
    output tx_done,
    output rx_done
);
    wire tx_line;
    // Loopback: TX output connected to RX input
    uart_tx TX (.clk(clk), .rst(rst), .tx_start(tx_start), .tx_data(tx_data), .tx(tx_line), .tx_done(tx_done));
    uart_rx RX (.clk(clk), .rst(rst), .rx(tx_line), .rx_data(rx_data), .rx_done(rx_done));
endmodule
