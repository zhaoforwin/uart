class uart_reset_suite_test extends uvm_test;

     `uvm_component_utils(uart_reset_suite_test)

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
        uart_normal_reset_sequence n_seq;
        uart_reset_duringrx_sequence r_seq;
        uart_reset_duringtx_sequence t_seq;
        super.run_phase(phase);

        phase.raise_objection(this);

        n_seq = uart_normal_reset_sequence::type_id::create("n_seq");
        r_seq = uart_reset_duringrx_sequence::type_id::create("r_seq");
        t_seq = uart_reset_duringtx_sequence::type_id::create("t_seq");
        n_seq.start(env.v_seqr);
        repeat(12*UART_BIT_CLKS)
            @(posedge intf.clk);
        
        r_seq.start(env.v_seqr);
        repeat(12*UART_BIT_CLKS)
            @(posedge intf.clk);
        
        t_seq.start(env.v_seqr);
        repeat(12*UART_BIT_CLKS)
            @(posedge intf.clk);


        phase.drop_objection(this);

    endtask

  


endclass
