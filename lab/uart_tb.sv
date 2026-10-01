`timescale 1ns/1ps

module uart_tb;


    import uvm_pkg::*;
    import uart_pkg::*;

    localparam CLK_PERIOD =20;

    logic   clk;
  //  logic   sw_0;


    initial begin 
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
    //    sw_0 = 1'b0;
        #200;
      //  sw_0 = 1'b1;
    end
 
    uart_interface u_if(
        .clk (clk)
      //  .sw_0 (sw_0)
        );

    
    impl_top #(
        .CLK_HZ (50000000),
        .BIT_RATE (9600),
        .PAYLOAD_BITS(8)
    
    )u_dut(
        .clk (clk),
        .sw_0 (u_if.sw_0),
        .sw_1 (1'b0),
        .uart_rxd (u_if.uart_rxd),
        .uart_txd (u_if.uart_txd),
        .led (u_if.led)
    );


     initial begin
        uvm_config_db#(virtual uart_interface)::set(
            null,"*","vif",u_if
            );
        end

    initial begin

        run_test("");


    end 

    initial begin
        #800_000_000;
        $display("TB TIMEOUT");
        $finish;
    end

    initial begin

        $fsdbDumpfile("uart.fsdb");
        $fsdbDumpvars(0,uart_tb);

    end

endmodule
