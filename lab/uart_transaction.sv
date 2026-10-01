class uart_transaction extends uvm_sequence_item;
rand logic[7:0] data;
//logic is_monitor = 0;


    `uvm_object_utils_begin(uart_transaction)
        `uvm_field_int(data,UVM_ALL_ON)
       // `uvm_field_int(is_monitor,UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "");
        super.new(name);
    endfunction

 /*   virtual function string conver2string();
        return $sformatf("data=0x%02h (%0d) %s",
                            data,data,
                            is_monitor?"[RX FROM DUT]" : "[TX TO DUT]");


    endfunction

*/
endclass
