class fifo_scoreboard extends uvm_scoreboard;
    
    // Register with factory
    `uvm_component_utils(fifo_scoreboard)
    
    // Analysis port to receive transactions from monitor
    uvm_analysis_imp#(fifo_transaction, fifo_scoreboard) analysis_export;
    
    // Reference queue - your golden model!
    logic [7:0] ref_queue[$];
    
    // Statistics
    int transactions_checked;
    int writes_performed;
    int reads_performed;
    int errors_detected;
    
    // Constructor
    function new(string name = "fifo_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        transactions_checked = 0;
        writes_performed = 0;
        reads_performed = 0;
        errors_detected = 0;
    endfunction
    
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        `uvm_info(get_type_name(), "Build phase", UVM_MEDIUM)
        
        // Create analysis export
        analysis_export = new("analysis_export", this);
    endfunction
    
    // Write function - called by monitor for each transaction
    // This is where ALL your checking logic goes!
    virtual function void write(fifo_transaction trans);
        transactions_checked++;
        
        `uvm_info(get_type_name(), 
                  $sformatf("Received transaction #%0d: wr_en=%0b rd_en=%0b wr_data=0x%0h rd_data=0x%0h empty=%0b full=%0b",
                           transactions_checked, trans.wr_en, trans.rd_en, 
                           trans.wr_data, trans.rd_data, trans.empty, trans.full),
                  UVM_HIGH)
        
        // WRITE OPERATION
        if (trans.wr_en && !trans.full) begin
            // Store data in reference queue
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
        
        // READ OPERATION
        if (trans.rd_en && !trans.empty) begin
            logic [7:0] expected_data;
            
            if (ref_queue.size() == 0) begin
                `uvm_error(get_type_name(), 
                          "Read occurred but ref_queue is empty! Model mismatch!")
                errors_detected++;
            end
            else begin
                // Get expected data from reference queue
                expected_data = ref_queue.pop_front();
                reads_performed++;
                
                // CRITICAL CHECK: Compare expected vs actual
                if (trans.rd_data === expected_data) begin
                    `uvm_info(get_type_name(), 
                              $sformatf("Read: PASS - rd_data=0x%0h matches expected=0x%0h. Queue size now: %0d",
                                       trans.rd_data, expected_data, ref_queue.size()),
                              UVM_HIGH)
                end
                else begin
                    `uvm_error(get_type_name(), 
                              $sformatf("Read: FAIL - rd_data=0x%0h does NOT match expected=0x%0h",
                                       trans.rd_data, expected_data))
                    errors_detected++;
                end
            end
        end
        else if (trans.rd_en && trans.empty) begin
            `uvm_info(get_type_name(), "Read attempted but FIFO empty (expected behavior)", UVM_HIGH)
        end
        
        // Sanity check: Queue size vs empty flag
        if ((ref_queue.size() == 0) && !trans.empty) begin
            `uvm_error(get_type_name(), 
                      $sformatf("Model mismatch: ref_queue empty but DUT empty flag = %0b", trans.empty))
            errors_detected++;
        end
        
    endfunction
    
    // Report phase - print statistics
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
        
        if (errors_detected == 0) begin
            `uvm_info(get_type_name(), "*** TEST PASSED - No errors detected! ***", UVM_LOW)
        end
        else begin
            `uvm_error(get_type_name(), $sformatf("*** TEST FAILED - %0d errors detected! ***", errors_detected))
        end
        `uvm_info(get_type_name(), "========================================", UVM_LOW)
    endfunction
    
endclass