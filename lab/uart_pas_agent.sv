class uart_pas_agent extends uvm_agent;

    `uvm_component_utils(uart_pas_agent)
    function new(string name = "uart_agnet",uvm_component parent);

        super.new(name,parent);

    endfunction

    uart_sequencer seqr;
    //uart_driver dri;
    uart_pas_monitor p_moni;

    function void build_phase(uvm_phase phase);
            
        super.build_phase(phase);
        seqr = uart_sequencer::type_id::create("seqr",this);
      //  dri = uart_driver::type_id::create("dri",this);
        p_moni = uart_pas_monitor::type_id::create("moni",this);

    endfunction

    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);
        //dri.seq_item_port.connect(seqr.seq_item_export);


    endfunction


endclass
