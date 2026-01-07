// Bridge between my testbench & the DUT
interface fifo_if(input logic clk, input logic reset_n);

    logic wr_en;
    logic [7:0]  wr_data;
    logic rd_en;
    logic [7:0]  rd_data;
    logic full;
    logic empty;
    logic almost_full;
    logic almost_empty;

     // Clocking block for monitor (observe everything)
    clocking monitor_cb @(posedge clk);
        default input #1ns output #1ns; // delays to avoid setup/hold time restrictions
        input wr_en;
        input wr_data;
        input rd_en;
        input rd_data;
        input full;
        input empty;
        input almost_full;
        input almost_empty;
    endclocking
    
    // Modport for driver (what driver can access)
    modport DRIVER (
        clocking driver_cb,
        input clk,
        input reset_n
    );
    
    // Modport for monitor (what monitor can access)
    modport MONITOR (
        clocking monitor_cb,
        input clk,
        input reset_n
    );

endinterface