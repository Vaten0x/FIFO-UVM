class fifo_scoreboard extends uvm_scoreboard;
    
    `uvm_component_utils(fifo_scoreboard)
    
    uvm_analysis_imp#(fifo_transaction, fifo_scoreboard) analysis_export;
    
    // Reference queue - golden model
    logic [7:0] ref_queue[$];
    
    // Pending read - for synchronous FIFO (1-cycle read latency)
    logic [7:0] pending_read_data;
    bit         pending_read_valid;
    
    // Statistics
    int transactions_checked;
    int writes_performed;
    int reads_performed;
    int errors_detected;
    
    function new(string name = "fifo_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        transactions_checked = 0;
        writes_performed = 0;
        reads_performed = 0;
        errors_detected = 0;
        pending_read_valid = 0;
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "Build phase", UVM_MEDIUM)
        analysis_export = new("analysis_export", this);
    endfunction
    
    virtual function void write(fifo_transaction trans);
        transactions_checked++;
        
        `uvm_info(get_type_name(), 
                  $sformatf("Received transaction #%0d: wr_en=%0b rd_en=%0b wr_data=0x%0h rd_data=0x%0h empty=%0b full=%0b",
                           transactions_checked, trans.wr_en, trans.rd_en, 
                           trans.wr_data, trans.rd_data, trans.empty, trans.full),
                  UVM_HIGH)
        
        // CHECK PENDING READ FROM PREVIOUS CYCLE
        // (Synchronous FIFO has 1-cycle read latency)
        if (pending_read_valid) begin
            if (trans.rd_data === pending_read_data) begin
                `uvm_info(get_type_name(), 
                          $sformatf("Read: PASS - rd_data=0x%0h matches expected=0x%0h",
                                   trans.rd_data, pending_read_data),
                          UVM_HIGH)
            end
            else begin
                `uvm_error(get_type_name(), 
                          $sformatf("Read: FAIL - rd_data=0x%0h does NOT match expected=0x%0h",
                                   trans.rd_data, pending_read_data))
                errors_detected++;
            end
            pending_read_valid = 0;  // Clear pending read
        end
        
        // WRITE OPERATION
        if (trans.wr_en && !trans.full) begin
            ref_queue.push_back(trans.wr_data);
            writes_performed++;
            
            `uvm_info(get_type_name(), 
                      $sformatf("Write: Stored 0x%0h in ref_queue. Queue size now: %0d", 
                               trans.wr_data, ref_queue.size()),
                      UVM_HIGH)
        end
        else if (trans.wr_en && trans.full) begin
            `uvm_info(get_type_name(), "Write attempted but FIFO full (expected behavior)", UVM_HIGH)
        end
        
        // READ OPERATION - Set up pending read for NEXT cycle
        if (trans.rd_en && !trans.empty) begin
            if (ref_queue.size() == 0) begin
                `uvm_error(get_type_name(), 
                          "Read occurred but ref_queue is empty! Model mismatch!")
                errors_detected++;
            end
            else begin
                // Pop from queue and save for checking NEXT cycle
                pending_read_data = ref_queue.pop_front();
                pending_read_valid = 1;
                reads_performed++;
                
                `uvm_info(get_type_name(), 
                          $sformatf("Read: Expecting 0x%0h on NEXT cycle. Queue size now: %0d",
                                   pending_read_data, ref_queue.size()),
                          UVM_HIGH)
            end
        end
        else if (trans.rd_en && trans.empty) begin
            `uvm_info(get_type_name(), "Read attempted but FIFO empty (expected behavior)", UVM_HIGH)
        end
        
    endfunction
    
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        
        `uvm_info(get_type_name(), "========================================", UVM_LOW)
        `uvm_info(get_type_name(), "       SCOREBOARD FINAL REPORT         ", UVM_LOW)
        `uvm_info(get_type_name(), "========================================", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Transactions checked: %0d", transactions_checked), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Writes performed:     %0d", writes_performed), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Reads performed:      %0d", reads_performed), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Errors detected:      %0d", errors_detected), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Final queue size:     %0d", ref_queue.size()), UVM_LOW)
        
        if (pending_read_valid) begin
            `uvm_warning(get_type_name(), "Pending read was not checked - simulation may have ended early")
        end
        
        if (errors_detected == 0) begin
            `uvm_info(get_type_name(), "*** TEST PASSED - No errors detected! ***", UVM_LOW)
        end
        else begin
            `uvm_error(get_type_name(), $sformatf("*** TEST FAILED - %0d errors detected! ***", errors_detected))
        end
        `uvm_info(get_type_name(), "========================================", UVM_LOW)
    endfunction
    
endclass