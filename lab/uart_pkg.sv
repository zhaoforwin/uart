package uart_pkg;

    import uvm_pkg::*;

    `include "uvm_macros.svh"
    
    parameter int UART_BIT_CLKS = 5209;

    `include "uart_transaction.sv"
    `include "uart_reset_transaction.sv"
    
    `include "uart_sequence.sv"
    `include "uart_smoke_sequence.sv"
    `include "uart_rand_sequence.sv"
    `include "uart_reset_sequence.sv"

    `include "uart_coverage.sv"
    `include "uart_reset_coverage.sv"

    `include "uart_sequencer.sv"
    `include "uart_reset_sequencer.sv"
    `include "uart_virtual_sequencer.sv"

    `include "uart_driver.sv"
    `include "uart_reset_driver.sv"

    `include "uart_pas_monitor.sv"
    `include "uart_act_monitor.sv"
    `include "uart_pas_agent.sv"
    `include "uart_act_agent.sv"
    `include "uart_reset_agent.sv"

    `include "uart_normal_reset_sequence.sv"
    `include "uart_reset_duringrx_sequence.sv"
    `include "uart_reset_duringtx_sequence.sv"

    `include "uart_refmodule.sv"
    `include "uart_scoreboard.sv"
    `include "uart_env.sv"



    `include "uart_test.sv"
    `include "uart_smoke_test.sv"
    `include "uart_rand_test.sv"
    `include "uart_reset_suite_test.sv"






endpackage
