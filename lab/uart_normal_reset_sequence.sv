class uart_normal_reset_sequence extends uvm_sequence;

    `uvm_object_utils(uart_normal_reset_sequence) 
    `uvm_declare_p_sequencer(uart_virtual_sequencer)

    /*int unsigned pre_delay_cycles = 0;
    int unsigned assert_cysles = 10;
    uart_reset_kind_e kind = RESET_NORMAL;
*/
    function new(string name = "");
        super.new(name);
    endfunction

    task body();

        uart_reset_sequence rst_seq;
        uart_sequence uart_seq;

        rst_seq = uart_reset_sequence::type_id::create("rst_seq");
        uart_seq = uart_sequence::type_id::create("uart_seq");

        rst_seq.kind = RESET_NORMAL;
        rst_seq.pre_delay_cycles = 0;
        rst_seq.assert_cycles = 10;


        rst_seq.start(p_sequencer.reset_seqr);

        uart_seq.data_value = 8'hA5;

        uart_seq.start(p_sequencer.uart_seqr);
       
        
    endtask







endclass
