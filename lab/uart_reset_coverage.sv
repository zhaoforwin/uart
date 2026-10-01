class uart_reset_coverage extends uvm_subscriber #(uart_reset_transaction);

    `uvm_component_utils(uart_reset_coverage)

    uart_reset_kind_e sample_kind;

    covergroup reset_cg;
        option.per_instance = 1;

    kind_cp : coverpoint sample_kind {

        bins normal   = {RESET_NORMAL};
        bins during_rx = {RESET_DURING_RX};
        bins during_tx = {RESET_DURING_TX};
  /*      bins pattren_AA = {8'hAA};
        bins low  = {[8'h01:8'h54]};
        bins middle  = {[8'h56:8'hA9]};
        bins high  = {[8'hAB:8'hFE]};
*/
    }
    endgroup

    function new(string name = "",uvm_component parent = "");

        super.new(name,parent);

        reset_cg = new();
    endfunction
    
    function void write(uart_reset_transaction tr);

        sample_kind = tr.kind;
        reset_cg.sample();
        `uvm_info("UART_COVERAGRE",$sformatf("SAMPLE DATA = 0x%02h",tr.data),UVM_LOW)

    endfunction

    function void report_phase(uvm_phase phase);

        real coverage_value;
        super.report_phase(phase);

        coverage_value = reset_cg.get_inst_coverage();
        `uvm_info("UART_COVERAGE",$sformatf("Function coverage = %0.2f%%",
                                            coverage_value),UVM_LOW)
    
        `uvm_info("UART_COVERAGE",$sformatf("KIND = %0d",sample_kind),UVM_LOW)
    endfunction
    
endclass
