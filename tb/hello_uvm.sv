`include "uvm_macros.svh"
import uvm_pkg::*;

class my_test extends uvm_test;
    `uvm_component_utils(my_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Hello from UVM!", UVM_LOW)
    endtask
endclass

module tb_top;
    initial run_test("my_test");
endmodule