module FIFO_tb(); //simple testbench

    localparam DATA_WIDTH = 8;
    localparam DEPTH = 16;

    logic clk;
    logic reset_n; // active-low button
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

    initial begin
        // Instantiate everything before running test
        reset_n = 1'b0; //reset on
        wr_en = 1'b0;
        wr_data = 8'd0;
        rd_en = 1'b0;
        #100;
        reset_n = 1'b1; //reset off
        #15;

        // Write one entry with data = 8'd1
        wr_en = 1'b1;
        wr_data = 8'b00000001;
        assert(dut.counter == 4'b0000) else $error("counter error #1");
        assert(dut.wr_ptr == 4'b0000) else $error("wr_ptr error #1");
        assert(dut.rd_ptr == 4'b0000) else $error("rd_ptr error #1");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b1) else $error("empty flag error");
        assert(dut.almost_empty == 1'b1) else $error("almost empty flag error");
        $display("Test 1 finished");
        #20;

        // Write another entry with data 8'd2
        assert(dut.memory[0] == 8'b00000001) else $error("Date memory Issue #1");
        assert(dut.counter == 4'b0000) else $error("counter error #2");
        assert(dut.wr_ptr == 4'b0001) else $error("wr_ptr error #1");
        assert(dut.rd_ptr == 4'b0000) else $error("rd_ptr error #1");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b1) else $error("almost empty flag error");
        $display("Test 2 finished");
        wr_en = 1'b1;
        wr_data = 8'b00000010;
        #20;

        $finish;
    end

    initial begin
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, FIFO_tb);
    end

endmodule