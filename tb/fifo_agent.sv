class fifo_agent extends uvm_agent;
    
    // Register with factory
    `uvm_component_utils(fifo_agent)
    
    // Components
    fifo_sequencer sequencer;
    fifo_driver    driver;
    // fifo_monitor   monitor;  // We'll add this later
    
    // Configuration - is this agent active or passive?
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    
    // Constructor
    function new(string name = "fifo_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase - create components
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        `uvm_info(get_type_name(), "Build phase", UVM_HIGH)
        
        // Create monitor (always created - needed for both active/passive)
        // monitor = fifo_monitor::type_id::create("monitor", this);
        
        // Create driver and sequencer only if active
        if (is_active == UVM_ACTIVE) begin
            sequencer = fifo_sequencer::type_id::create("sequencer", this);
            driver = fifo_driver::type_id::create("driver", this);
        end
    endfunction
    
    // Connect phase - wire components together
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        `uvm_info(get_type_name(), "Connect phase", UVM_HIGH)
        
        if (is_active == UVM_ACTIVE) begin
            // Connect driver's seq_item_port to sequencer's seq_item_export
            driver.seq_item_port.connect(sequencer.seq_item_export);
            
            `uvm_info(get_type_name(), "Driver connected to sequencer", UVM_HIGH)
        end
    endfunction
    
endclass