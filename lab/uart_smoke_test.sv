class uart_smoke_test extends uvm_test;

    `uvm_component_utils(uart_smoke_test)

    function new(string name ="",uvm_component parent="");
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
                            intf))
            `uvm_fatal("UART_SMOKE_TEST","TEST INTERFACE CONFIG FAIL")
        

    endfunction

    task run_phase(uvm_phase phase);

        uart_smoke_sequence seq;
        phase.raise_objection(this);

        seq = uart_smoke_sequence::type_id::create("seq");
        
        `uvm_info("UART_SMOKE_TEST","start uart directed test",UVM_LOW)

        seq.start(env.a_age.seqr);
            repeat(60_000)@(posedge intf.clk);

        `uvm_info("UART_SMOKE_TEST","smke test finished",UVM_LOW)

        phase.drop_objection(this);



    endtask

endclass
