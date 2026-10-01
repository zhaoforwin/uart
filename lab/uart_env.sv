class uart_env extends uvm_env;

    `uvm_component_utils(uart_env)

    uart_act_agent a_age;
    uart_pas_agent p_age;
    uart_refmodule refm;
    uart_scoreboard scor;
    uart_coverage cov;
    uart_reset_agent rst_age;
    uart_reset_coverage rst_cov;
    uart_virtual_sequencer v_seqr;

    function new(string name = "uart_env",uvm_component parent = "");

        super.new(name,parent);

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);
        p_age = uart_pas_agent::type_id::create("p_age",this);
        a_age = uart_act_agent::type_id::create("a_age",this);
        refm = uart_refmodule::type_id::create("refm",this);
        scor = uart_scoreboard::type_id::create("scor",this);
        cov = uart_coverage::type_id::create("cov",this);
        rst_age = uart_reset_agent::type_id::create("rst_age",this);
        rst_cov = uart_reset_coverage::type_id::create("rst_cov",this);
        v_seqr = uart_virtual_sequencer::type_id::create("v_seqr",this);
        

    endfunction

    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);
        a_age.a_moni.am_ap.connect(refm.in_imp);
        refm.out_ap.connect(scor.exp_imp);
        p_age.p_moni.pm_ap.connect(scor.act_imp);
        a_age.a_moni.am_ap.connect(cov.analysis_export);

        rst_age.dri.reset_ap.connect(scor.reset_imp);
        rst_age.dri.reset_ap.connect(rst_cov.analysis_export);
        v_seqr.uart_seqr = a_age.seqr;
        v_seqr.reset_seqr = rst_age.seqr;

    endfunction

endclass
