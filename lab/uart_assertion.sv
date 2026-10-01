module uart_assertion #(

    parameter integer UART_BIT_CLKS   = 5209,
    parameter integer MIN_RESET_CLKS  = 2,
    parameter [7:0]   RESET_LED_VALUE = 8'hF0

)(
    input logic       clk,
    input logic       sw_0,

    input logic       uart_rxd,
    input logic       uart_txd,

    input logic [7:0] led
);


    import uvm_pkg::*;
    `include "uvm_macros.svh"


    //---------------------------------------------------------
    // UART timing
    //
    // UART frame:
    //
    // start + 8 data + stop
    //
    // start edge -> stop center
    //
    // = 9.5 UART bits
    //---------------------------------------------------------

    localparam integer HALF_BIT_CLKS =
        UART_BIT_CLKS / 2;

    localparam integer STOP_CENTER_CLKS =
        9 * UART_BIT_CLKS + HALF_BIT_CLKS;

    //---------------------------------------------------------
    // RX/TX frame tracking
    //
    // 目的：
    // 只把真正的一帧开始识别成start，
    // 避免把data中的1->0误认为新的start。
    //---------------------------------------------------------

    logic rx_prev;
    logic tx_prev;

    logic rx_busy;
    logic tx_busy;

    integer rx_count;
    integer tx_count;


    //---------------------------------------------------------
    // Start event
    //
    // 必须满足：
    //
    // 1. 当前不在frame中
    // 2. 上一个采样值为1
    // 3. 当前变成0
    //---------------------------------------------------------

    wire rx_start_event;

    wire tx_start_event;


    assign rx_start_event =
        sw_0 &&
        !rx_busy &&
        (rx_prev === 1'b1) &&
        (uart_rxd === 1'b0);


    assign tx_start_event =
        sw_0 &&
        !tx_busy &&
        (tx_prev === 1'b1) &&
        (uart_txd === 1'b0);



    //---------------------------------------------------------
    // Initial
    //---------------------------------------------------------

    initial begin

        rx_prev  = 1'b1;
        tx_prev  = 1'b1;

        rx_busy  = 1'b0;
        tx_busy  = 1'b0;

        rx_count = 0;
        tx_count = 0;

    end



    //---------------------------------------------------------
    // UART frame tracker
    //---------------------------------------------------------

    always @(posedge clk) begin

        //-----------------------------------------------------
        // Reset
        //-----------------------------------------------------

        if(!sw_0) begin

            rx_prev <= 1'b1;
            tx_prev <= 1'b1;

            rx_busy <= 1'b0;
            tx_busy <= 1'b0;

            rx_count <= 0;
            tx_count <= 0;

        end


        else begin

            //-------------------------------------------------
            // 保存上一个电平
            //-------------------------------------------------

            rx_prev <= uart_rxd;
            tx_prev <= uart_txd;


            //-------------------------------------------------
            // RX frame tracking
            //-------------------------------------------------

            if(rx_start_event) begin

                rx_busy <= 1'b1;

                rx_count <=
                    STOP_CENTER_CLKS;

            end


            else if(rx_busy) begin

                if(rx_count <= 1) begin

                    rx_busy <= 1'b0;

                    rx_count <= 0;

                end

                else begin

                    rx_count <=
                        rx_count - 1;

                end

            end



            //-------------------------------------------------
            // TX frame tracking
            //-------------------------------------------------

            if(tx_start_event) begin

                tx_busy <= 1'b1;

                tx_count <=
                    STOP_CENTER_CLKS;

            end


            else if(tx_busy) begin

                if(tx_count <= 1) begin

                    tx_busy <= 1'b0;

                    tx_count <= 0;

                end

                else begin

                    tx_count <=
                        tx_count - 1;

                end

            end

        end

    end



    //=========================================================
    //
    // ASSERTION 1
    //
    // Reset至少保持MIN_RESET_CLKS个clock
    //
    //=========================================================

    property p_reset_min_width;

        @(posedge clk)

        $fell(sw_0)

        |->

        (!sw_0)[*MIN_RESET_CLKS];

    endproperty


    A_RESET_MIN_WIDTH:

    assert property(
        p_reset_min_width
    )

    else begin

        `uvm_error(
            "UART_SVA_RESET_WIDTH",
            "Reset pulse is too short"
        )

    end



    //=========================================================
    //
    // ASSERTION 2
    //
    // Reset assert以后：
    //
    // 下一clock TX必须回到UART idle = 1
    //
    // 使用|=>而不是|->
    //
    // 因为DUT可能使用同步reset。
    //
    //=========================================================

    property p_reset_txd_idle;

        @(posedge clk)

        $fell(sw_0)

        |=>>

        (uart_txd === 1'b1);

    endproperty


    A_RESET_TXD_IDLE:

    assert property(
        p_reset_txd_idle
    )

    else begin

        `uvm_error(
            "UART_SVA_RESET_TX",
            "uart_txd did not return to idle after reset"
        )

    end



    //=========================================================
    //
    // ASSERTION 3
    //
    // Reset以后LED恢复8'hF0
    //
    //=========================================================

    property p_reset_led_value;

        @(posedge clk)

        $fell(sw_0)

        |=>>

        (led === RESET_LED_VALUE);

    endproperty


    A_RESET_LED:

    assert property(
        p_reset_led_value
    )

    else begin

        `uvm_error(
            "UART_SVA_RESET_LED",
            $sformatf(
                "LED reset value error, led=0x%02h expected=0x%02h",
                led,
                RESET_LED_VALUE
            )
        )

    end



    //=========================================================
    //
    // ASSERTION 4
    //
    // Reset已经持续至少一个clock后，
    // DUT输出必须保持reset状态。
    //
    //=========================================================

    property p_reset_hold;

        @(posedge clk)

        (
            !sw_0 &&
            $past(!sw_0)
        )

        |->

        (
            uart_txd === 1'b1
            &&
            led === RESET_LED_VALUE
        );

    endproperty


    A_RESET_HOLD:

    assert property(
        p_reset_hold
    )

    else begin

        `uvm_error(
            "UART_SVA_RESET_HOLD",
            "DUT output changed while reset was asserted"
        )

    end



    //=========================================================
    //
    // ASSERTION 5
    //
    // Reset释放以后，DUT输出不允许X/Z
    //
    //=========================================================

    property p_output_known;

        @(posedge clk)

        sw_0

        |->

        !$isunknown({
            uart_txd,
            led
        });

    endproperty


    A_OUTPUT_KNOWN:

    assert property(
        p_output_known
    )

    else begin

        `uvm_error(
            "UART_SVA_X_CHECK",
            "X/Z detected on DUT output"
        )

    end



    //=========================================================
    //
    // ASSERTION 6
    //
    // RX START bit检查
    //
    // 检测到下降沿后，
    // 半个UART bit之后必须仍然为0。
    //
    // 如果只是一根很短的glitch，
    // 这里就会失败。
    //
    //=========================================================

    property p_rx_start_bit;

        @(posedge clk)

        disable iff(!sw_0)

        rx_start_event

        |->

        ##HALF_BIT_CLKS

        (uart_rxd === 1'b0);

    endproperty


    A_RX_START_BIT:

    assert property(
        p_rx_start_bit
    )

    else begin

        `uvm_error(
            "UART_SVA_RX_START",
            "Invalid RX start bit"
        )

    end



    //=========================================================
    //
    // ASSERTION 7
    //
    // RX STOP bit检查
    //
    // start下降沿之后：
    //
    // 9.5 bit
    //
    // 应处于STOP bit中心。
    //
    //=========================================================

    property p_rx_stop_bit;

        @(posedge clk)

        disable iff(!sw_0)

        rx_start_event

        |->

        ##STOP_CENTER_CLKS

        (uart_rxd === 1'b1);

    endproperty


    A_RX_STOP_BIT:

    assert property(
        p_rx_stop_bit
    )

    else begin

        `uvm_error(
            "UART_SVA_RX_STOP",
            "Invalid RX stop bit"
        )

    end



    //=========================================================
    //
    // ASSERTION 8
    //
    // TX START bit检查
    //
    //=========================================================

    property p_tx_start_bit;

        @(posedge clk)

        disable iff(!sw_0)

        tx_start_event

        |->

        ##HALF_BIT_CLKS

        (uart_txd === 1'b0);

    endproperty


    A_TX_START_BIT:

    assert property(
        p_tx_start_bit
    )

    else begin

        `uvm_error(
            "UART_SVA_TX_START",
            "Invalid TX start bit"
        )

    end



    //=========================================================
    //
    // ASSERTION 9
    //
    // TX STOP bit检查
    //
    //=========================================================

    property p_tx_stop_bit;

        @(posedge clk)

        disable iff(!sw_0)

        tx_start_event

        |->

        ##STOP_CENTER_CLKS

        (uart_txd === 1'b1);

    endproperty


    A_TX_STOP_BIT:

    assert property(
        p_tx_stop_bit
    )

    else begin

        `uvm_error(
            "UART_SVA_TX_STOP",
            "Invalid TX stop bit"
        )

    end



    //=========================================================
    //
    // ASSERTION 10
    //
    // RX收到一帧以后，
    // DUT必须在合理时间内启动TX回传。
    //
    // 当前DUT是UART loopback：
    //
    // uart_rxd
    //   ↓
    // uart_rx
    //   ↓
    // valid/data
    //   ↓
    // uart_tx
    //   ↓
    // uart_txd
    //
    // RX一帧约10 bit。
    //
    // 因此从RX start到TX start，
    // 给9~12个bit的窗口。
    //
    //=========================================================

    localparam integer LOOPBACK_MIN_CLKS =
        9 * UART_BIT_CLKS;

    localparam integer LOOPBACK_MAX_CLKS =
        12 * UART_BIT_CLKS;


    property p_rx_to_tx_response;

        @(posedge clk)

        disable iff(!sw_0)

        rx_start_event

        |->

        ##[
            LOOPBACK_MIN_CLKS:
            LOOPBACK_MAX_CLKS
        ]

        tx_start_event;

    endproperty


    A_RX_TO_TX_RESPONSE:

    assert property(
        p_rx_to_tx_response
    )

    else begin

        `uvm_error(
            "UART_SVA_LOOPBACK",
            "RX frame was not followed by TX response"
        )

    end



    //=========================================================
    //
    // COVER PROPERTY
    //
    // 这些不是assert。
    //
    // 它们用于证明验证场景确实发生过。
    //
    //=========================================================


    //---------------------------------------------------------
    // 至少发生一次Reset
    //---------------------------------------------------------

    C_RESET:

    cover property(
        @(posedge clk)

        $fell(sw_0)
    );



    //---------------------------------------------------------
    // 至少发生一个完整RX frame start
    //---------------------------------------------------------

    C_RX_FRAME:

    cover property(
        @(posedge clk)

        rx_start_event
    );



    //---------------------------------------------------------
    // 至少发生一个TX frame
    //---------------------------------------------------------

    C_TX_FRAME:

    cover property(
        @(posedge clk)

        tx_start_event
    );



    //---------------------------------------------------------
    // Reset During RX
    //---------------------------------------------------------

    C_RESET_DURING_RX:

    cover property(
        @(posedge clk)

        $fell(sw_0)
        &&
        $past(rx_busy)
    );



    //---------------------------------------------------------
    // Reset During TX
    //---------------------------------------------------------

    C_RESET_DURING_TX:

    cover property(
        @(posedge clk)

        $fell(sw_0)
        &&
        $past(tx_busy)
    );


endmodule
