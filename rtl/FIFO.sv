module FIFO #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16
)(
    input clk,
    input rst_n,
    input wr_en,
    input [7:0] wr_data,
    input rd_en,
    output reg [7:0] rd_data,
    output full,
    output empty,
    output almost_full,
    output almost_empty 
);

    localparam ADDR_WIDTH = $clog2(DATA_WIDTH);

    reg [ADDR_WIDTH-1:0] wr_ptr;
    reg [ADDR_WIDTH-1:0] rd_ptr;


endmodule