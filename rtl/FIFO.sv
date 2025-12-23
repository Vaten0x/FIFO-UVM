module FIFO #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16 // expects DEPTH to be at least > 3
)(
    input clk,
    input reset_n,
    input wr_en,
    input [7:0] wr_data,
    input rd_en,
    output logic [7:0] rd_data,
    output logic full,
    output logic empty,
    output logic almost_full,
    output logic almost_empty 
);

    localparam ADDR_WIDTH = $clog2(DEPTH);

    logic [ADDR_WIDTH-1:0] wr_ptr;
    logic [ADDR_WIDTH-1:0] rd_ptr;
    logic [ADDR_WIDTH-1:0] counter;
    logic [DATA_WIDTH-1:0] memory [ADDR_WIDTH-1:0];

    assign full = (counter == DEPTH);
    assign empty = (counter == 0);
    assign almost_full = (counter >= DEPTH - 2);
    assign almost_empty = (counter <= 2);

    always @(posedge clk) begin
        if (reset_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            counter <= 0;
        end else if (wr_en && rd_en && !full & !empty) begin
            //simultaneous read and write logic here
        end else if (wr_en && !full) begin
            //write logic here
        end else if (rd_en && !empty) begin
            //read logic here
        end else begin
            wr_ptr <= wr_ptr;
            rd_ptr <= rd_ptr;
            counter <= counter;
        end
    end

endmodule