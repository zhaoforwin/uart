class uart_reset_agent extends uvm_agent;

    `uvm_component_utils(uart_reset_agent)
    function new(string name = "uart_agent",uvm_component parent);

        super.new(name,parent);

    endfunction

    uart_reset_sequencer seqr;
    uart_reset_driver dri;
   // uart_act_monitor a_moni;

    function void build_phase(uvm_phase phase);
            
        super.build_phase(phase);
        seqr = uart_reset_sequencer::type_id::create("seqr",this);
        dri = uart_reset_driver::type_id::create("dri",this);
        //a_moni = uart_act_monitor::type_id::create("a_moni",this);

    endfunction

    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);
        dri.seq_item_port.connect(seqr.seq_item_export);


    endfunction


endclass
