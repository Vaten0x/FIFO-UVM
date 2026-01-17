//==============================================================================
// Base Test - Common setup
//==============================================================================
class fifo_base_test extends uvm_test;
    
    // Register with factory
    `uvm_component_utils(fifo_base_test)
    
    // Environment handle
    fifo_env env;
    
    // Constructor
    function new(string name = "fifo_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase - create environment
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Enable transaction recording for Verdi
        uvm_config_db#(int)::set(this, "*", "recording_detail", UVM_FULL);
        
        `uvm_info(get_type_name(), "Build phase", UVM_MEDIUM)
        
        // Create environment
        env = fifo_env::type_id::create("env", this);
    endfunction
    
    // End of elaboration - print topology
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        
        // Print testbench hierarchy
        uvm_top.print_topology();

        // Enable all recording
        uvm_config_db#(int)::set(null, "*", "recording_detail", UVM_FULL);
    endfunction
    
    // Report phase - print summary
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        
        `uvm_info(get_type_name(), "Test completed!", UVM_LOW)
    endfunction
    
endclass

//==============================================================================
// Random Test - Run random sequence
//==============================================================================
class fifo_random_test extends fifo_base_test;
    
    `uvm_component_utils(fifo_random_test)
    
    function new(string name = "fifo_random_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Run phase - THIS IS WHERE THE ACTION HAPPENS!
    task run_phase(uvm_phase phase);
        fifo_random_sequence seq;
        
        `uvm_info(get_type_name(), "Starting random test", UVM_LOW)
        
        // Raise objection - keeps simulation alive
        phase.raise_objection(this);
        
        // Create and configure sequence
        seq = fifo_random_sequence::type_id::create("seq");
        seq.num_trans = 100;  // Generate 100 transactions
        
        // Start sequence on sequencer
        seq.start(env.agent.sequencer);
        
        // Small delay after sequence
        #1000;
        
        // Drop objection - allows simulation to end
        phase.drop_objection(this);
        
        `uvm_info(get_type_name(), "Random test completed", UVM_LOW)
    endtask
    
endclass

//==============================================================================
// Write-Read Test - Fill then drain FIFO
//==============================================================================
class fifo_write_read_test extends fifo_base_test;
    
    `uvm_component_utils(fifo_write_read_test)
    
    function new(string name = "fifo_write_read_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    task run_phase(uvm_phase phase);
        fifo_write_sequence write_seq;
        fifo_read_sequence read_seq;
        
        `uvm_info(get_type_name(), "Starting write-read test", UVM_LOW)
        
        phase.raise_objection(this);
        
        // First, fill FIFO
        write_seq = fifo_write_sequence::type_id::create("write_seq");
        write_seq.num_writes = 16;  // Fill FIFO
        write_seq.start(env.agent.sequencer);
        
        #100;  // Small delay
        
        // Then, drain FIFO
        read_seq = fifo_read_sequence::type_id::create("read_seq");
        read_seq.num_reads = 16;  // Drain FIFO
        read_seq.start(env.agent.sequencer);
        
        #1000;
        
        phase.drop_objection(this);
        
        `uvm_info(get_type_name(), "Write-read test completed", UVM_LOW)
    endtask
    
endclass