class uart_rand_sequence extends uvm_sequence #(uart_transaction);

    `uvm_object_utils(uart_rand_sequence)

    function new(string name = "");
        super.new(name);
    endfunction

    task body();
        repeat(100) begin
        uart_transaction req;

        req = uart_transaction::type_id::create("req");

        start_item(req);
        if(!req.randomize() with{
    
                data dist {
                    8'h00 :=5,
                    8'hFF :=5,
                    8'h55 :=5,
                    8'hAA :=5,

                    [8'h01:8'h54] :/ 20,
                    [8'h56:8'hA9] :/ 30,
                    [8'hAB:8'hFE] :/ 30




            };
            })`uvm_fatal("RAND","randmize fail")
        finish_item(req);

        /*bit [7:0] test_data[0:9] = '{
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
*/
end

    endtask





endclass
