class uart_reset_driver extends uvm_driver #(uart_reset_transaction);


    localparam int CLK_HZ  = 50_000_000;
    localparam int BIT_RATE = 9600;

    //localparam int UART_BIT_CLKS = CLK_HZ/BIT_RATE + 1;



    `uvm_component_utils(uart_reset_driver)

    uvm_analysis_port #(uart_reset_transaction) reset_ap;
    
    function new (string name = "uart_driver",uvm_component parent = null);
    
        super.new(name,parent);
        reset_ap =new("reset_ap",this);
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


    task  driver_uart_byte(logic[7:0] data);
        
        driver_bit(1'b0);

        for (int i =0; i<8;i++)begin

            driver_bit(data[i]);

        end

        driver_bit(1'b1);
        
        `uvm_info("UART_DRIVER",$sformatf("finish sending data:0x%02h",data),UVM_LOW)
        repeat(UART_BIT_CLKS)
            @(posedge intf.clk);
    endtask

    task run_phase(uvm_phase phase);

        uart_reset_transaction req;
        uart_reset_transaction evt;
  
        forever begin
            seq_item_port.get_next_item(req);
            
            repeat(req.pre_delay_cycles)@(posedge intf.clk);
            $cast(evt,req.clone());
            reset_ap.write(evt);
            @(negedge intf.clk);
            intf.sw_0 <=1'b0;
            `uvm_info("reset_DRIVER",$sformatf("RESET ASSERT,kind=%0d",req.kind),UVM_LOW)
            repeat(req.assert_cycles)@(posedge intf.clk);
            intf.sw_0 <=1'b1;
            `uvm_info("reset_DRIVER","RESET RELEASE",UVM_LOW)
            seq_item_port.item_done();


  /*intf.uart_rxd <= 1'b1;


        wait(intf.sw_0 === 1'b1);

        @(posedge intf.clk);


        forever begin

        seq_item_port.get_next_item(req);
        `uvm_info("UART_SEND","START SENDING",UVM_LOW)
        driver_uart_byte(req.data);

        `uvm_info("UART_SEND","STOP SENDING",UVM_LOW)
        



        seq_item_port.item_done();
*/
        end
    endtask



endclass
