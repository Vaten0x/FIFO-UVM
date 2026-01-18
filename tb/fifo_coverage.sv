class fifo_coverage extends uvm_subscriber#(fifo_transaction);
    
    `uvm_component_utils(fifo_coverage)
    
    // Covergroup - Define scenarios to track
    covergroup fifo_cg;
        
        // Basic operations coverage
        write_cp: coverpoint wr_en {
            bins write = {1};
            bins no_write = {0};
        }
        
        read_cp: coverpoint rd_en {
            bins read = {1};
            bins no_read = {0};
        }
        
        // FIFO status flags
        full_cp: coverpoint full {
            bins not_full = {0};
            bins is_full = {1};
        }
        
        empty_cp: coverpoint empty {
            bins not_empty = {0};
            bins is_empty = {1};
        }
        
        almost_full_cp: coverpoint almost_full {
            bins not_almost_full = {0};
            bins is_almost_full = {1};
        }
        
        almost_empty_cp: coverpoint almost_empty {
            bins not_almost_empty = {0};
            bins is_almost_empty = {1};
        }
        
        // Data values - sample a few interesting patterns
        wr_data_cp: coverpoint wr_data {
            bins zero = {8'h00};
            bins all_ones = {8'hFF};
            bins mid_range = {[8'h01:8'hFE]};
            bins others = default;
        }
        
        // CROSS COVERAGE - The important stuff! 🎯
        
        // Did we try to write when full?
        write_when_full: cross write_cp, full_cp {
            bins attempted_write_when_full = binsof(write_cp.write) && binsof(full_cp.is_full);
            bins write_when_not_full = binsof(write_cp.write) && binsof(full_cp.not_full);
        }
        
        // Did we try to read when empty?
        read_when_empty: cross read_cp, empty_cp {
            bins attempted_read_when_empty = binsof(read_cp.read) && binsof(empty_cp.is_empty);
            bins read_when_not_empty = binsof(read_cp.read) && binsof(empty_cp.not_empty);
        }
        
        // Simultaneous read and write operations
        simultaneous_rw: cross write_cp, read_cp {
            bins both_active = binsof(write_cp.write) && binsof(read_cp.read);
            bins write_only = binsof(write_cp.write) && binsof(read_cp.no_read);
            bins read_only = binsof(write_cp.no_write) && binsof(read_cp.read);
            bins idle = binsof(write_cp.no_write) && binsof(read_cp.no_read);
        }
        
        // Almost full flag behavior
        almost_full_scenarios: cross write_cp, read_cp, almost_full_cp {
            // Write when almost full
            bins wr_when_almost_full = binsof(write_cp.write) && binsof(almost_full_cp.is_almost_full);
            // Read when almost full
            bins rd_when_almost_full = binsof(read_cp.read) && binsof(almost_full_cp.is_almost_full);
            // Simultaneous when almost full
            bins both_when_almost_full = binsof(write_cp.write) && binsof(read_cp.read) && 
                                         binsof(almost_full_cp.is_almost_full);
        }
        
        // Almost empty flag behavior
        almost_empty_scenarios: cross write_cp, read_cp, almost_empty_cp {
            bins wr_when_almost_empty = binsof(write_cp.write) && binsof(almost_empty_cp.is_almost_empty);
            bins rd_when_almost_empty = binsof(read_cp.read) && binsof(almost_empty_cp.is_almost_empty);
            bins both_when_almost_empty = binsof(write_cp.write) && binsof(read_cp.read) && 
                                          binsof(almost_empty_cp.is_almost_empty);
        }
        
    endgroup
    
    // Transaction signals for sampling
    bit       wr_en;
    bit       rd_en;
    bit       full;
    bit       empty;
    bit       almost_full;
    bit       almost_empty;
    bit [7:0] wr_data;
    bit [7:0] rd_data;
    
    // Coverage statistics
    real current_coverage;
    
    function new(string name = "fifo_coverage", uvm_component parent = null);
        super.new(name, parent);
        fifo_cg = new();  // Create covergroup
        current_coverage = 0;
    endfunction
    
    // Called automatically by monitor for each transaction
    function void write(fifo_transaction t);
        // Copy transaction fields
        wr_en = t.wr_en;
        rd_en = t.rd_en;
        full = t.full;
        empty = t.empty;
        almost_full = t.almost_full;
        almost_empty = t.almost_empty;
        wr_data = t.wr_data;
        rd_data = t.rd_data;
        
        // Sample coverage
        fifo_cg.sample();
        
        // Update coverage percentage
        current_coverage = fifo_cg.get_coverage();
        
        `uvm_info(get_type_name(), 
                  $sformatf("Coverage sample: wr=%0b rd=%0b full=%0b empty=%0b | Coverage: %.2f%%", 
                           wr_en, rd_en, full, empty, current_coverage),
                  UVM_HIGH)
    endfunction
    
    // Report phase - print final coverage
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        
        `uvm_info(get_type_name(), "========================================", UVM_LOW)
        `uvm_info(get_type_name(), "     FUNCTIONAL COVERAGE REPORT        ", UVM_LOW)
        `uvm_info(get_type_name(), "========================================", UVM_LOW)
        `uvm_info(get_type_name(), 
                  $sformatf("Overall Functional Coverage: %.2f%%", current_coverage),
                  UVM_LOW)
        
        // Individual coverpoint coverage
        `uvm_info(get_type_name(), 
                  $sformatf("  Write operations:     %.2f%%", fifo_cg.write_cp.get_coverage()),
                  UVM_LOW)
        `uvm_info(get_type_name(), 
                  $sformatf("  Read operations:      %.2f%%", fifo_cg.read_cp.get_coverage()),
                  UVM_LOW)
        `uvm_info(get_type_name(), 
                  $sformatf("  Full flag:            %.2f%%", fifo_cg.full_cp.get_coverage()),
                  UVM_LOW)
        `uvm_info(get_type_name(), 
                  $sformatf("  Empty flag:           %.2f%%", fifo_cg.empty_cp.get_coverage()),
                  UVM_LOW)
        `uvm_info(get_type_name(), 
                  $sformatf("  Almost full flag:     %.2f%%", fifo_cg.almost_full_cp.get_coverage()),
                  UVM_LOW)
        `uvm_info(get_type_name(), 
                  $sformatf("  Almost empty flag:    %.2f%%", fifo_cg.almost_empty_cp.get_coverage()),
                  UVM_LOW)
        `uvm_info(get_type_name(), 
                  $sformatf("  Simultaneous R/W:     %.2f%%", fifo_cg.simultaneous_rw.get_coverage()),
                  UVM_LOW)
        
        `uvm_info(get_type_name(), "========================================", UVM_LOW)
    endfunction
    
endclass