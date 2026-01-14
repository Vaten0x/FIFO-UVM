class fifo_base_sequence extends uvm_sequence#(fifo_transaction);

    `uvm_object_utils(fifo_base_sequence)

    function new(string name = "fifo_base_sequence");
        super.new(name);
    endfunction

    // no body() for base sequence

endclass

// random operations on FIFO
class fifo_random_sequence extends fifo_base_sequence;

    `uvm_object_utils(fifo_random_sequence)

    rand int num_trans;

    constraint c_num_trans {
        num_trans inside {[50:200]} //between 50 to 200 transactions
    }

    function new(string name = "fifo_random_sequence");
        super.new(name);
    endfunction

    task body();
        fifo_transaction req;
        `uvm_info(get_type_name(), $sformatf("Starting random sequence with %0d transactions", num_trans), UVM_LOW)

        repeat (num_trans) begin
            //create transaction
            req = fifo_transaction::type_id::create("req");

            //wait driver to be ready and randomize it
            start_item(req);

            //randomize using transaction's constraints
            if (!req.randomize()) begin
                `uvm_error(get_type_name(), "Randomization failed!")
            end

            finish_item(req);

            `uvm_info(get_type_name(), $sformatf("Sent: %s", req.convert2string()), UVM_HIGH)
        end

        `uvm_info(get_type_name(), "Random sequence completed", UVM_LOW)

    endtask
endclass

// fill operations on FIFO
class fifo_write_sequence extends fifo_base_sequence;

    `uvm_object_utils(fifo_write_sequence)

    rand int num_writes;

    constraint c_num_writes {
        num_writes inside {[10:20]};
    }

    function new(string name = "fifo_write_sequence");
        super.new(name);
    endfunction


    task body();
        fifo_transaction req;
        
        `uvm_info(get_type_name(), 
                  $sformatf("Starting write sequence with %0d writes", num_writes), 
                  UVM_LOW)
        
        repeat(num_writes) begin
            req = fifo_transaction::type_id::create("req");
            start_item(req);
            
            // Constrain to only writes
            if (!req.randomize() with {
                wr_en == 1;   // Always write
                rd_en == 0;   // Never read
            }) begin
                `uvm_error(get_type_name(), "Randomization failed!")
            end
            
            finish_item(req);
        end
        
        `uvm_info(get_type_name(), "Write sequence completed", UVM_LOW)
    endtask
endclass

// empty FIFO
class fifo_read_sequence extends fifo_base_sequence;
    
    `uvm_object_utils(fifo_read_sequence)
    
    rand int num_reads;
    
    constraint c_num_reads {
        num_reads inside {[10:20]};
    }
    
    function new(string name = "fifo_read_sequence");
        super.new(name);
    endfunction
    
    task body();
        fifo_transaction req;
        
        `uvm_info(get_type_name(), 
                  $sformatf("Starting read sequence with %0d reads", num_reads), 
                  UVM_LOW)
        
        repeat(num_reads) begin
            req = fifo_transaction::type_id::create("req");
            start_item(req);
            
            // Constrain to only reads
            if (!req.randomize() with {
                wr_en == 0;   // Never write
                rd_en == 1;   // Always read
            }) begin
                `uvm_error(get_type_name(), "Randomization failed!")
            end
            
            finish_item(req);
        end
        
        `uvm_info(get_type_name(), "Read sequence completed", UVM_LOW)
    endtask
    
endclass