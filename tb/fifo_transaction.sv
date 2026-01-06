class fifo_transaction extends uvm_sequence_items;
    // Inputs - what i want to send to FIFO
    rand bit [7:0] wr_data;
    rand bit wr_en;
    rand bit rd_en;

    // Outputs (will need these later for monitor)
    bit [7:0] rd_data;
    bit full;
    bit almost_full;
    bit almost_empty;
    bit empty;

    // UVM automation macros
    `uvm_object_utils_begin(fifo_transaction)
    `uvm_field_int(wr_data, UVM_ALL_ON)
    `uvm_field_int(wr_en, UVM_ALL_ON)
    `uvm_field_int(rd_en, UVM_ALL_ON)
    `uvm_object_utils_end

    // Constructors

    // Constraints

endclass


