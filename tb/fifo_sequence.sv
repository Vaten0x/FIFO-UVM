class fifo_random_sequence extends uvm_sequence#(fifo_transaction);

    `uvm_object_utils(fifo_base_sequence)

    function new(string name = "fifo_base_sequence");
        super.new(name);
    endfunction

endclass

