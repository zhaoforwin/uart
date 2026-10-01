interface uart_interface#(
parameter int CYCLES_PER_BIT = 5208)(
input logic clk
);

logic sw_0;
logic sw_1;
logic uart_rxd;
logic uart_txd;
logic[7:0] led;

clocking driver_cb @(posedge clk);
    default output #1;
    output uart_rxd;
    output sw_1;
    output sw_0;

endclocking

clocking monitor_cb @(posedge clk);
    default input #1step;
    input uart_txd;
    input uart_rxd;
    input sw_0;
    input led;


endclocking


endinterface
