bind impl_top uart_assertion #(

    .UART_BIT_CLKS   (5209),
    .MIN_RESET_CLKS  (2),
    .RESET_LED_VALUE (8'hF0)

) u_uart_assertion (

    .clk       (clk),

    .sw_0      (sw_0),

    .uart_rxd  (uart_rxd),

    .uart_txd  (uart_txd),

    .led       (led)

);