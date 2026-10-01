class uart_reset_sequence extends uvm_sequence#(uart_reset_transaction);

    `uvm_object_utils(uart_reset_sequence) 

    int unsigned pre_delay_cycles = 0;
    int unsigned assert_cycles = 10;
    uart_reset_kind_e kind = RESET_NORMAL;

    function new(string name = "");
        super.new(name);
    endfunction

    task body();

        uart_reset_transaction req;

        req = uart_reset_transaction::type_id::create("req");

        start_item(req);

        req.pre_delay_cycles = pre_delay_cycles;
        req.assert_cycles = assert_cycles;
        req.kind = kind;

        finish_item(req);
        `uvm_info("RESET_SEQ",$sformatf("kind=%0d,pre_delay=%d,assert_cycles=%0d",req.kind,req.pre_delay_cycles,req.assert_cycles),UVM_LOW)

    endtask







endclass
