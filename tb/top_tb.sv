`include "uvm_macros.svh"
import uvm_pkg::*;

// `include "fifo_test.sv"
// `include "fifo_env.sv"
`include "fifo_transaction.sv"

module top_tb;
    initial begin
        run_test();
    end
endmodule