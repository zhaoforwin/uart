
typedef enum int {

    RESET_NORMAL,
    RESET_DURING_RX,
    RESET_DURING_TX

} uart_reset_kind_e;



class uart_reset_transaction extends uvm_sequence_item;
rand logic[7:0] data;
//logic is_monitor = 0;
rand int unsigned pre_delay_cycles;
rand int unsigned assert_cycles;
uart_reset_kind_e kind;


    `uvm_object_utils_begin(uart_reset_transaction)
        `uvm_field_int(data,UVM_ALL_ON)
        `uvm_field_int(pre_delay_cycles,UVM_ALL_ON)
        `uvm_field_int(assert_cycles,UVM_ALL_ON)
        `uvm_field_enum(uart_reset_kind_e,kind,UVM_ALL_ON)
       // `uvm_field_int(is_monitor,UVM_ALL_ON)
    `uvm_object_utils_end

constraint reset_c {

        assert_cycles inside {[2:100]};

    }


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
