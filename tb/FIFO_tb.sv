// simple testbench

module FIFO #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16
);

    logic clk;
    logic reset_n;
    logic wr_en;
    logic [7:0] wr_data;
    logic rd_en;
    logic [7:0] rd_data;
    logic full;
    logic empty;
    logic almost_full;
    logic almost_empty;

    FIFO #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .reset_n(reset_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .full(full),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50MHz clock
    end

endmodule