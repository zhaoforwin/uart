class uart_virtual_sequencer extends uvm_sequencer;

    `uvm_component_utils(uart_virtual_sequencer)

    uart_sequencer  uart_seqr;
    uart_reset_sequencer reset_seqr;


    function new(string name,uvm_component parent);

        super.new(name,parent);
    endfunction





endclass
