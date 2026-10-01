class uart_reset_sequencer extends uvm_sequencer #(uart_reset_transaction);

    `uvm_component_utils(uart_reset_sequencer)

    function new(string name = "uart_sequencer",uvm_component parent = null);

        super.new(name,parent);

    endfunction




endclass
