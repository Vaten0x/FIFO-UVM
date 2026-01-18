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

//==============================================================================
// Coverage Test - Target 100% code and functional coverage
//==============================================================================
class fifo_coverage_test extends fifo_base_test;
    
    `uvm_component_utils(fifo_coverage_test)
    
    function new(string name = "fifo_coverage_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    task run_phase(uvm_phase phase);
        fifo_transaction tx;
        
        `uvm_info(get_type_name(), "Starting coverage test", UVM_LOW)
        
        phase.raise_objection(this);
        
        // 1. Basic random operations
        run_random_ops(50);
        
        // 2. Test reset during operation (fixes reset_n toggle coverage)
        test_reset_during_operation();
        
        // 3. Test write pointer wraparound (fixes wr_ptr == 4'hf branch)
        test_write_wraparound();
        
        // 4. Test read pointer wraparound
        test_read_wraparound();
        
        // 5. Test all_ones data pattern (fixes functional coverage)
        test_all_ones_data();
        
        // 6. More random operations to hit edge cases
        run_random_ops(100);
        
        #1000;
        
        phase.drop_objection(this);
        
        `uvm_info(get_type_name(), "Coverage test completed", UVM_LOW)
    endtask
    
    // Helper: Run random operations
    task run_random_ops(int num);
        fifo_transaction tx;
        repeat(num) begin
            tx = fifo_transaction::type_id::create("tx");
            assert(tx.randomize());
            env.agent.sequencer.send_request(tx);
            env.agent.sequencer.wait_for_grant();
            env.agent.sequencer.send_item(tx);
            env.agent.sequencer.wait_for_item_done();
        end
    endtask
    
    // Test 1: Reset during operation (1→0 toggle)
    task test_reset_during_operation();
        fifo_transaction tx;
        
        `uvm_info(get_type_name(), "Testing reset during operation", UVM_MEDIUM)
        
        // Write some data first
        repeat(8) begin
            tx = fifo_transaction::type_id::create("tx");
            assert(tx.randomize() with {wr_en == 1; rd_en == 0;});
            env.agent.sequencer.send_request(tx);
            env.agent.sequencer.wait_for_grant();
            env.agent.sequencer.send_item(tx);
            env.agent.sequencer.wait_for_item_done();
        end
        
        // Assert reset (THIS IS THE MISSING 1→0 TOGGLE!)
        repeat(3) begin
            tx = fifo_transaction::type_id::create("tx");
            tx.reset_n = 0;  // Force reset active
            tx.wr_en = 0;
            tx.rd_en = 0;
            env.agent.sequencer.send_request(tx);
            env.agent.sequencer.wait_for_grant();
            env.agent.sequencer.send_item(tx);
            env.agent.sequencer.wait_for_item_done();
        end
        
        // De-assert reset
        tx = fifo_transaction::type_id::create("tx");
        tx.reset_n = 1;
        tx.wr_en = 0;
        tx.rd_en = 0;
        env.agent.sequencer.send_request(tx);
        env.agent.sequencer.wait_for_grant();
        env.agent.sequencer.send_item(tx);
        env.agent.sequencer.wait_for_item_done();
        
        #100;
    endtask
    
    // Test 2: Write pointer wraparound (wr_ptr goes 15→0)
    task test_write_wraparound();
        fifo_transaction tx;
        
        `uvm_info(get_type_name(), "Testing write pointer wraparound", UVM_MEDIUM)
        
        // Write 20 items to guarantee wraparound (DEPTH=16)
        repeat(20) begin
            tx = fifo_transaction::type_id::create("tx");
            assert(tx.randomize() with {wr_en == 1; rd_en == 0;});
            env.agent.sequencer.send_request(tx);
            env.agent.sequencer.wait_for_grant();
            env.agent.sequencer.send_item(tx);
            env.agent.sequencer.wait_for_item_done();
        end
        
        #100;
    endtask
    
    // Test 3: Read pointer wraparound (rd_ptr goes 15→0)
    task test_read_wraparound();
        fifo_transaction tx;
        
        `uvm_info(get_type_name(), "Testing read pointer wraparound", UVM_MEDIUM)
        
        // First fill FIFO
        repeat(16) begin
            tx = fifo_transaction::type_id::create("tx");
            assert(tx.randomize() with {wr_en == 1; rd_en == 0;});
            env.agent.sequencer.send_request(tx);
            env.agent.sequencer.wait_for_grant();
            env.agent.sequencer.send_item(tx);
            env.agent.sequencer.wait_for_item_done();
        end
        
        // Now read 20 times to wrap rd_ptr
        repeat(20) begin
            tx = fifo_transaction::type_id::create("tx");
            assert(tx.randomize() with {wr_en == 0; rd_en == 1;});
            env.agent.sequencer.send_request(tx);
            env.agent.sequencer.wait_for_grant();
            env.agent.sequencer.send_item(tx);
            env.agent.sequencer.wait_for_item_done();
        end
        
        #100;
    endtask
    
    // Test 4: All-ones data pattern (fixes functional coverage)
    task test_all_ones_data();
        fifo_transaction tx;
        
        `uvm_info(get_type_name(), "Testing all-ones data pattern", UVM_MEDIUM)
        
        // Write 16'hFFFF specifically
        repeat(5) begin
            tx = fifo_transaction::type_id::create("tx");
            tx.wr_en = 1;
            tx.rd_en = 0;
            tx.wr_data = 16'hFFFF;  // This hits the all_ones bin!
            env.agent.sequencer.send_request(tx);
            env.agent.sequencer.wait_for_grant();
            env.agent.sequencer.send_item(tx);
            env.agent.sequencer.wait_for_item_done();
        end
        
        #100;
    endtask
    
endclass