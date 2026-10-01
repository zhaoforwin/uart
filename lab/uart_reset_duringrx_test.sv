class uart_reset_duringrx_test extends uvm_test;

    `uvm_component_utils(uart_reset_duringrx_test)

    function new(string name="uart_test",uvm_component parent);

        super.new(name,parent);

    endfunction

    uart_env env;

    virtual uart_interface intf;

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);
        env = uart_env::type_id::create("env",this);
        if(!uvm_config_db #(virtual uart_interface)::get(
                this,
                "",
                "vif",
                intf))begin
            `uvm_fatal("UART_TEST","interface config fail")
        
                end

    endfunction


    task run_phase(uvm_phase phase);

        //uart_sequence seq;
        uart_reset_duringrx_sequence seq;
        super.run_phase(phase);

        phase.raise_objection(this);

        seq = uart_normal_reset_duringrx_sequence::type_id::create("seq");
        seq.start(env.v_seqr);
        repeat(12*UART_BIT_CLKS)
            @(posedge intf.clk);


        phase.drop_objection(this);

    endtask

endclass
