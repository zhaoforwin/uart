class uart_act_monitor extends uvm_monitor;

 //   localparam int UART_BIT_CLKS = 5209;

    `uvm_component_utils(uart_act_monitor)

    virtual uart_interface intf;
    uvm_analysis_port #(uart_transaction) am_ap;

    function new(string name ="",uvm_component parent);

        super.new(name,parent);
        am_ap = new("am_ap",this);

    endfunction



    function void build_phase(uvm_phase phase);
        
        super.build_phase(phase);
        if(!uvm_config_db #(virtual uart_interface)::get(
                                this,
                                "",
                                "vif",
                                intf
                                ))begin
                `uvm_fatal("MONITOR CONFIG","interface config error")
                                end


    endfunction



    task run_phase(uvm_phase phase);

        logic[7:0] rx_data;

        bit frame_done;

        bit reset_hit;

        uart_transaction tr;
        tr = uart_transaction::type_id::create("tr");
        //wait(intf.sw_0 === 1'b1);

        forever begin

            wait(intf.sw_0 === 1'b1);
            wait(intf.uart_rxd === 1'b1);
            frame_done = 0;
            reset_hit = 0;

            @(negedge intf.uart_rxd);
            `uvm_info("UART_MONITOR","UART start bit detected",UVM_LOW)
            
           // repeat(UART_BIT_CLKS/2)
             //   @(posedge intf.clk);

            fork : MONITOR_OR_RESET
                begin
                    capture_frame(rx_data);
                    frame_done = 1;
                end

                begin
                    @(negedge intf.sw_0);
                    reset_hit = 1;
                end
            join_any

            disable MONITOR_OR_RESET;
                if(reset_hit)begin
                    `uvm_info(
                            "UART_ACT_MON",
                            "RX frame aborted by reset",
                            UVM_LOW)
                    wait(intf.sw_0 === 1'b1);
                    wait(intf.uart_rxd === 1'b1);
                    @(posedge intf.clk);
                    continue;
                end else begin
                    tr.data = rx_data;
                            `uvm_info(
                            "UART_ACT_MON",
                            $sformatf("Rceived:0x%02h",tr.data),
                            UVM_LOW)
                    am_ap.write(tr);
                end
            end
    endtask

    task capture_frame(output logic [7:0]rx_data);

        //@(negedge intf.uart_rxd);
        repeat(UART_BIT_CLKS /2)
            @(posedge intf.clk);
            if(intf.uart_rxd !==1'b0)begin
                    //`uvm_error("UVM_MONITOR","Invalid UART start bit")
                    return;
            end

            for(int i = 0;i<8;i++)begin
                    repeat(UART_BIT_CLKS)
                        @(posedge intf.clk);
                    rx_data[i] = intf.uart_rxd;
            end

            repeat(UART_BIT_CLKS)
                    @(posedge intf.clk);

            if(intf.uart_rxd !== 1'b1)begin
                   // `uvm_error("UVM_MONITOR","INVALID STOP UART BIT")
            end


    endtask





endclass
