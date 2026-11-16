// Testbench for UART - Loopback Test
`timescale 1ns/1ps
module tb_uart();
    reg clk = 0;
    reg rst = 1;
    reg tx_start = 0;
    reg [7:0] tx_data = 0;
    wire [7:0] rx_data;
    wire tx_done, rx_done;

    uart_top uut (.clk(clk), .rst(rst), .tx_start(tx_start), .tx_data(tx_data), .rx_data(rx_data), .tx_done(tx_done), .rx_done(rx_done));

    // Clock: 1MHz
    always #500 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_uart);

        $display("=== UART Loopback Test Started ===");
        #2000 rst = 0;
        #1000;

        // Test 1: Send A5
        tx_data = 8'hA5;
        tx_start = 1;
        #1000 tx_start = 0;
        wait(rx_done == 1);
        #1000;
        $display("Test 1: Sent = %h, Received = %h", 8'hA5, rx_data);
        if (rx_data == 8'hA5) $display("Test 1 PASSED");
        else $display("Test 1 FAILED");

        #2000;
        // Test 2: Send 3C
        tx_data = 8'h3C;
        tx_start = 1;
        #1000 tx_start = 0;
        wait(rx_done == 1);
        #1000;
        $display("Test 2: Sent = %h, Received = %h", 8'h3C, rx_data);
        if (rx_data == 8'h3C) $display("Test 2 PASSED");
        else $display("Test 2 FAILED");

        #2000;
        $display("=== UART Test Completed ===");
        $finish;
    end
endmodule
