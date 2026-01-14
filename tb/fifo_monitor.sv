class fifo_monitor extends uvm_monitor;
    
    // Register with factory
    `uvm_component_utils(fifo_monitor)
    
    // Virtual interface
    virtual fifo_if vif;
    
    // Analysis port - sends transactions to scoreboard
    uvm_analysis_port#(fifo_transaction) analysis_port;
    
    // Constructor
    function new(string name = "fifo_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase - get interface and create analysis port
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        `uvm_info(get_type_name(), "Build phase", UVM_HIGH)
        
        // Get interface from config_db
        if (!uvm_config_db#(virtual fifo_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "Virtual interface not found in config_db!")
        end
        
        // Create analysis port
        analysis_port = new("analysis_port", this);
    endfunction
    
    // Run phase - observe DUT and send transactions
    task run_phase(uvm_phase phase);
        fifo_transaction trans;
        
        // Wait for reset
        wait(vif.reset_n);
        `uvm_info(get_type_name(), "Reset deasserted, starting to monitor", UVM_MEDIUM)
        
        forever begin
            // Create new transaction for this observation
            trans = fifo_transaction::type_id::create("trans");
            
            // Sample DUT signals using monitor clocking block
            @(vif.monitor_cb);
            
            // Capture inputs (what was requested)
            trans.wr_en = vif.monitor_cb.wr_en;
            trans.rd_en = vif.monitor_cb.rd_en;
            trans.wr_data = vif.monitor_cb.wr_data;
            
            // Capture outputs (what DUT responded with)
            trans.rd_data = vif.monitor_cb.rd_data;
            trans.full = vif.monitor_cb.full;
            trans.empty = vif.monitor_cb.empty;
            trans.almost_full = vif.monitor_cb.almost_full;
            trans.almost_empty = vif.monitor_cb.almost_empty;
            
            // Send transaction to scoreboard via analysis port
            `uvm_info(get_type_name(), 
                      $sformatf("Observed: wr_en=%0b rd_en=%0b wr_data=0x%0h | rd_data=0x%0h full=%0b empty=%0b",
                               trans.wr_en, trans.rd_en, trans.wr_data, 
                               trans.rd_data, trans.full, trans.empty), 
                      UVM_HIGH)
            
            analysis_port.write(trans);
        end
    endtask
    
endclass