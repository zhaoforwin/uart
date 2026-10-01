`uvm_analysis_imp_decl(_exp)
`uvm_analysis_imp_decl(_act)
`uvm_analysis_imp_decl(_reset)

class uart_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(uart_scoreboard)

    uvm_analysis_imp_exp #(uart_transaction,uart_scoreboard) exp_imp;
    uvm_analysis_imp_act #(uart_transaction,uart_scoreboard) act_imp;
    uvm_analysis_imp_reset #(uart_reset_transaction,uart_scoreboard) reset_imp;

    uart_transaction exp_queue[$];
    uart_transaction act_queue[$];

    int unsigned pass_count;
    int unsigned fail_count;
    int unsigned flush_count;

    function new (string name = "",uvm_component parent);
    
        super.new(name,parent);
        exp_imp = new("exp_imp",this);
        act_imp = new("act_imp",this);
        reset_imp = new("reset_imp",this);

        pass_count = 0;
        fail_count = 0;
        flush_count = 0;
     endfunction

    function void write_exp(uart_transaction tr);
        exp_queue.push_back(tr);
        `uvm_info("UART_SCOREBOARD",$sformatf("expected received:0x%02h",tr.data)
                    ,UVM_HIGH)
        compare_data();

     endfunction
    
    function void write_act(uart_transaction tr);
        act_queue.push_back(tr);
        `uvm_info("UART_SCOREBOARD",$sformatf("ACTUAL received:0x%02h",tr.data)
                    ,UVM_HIGH)
        compare_data();

     endfunction

     function void write_reset(uart_reset_transaction tr);
        exp_queue.delete();
        act_queue.delete();
        flush_count++;
        `uvm_info("UART_SCOREBOARD",
                    $sformatf("RESET FLUSH,kind = %0d",tr.kind),UVM_LOW)



     endfunction

     function void compare_data();
        uart_transaction exp_tr;
        uart_transaction act_tr;

        while (exp_queue.size()>0 && act_queue.size()>0)begin

            exp_tr = exp_queue.pop_front();
            act_tr = act_queue.pop_front();

            if(exp_tr.data === act_tr.data)begin
                pass_count++;
                `uvm_info("UART_SCOREBOARD",
                            $sformatf("Pass:expected = 0x%02h,actual = 0x%02h",
                            exp_tr.data,act_tr.data),UVM_LOW)
            end else begin
                    fail_count++;
                                `uvm_error("UART_SCOREBOARD",
                            $sformatf("Pass:expected = 0x%02h,actual = 0x%02h",
                            exp_tr.data,act_tr.data))

            end

        end


     endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        if(exp_queue.size()>0 && act_queue.size()>0)begin
            `uvm_error("UART_SCOREBOARD","remains transaction")
        end
        `uvm_info("UART_SCOREBOARD",
                        $sformatf("Pass num:%0d,fail num :%0d,flush num:%0d",
                        pass_count,fail_count,flush_count
                        ),UVM_LOW)



    endfunction

    /*function void build_phase(uvm_phase phase);


        super.build_phase(phase);
        d_fifo = new("d_fifo",this);
        m_fifo = new("m_fifo",this);

    endfunction

    task run_phase(uvm_phase phase);

        uart_transaction d_tr;
        uart_transaction m_tr;

        forever begin
            d_fifo.get(d_tr);
            m_fifo.get(m_tr);

        if(d_tr.data === m_tr.data)begin
            `uvm_info("UART_SCOREBOARD","pass successfully",UVM_LOW)
        end else begin
            
            `uvm_error("UART_SCOREBOARD",$sformatf("fail:send:0x%02h,receive:0x%02h",d_tr.data,m_tr.data))
        end
        end

    endtask

*/

endclass
