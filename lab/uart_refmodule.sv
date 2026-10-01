class uart_refmodule extends uvm_component;
    `uvm_component_utils(uart_refmodule)

    uvm_analysis_imp #(uart_transaction,uart_refmodule) in_imp;
    uvm_analysis_port #(uart_transaction) out_ap;

    function new(string name = "",uvm_component parent = "");

        super.new(name,parent);
        in_imp = new("in_imp",this);
        out_ap = new("out_ap",this);
    
    endfunction

    function void write(uart_transaction tr);
        uart_transaction exp_tr;

        exp_tr = uart_transaction::type_id::create("exp_tr",this);

        exp_tr.data = tr.data;

        `uvm_info("UART_REFMODUL",$sformatf("predict output = x%02h",exp_tr.data),
                    UVM_LOW)
        out_ap.write(exp_tr);
    endfunction

endclass
