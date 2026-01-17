class fifo_driver extends uvm_driver#(fifo_transaction);
    
    // Register with factory
    `uvm_component_utils(fifo_driver)
    
    // Virtual interface handle
    virtual fifo_if vif;
    
    // Constructor
    function new(string name = "fifo_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase - get interface from config_db
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Enable recording for this driver
        set_report_verbosity_level(UVM_FULL);
        
        if (!uvm_config_db#(virtual fifo_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "Virtual interface not found in config_db!")
        end
    endfunction
    
    // Run phase - this is where the action happens!
    task run_phase(uvm_phase phase);
        fifo_transaction req;
        
        // Wait for reset
        wait(vif.reset_n);
        `uvm_info(get_type_name(), "Reset deasserted, starting to drive transactions", UVM_LOW)
        
        forever begin
            // Get transaction from sequencer
            seq_item_port.get_next_item(req);

            // Record transaction start
            void'(begin_tr(req, "Driver_Transaction"));
            
            // Drive the transaction
            drive_transaction(req);

            // Record transaction end
            end_tr(req);
            
            // Tell sequencer we're done
            seq_item_port.item_done();
        end
    endtask
    
    // Task to drive a single transaction
    task drive_transaction(fifo_transaction req);
        `uvm_info(get_type_name(), 
                  $sformatf("Driving: wr_en=%0b rd_en=%0b wr_data=0x%0h", 
                           req.wr_en, req.rd_en, req.wr_data), 
                  UVM_HIGH)
        
        // Wait for clock edge
        @(vif.driver_cb);
        
        // Drive signals using clocking block - proper timing, no races!
        vif.driver_cb.wr_en <= req.wr_en;
        vif.driver_cb.wr_data <= req.wr_data;
        vif.driver_cb.rd_en <= req.rd_en;
        
        // Note: We don't drive outputs (rd_data, full, empty, etc.)
        // Those come FROM the DUT, we only observe them
    endtask
    
endclass