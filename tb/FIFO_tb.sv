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
        // Test 1 - Instantiate everything before running test
        reset_n = 1'b0; //reset on
        wr_en = 1'b0;
        wr_data = 8'd0;
        rd_en = 1'b0;
        #100;
        reset_n = 1'b1; //reset off
        #15;
        assert(dut.counter == 4'b0000) else $error("counter error #1");
        assert(dut.wr_ptr == 4'b0000) else $error("wr_ptr error #1");
        assert(dut.rd_ptr == 4'b0000) else $error("rd_ptr error #1");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b1) else $error("empty flag error");
        assert(dut.almost_empty == 1'b1) else $error("almost empty flag error");
        $display("Test 1 finished");

        // Test 2 - Write entry with data = 8'd1 
        wr_en = 1'b1;
        wr_data = 8'b00000001;
        #20;
        // [ 1, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null ]
        assert(dut.memory[0] == 8'b00000001) else $error("Data memory Error #1");
        assert(dut.counter == 4'b0001) else $error("counter error #2");
        assert(dut.wr_ptr == 4'b0001) else $error("wr_ptr error #1");
        assert(dut.rd_ptr == 4'b0000) else $error("rd_ptr error #1");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b1) else $error("almost empty flag error");
        $display("Test 2 finished");

        // Test 3 - Write entry with data = 8'd2
        wr_en = 1'b1;
        wr_data = 8'b00000010;
        #20;
        // [ 1, 2, null, null, null, null, null, null, null, null, null, null, null, null, null, null ]
        assert(dut.memory[1] == 8'b00000010) else $error("Data memory Error #2");
        assert(dut.counter == 4'b0010) else $error("counter error #3");
        assert(dut.wr_ptr == 4'b0010) else $error("wr_ptr error #2");
        assert(dut.rd_ptr == 4'b0000) else $error("rd_ptr error #2");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b1) else $error("almost empty flag error");
        $display("Test 3 finished");

        // Test 4 - Read entry with data = 8'd1 
        wr_en = 1'b0;
        rd_en = 1'b1;
        #20;
        // [ null, 2, null, null, null, null, null, null, null, null, null, null, null, null, null, null ]
        assert(rd_data == 8'b00000001) else $error("Read Data Error #1");
        assert(dut.memory[1] == 8'b00000010) else $error("Data memory Error #3");
        assert(dut.counter == 4'b0001) else $error("counter error #4");
        assert(dut.wr_ptr == 4'b0010) else $error("wr_ptr error #3");
        assert(dut.rd_ptr == 4'b0001) else $error("rd_ptr error #3");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b1) else $error("almost empty flag error");
        $display("Test 4 finished");

        // Test 5 - Write another entry with data = 8'd3
        wr_en = 1'b1;
        rd_en = 1'b0;
        wr_data = 8'b00000011;
        #20;
        // [ null, 2, 3, null, null, null, null, null, null, null, null, null, null, null, null, null ]
        assert(dut.memory[2] == 8'b00000011) else $error("Data memory Error #4");
        assert(dut.counter == 4'b0010) else $error("counter error #5");
        assert(dut.wr_ptr == 4'b0011) else $error("wr_ptr error #4");
        assert(dut.rd_ptr == 4'b0001) else $error("rd_ptr error #4");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b1) else $error("almost empty flag error");
        $display("Test 5 finished");

        // Test 6 - Write another entry with data = 8'd4
        wr_en = 1'b1;
        wr_data = 8'b00000100;
        #20;
        // [ null, 2, 3, 4, null, null, null, null, null, null, null, null, null, null, null, null ]
        assert(dut.memory[3] == 8'b00000100) else $error("Data memory Error #5");
        assert(dut.counter == 4'b0011) else $error("counter error #6");
        assert(dut.wr_ptr == 4'b0100) else $error("wr_ptr error #5");
        assert(dut.rd_ptr == 4'b0001) else $error("rd_ptr error #5");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b0) else $error("almost empty flag error");
        $display("Test 6 finished");

        // Test 7 - Write another entry with data = 8'd5
        wr_en = 1'b1;
        wr_data = 8'b00000101;
        #20;
        // [ null, 2, 3, 4, 5, null, null, null, null, null, null, null, null, null, null, null ]
        assert(dut.memory[4] == 8'b00000101) else $error("Data memory Error #6");
        assert(dut.counter == 4'b0100) else $error("counter error #7");
        assert(dut.wr_ptr == 4'b0101) else $error("wr_ptr error #6");
        assert(dut.rd_ptr == 4'b0001) else $error("rd_ptr error #6");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b0) else $error("almost empty flag error");
        $display("Test 7 finished");

        // Test 8 - Write another entry with data = 8'd6
        wr_en = 1'b1;
        wr_data = 8'b00000110;
        #20;
        // [ null, 2, 3, 4, 5, 6, null, null, null, null, null, null, null, null, null, null ]
        assert(dut.memory[5] == 8'b00000110) else $error("Data memory Error #7");
        assert(dut.counter == 4'b0101) else $error("counter error #8");
        assert(dut.wr_ptr == 4'b0110) else $error("wr_ptr error #7");
        assert(dut.rd_ptr == 4'b0001) else $error("rd_ptr error #7");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b0) else $error("almost empty flag error");
        $display("Test 8 finished");

        // Test 9 - Write another entry with data = 8'd7
        wr_en = 1'b1;
        wr_data = 8'b00000111;
        #20;
        // [ null, 2, 3, 4, 5, 6, 7, null, null, null, null, null, null, null, null, null ]
        assert(dut.memory[6] == 8'b00000111) else $error("Data memory Error #8");
        assert(dut.counter == 4'b0110) else $error("counter error #9");
        assert(dut.wr_ptr == 4'b0111) else $error("wr_ptr error #8");
        assert(dut.rd_ptr == 4'b0001) else $error("rd_ptr error #8");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b0) else $error("almost empty flag error");
        $display("Test 9 finished");

        // Test 10 - Write another entry with data = 8'd8
        wr_en = 1'b1;
        wr_data = 8'b00001000;
        #20;
        // [ null, 2, 3, 4, 5, 6, 7, 8, null, null, null, null, null, null, null, null ]
        assert(dut.memory[7] == 8'b00001000) else $error("Data memory Error #8");
        assert(dut.counter == 4'b0111) else $error("counter error #9");
        assert(dut.wr_ptr == 4'b1000) else $error("wr_ptr error #8");
        assert(dut.rd_ptr == 4'b0001) else $error("rd_ptr error #8");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b0) else $error("almost empty flag error");
        $display("Test 10 finished");

        $display("All tests finished");
        $finish;
    end

    initial begin
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, FIFO_tb);
    end

endmodule