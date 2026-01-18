// Top testbench module for UVM testing
`include "uvm_macros.svh"
import uvm_pkg::*;

`include "tb/fifo_transaction.sv"
`include "tb/fifo_if.sv"
`include "tb/fifo_sequencer.sv"
`include "tb/fifo_driver.sv"
`include "tb/fifo_sequence.sv"
`include "tb/fifo_monitor.sv"
`include "tb/fifo_scoreboard.sv"
`include "tb/fifo_coverage.sv"
`include "tb/fifo_agent.sv"
`include "tb/fifo_env.sv"
`include "tb/fifo_test.sv"

module top_tb;

    logic clk;
    logic reset_n;

    // instantiate the interface
    fifo_if vif(clk, reset_n);

    // instantiate the DUT
    FIFO #(
        .DATA_WIDTH(8),
        .DEPTH(16)
    ) dut (
        .clk(clk),
        .reset_n(reset_n),
        .wr_en(vif.wr_en),
        .wr_data(vif.wr_data),
        .rd_en(vif.rd_en),
        .rd_data(vif.rd_data),
        .full(vif.full),
        .empty(vif.empty),
        .almost_full(vif.almost_full),
        .almost_empty(vif.almost_empty)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50MHz clock
    end

    // Reset generation
    initial begin
        reset_n = 0;
        #100;
        reset_n = 1;
    end

    // mid-simulation reset toggle for coverage
    initial begin
        #5000;              // Wait 5000ns into simulation
        reset_n = 0;        // Assert reset (1→0 transition - THIS FIXES COVERAGE!)
        repeat(3) @(posedge clk);
        reset_n = 1;        // De-assert reset (0→1 transition)
        $display("Mid-simulation reset toggle completed at time %0t", $time);
    end

    // UVM: Put interface into config_db
    initial begin
        uvm_config_db#(virtual fifo_if)::set(null,"*","vif",vif);
        
        run_test();
    end

    // enable fsdb to view it on verdi
    initial begin
        $fsdbDumpfile("fifo_uvm.fsdb");
        $fsdbDumpvars(0, top_tb);
    end
endmodule