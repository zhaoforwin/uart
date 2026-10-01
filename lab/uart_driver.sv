class uart_driver extends uvm_driver #(uart_transaction);


    localparam int CLK_HZ  = 50_000_000;
    localparam int BIT_RATE = 9600;

    //localparam int UART_BIT_CLKS = CLK_HZ/BIT_RATE + 1;



    `uvm_component_utils(uart_driver)

    function new (string name = "uart_driver",uvm_component parent = null);
    
        super.new(name,parent);

    endfunction
        
    virtual uart_interface intf;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(virtual uart_interface)::get(
                this,
                "",
                "vif",
                intf
                ))begin
                `uvm_fatal("UART_DRIVER","virtual interface fail")
        end


    endfunction

    task driver_bit(logic data);

        @(negedge intf.clk);

        intf.uart_rxd <= data;

        repeat(UART_BIT_CLKS)
            @(posedge intf.clk);

    endtask


    task  driver_uart_byte(logic[7:0] data,output bit aborted);
        aborted = 0;
        fork : UART_OR_RESET
            begin
            driver_bit(1'b0);
        
            for (int i =0; i<8;i++)begin

                driver_bit(data[i]);

            end

            driver_bit(1'b1);
            intf.uart_rxd <= 1'b1;
            repeat(UART_BIT_CLKS)begin@(posedge intf.clk);
                end
            end

            begin
                @(negedge intf.sw_0);
                aborted = 1;
            end

        join_any

        disable UART_OR_RESET;
            if(aborted) begin
                @(negedge intf.clk);
                intf.uart_rxd <= 1'b1;

                wait(intf.sw_0 ===1'b1);
            end
        //`uvm_info("UART_DRIVER",$sformatf("finish sending data:0x%02h",data),UVM_LOW)
        repeat(UART_BIT_CLKS)
            @(posedge intf.clk);
    endtask

    task run_phase(uvm_phase phase);

        uart_transaction req;

        bit aborted;

        intf.uart_rxd <= 1'b1;


        //wait(intf.sw_0 === 1'b1);

        //@(posedge intf.clk);


        forever begin
        
        wait(intf.sw_0 === 1'b1);
        @(posedge intf.clk)
        seq_item_port.get_next_item(req);
        `uvm_info("UART_SEND","START SENDING",UVM_LOW)
        driver_uart_byte(req.data,aborted);
        if(aborted) `uvm_info("UART_DRIVER","UART transfer reset",UVM_LOW)
        else `uvm_info("UART_DRIVER",$sformatf("UART sending data:0x%02h",req.data),UVM_LOW)


               



        seq_item_port.item_done();

        end
    endtask



endclass
