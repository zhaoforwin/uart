class uart_smoke_sequence extends uvm_sequence #(uart_transaction);

    `uvm_object_utils(uart_smoke_sequence)

    function new(string name = "");
        super.new(name);
    endfunction

    task body();
        uart_transaction req;

        bit [7:0] test_data[0:9] = '{
                8'h00,
                8'hFF,
                8'h55,
                8'hAA,
                8'hA5,
                8'h5A,
                8'h01,
                8'h10,
                8'h08,
                8'h80
                };

        req = uart_transaction::type_id::create("req");
        
        foreach(test_data[i])begin
            start_item(req);
            req.data = test_data[i];
            finish_item(req);
            `uvm_info("UART_SMOKE_SEQ",
            $sformatf("send data[%0d] = 0x%02h",i,req.data),
            UVM_LOW)
        end



    endtask





endclass
