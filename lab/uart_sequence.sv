class uart_sequence extends uvm_sequence #(uart_transaction);

    `uvm_object_utils(uart_sequence) 

    function new(string name = "");
        super.new(name);
    endfunction
    logic [7:0] data_value = 8'hA5;

    task body();

        uart_transaction req;

        req = uart_transaction::type_id::create("req");

        start_item(req);

        req.data = data_value;

        finish_item(req);

        `uvm_info("UART_SET_DATA",$sformatf("send data = 0x%02h",req.data),UVM_LOW)

    endtask







endclass
