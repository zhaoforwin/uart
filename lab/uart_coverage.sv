class uart_coverage extends uvm_subscriber #(uart_transaction);

    `uvm_component_utils(uart_coverage)

    bit [7:0] sample_data;

    covergroup uart_cg;

        option.per_instance = 1;

    data_cp : coverpoint sample_data {

        bins zero   = {8'h00};
        bins all_one = {8'hFF};
        bins pattern_55 = {8'h55};
        bins pattren_AA = {8'hAA};
        bins low  = {[8'h01:8'h54]};
        bins middle  = {[8'h56:8'hA9]};
        bins high  = {[8'hAB:8'hFE]};

    }
    endgroup

    function new(string name = "",uvm_component parent = "");

        super.new(name,parent);

        uart_cg = new();
    endfunction
    
    function void write(uart_transaction tr);

        sample_data = tr.data;
        uart_cg.sample();
        `uvm_info("UART_COVERAGRE",$sformatf("SAMPLE DATA = 0x%02h",tr.data),UVM_LOW)

    endfunction

    function void report_phase(uvm_phase phase);

        real coverage_value;
        super.report_phase(phase);

        coverage_value = uart_cg.get_inst_coverage();
        `uvm_info("UART_COVERAGE",$sformatf("Function coverage = %0.2f%%",
                                            coverage_value),UVM_LOW)
    endfunction
    
endclass
