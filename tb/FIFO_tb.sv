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
        assert(dut.counter == 5'd0) else $error("counter error #1");
        assert(dut.wr_ptr == 4'd0) else $error("wr_ptr error #1");
        assert(dut.rd_ptr == 4'd0) else $error("rd_ptr error #1");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b1) else $error("empty flag error");
        assert(dut.almost_empty == 1'b1) else $error("almost empty flag error");
        $display("Test 1 finished");

        // Test 2 - Write entry with data = 8'd1 
        wr_en = 1'b1;
        wr_data = 8'd1;
        #20;
        // [ 1, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null ]
        assert(dut.memory[0] == 8'd1) else $error("Data memory Error #1");
        assert(dut.counter == 5'd1) else $error("counter error #2");
        assert(dut.wr_ptr == 4'd1) else $error("wr_ptr error #1");
        assert(dut.rd_ptr == 4'd0) else $error("rd_ptr error #1");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b1) else $error("almost empty flag error");
        $display("Test 2 finished");

        // Test 3 - Write entry with data = 8'd2
        wr_en = 1'b1;
        wr_data = 8'd2;
        #20;
        // [ 1, 2, null, null, null, null, null, null, null, null, null, null, null, null, null, null ]
        assert(dut.memory[1] == 8'd2) else $error("Data memory Error #2");
        assert(dut.counter == 5'd2) else $error("counter error #3");
        assert(dut.wr_ptr == 4'd2) else $error("wr_ptr error #2");
        assert(dut.rd_ptr == 4'd0) else $error("rd_ptr error #2");
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
        assert(rd_data == 8'd1) else $error("Read Data Error #1");
        assert(dut.memory[1] == 8'd2) else $error("Data memory Error #3");
        assert(dut.counter == 5'd1) else $error("counter error #4");
        assert(dut.wr_ptr == 4'd2) else $error("wr_ptr error #3");
        assert(dut.rd_ptr == 4'd1) else $error("rd_ptr error #3");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b1) else $error("almost empty flag error");
        $display("Test 4 finished");

        // Test 5 - Write another entry with data = 8'd3
        wr_en = 1'b1;
        rd_en = 1'b0;
        wr_data = 8'd3;
        #20;
        // [ null, 2, 3, null, null, null, null, null, null, null, null, null, null, null, null, null ]
        // $display("dut.memory[2]: ", dut.memory[2]);
        assert(dut.memory[2] == 8'd3) else $error("Data memory Error #4");
        assert(dut.counter == 5'd2) else $error("counter error #5");
        assert(dut.wr_ptr == 4'd3) else $error("wr_ptr error #4");
        assert(dut.rd_ptr == 4'd1) else $error("rd_ptr error #4");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b1) else $error("almost empty flag error");
        $display("Test 5 finished");

        // Test 6 - Write another entry with data = 8'd4
        wr_en = 1'b1;
        wr_data = 8'd4;
        #20;
        // [ null, 2, 3, 4, null, null, null, null, null, null, null, null, null, null, null, null ]
        assert(dut.memory[3] == 8'd4) else $error("Data memory Error #5");
        assert(dut.counter == 5'd3) else $error("counter error #6");
        assert(dut.wr_ptr == 4'd4) else $error("wr_ptr error #5");
        assert(dut.rd_ptr == 4'd1) else $error("rd_ptr error #5");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b0) else $error("almost empty flag error");
        $display("Test 6 finished");

        // Test 7 - Write another entry with data = 8'd5
        wr_en = 1'b1;
        wr_data = 8'd5;
        #20;
        // [ null, 2, 3, 4, 5, null, null, null, null, null, null, null, null, null, null, null ]
        // $display("dut.memory[4]: ", dut.memory[4]);
        assert(dut.memory[4] == 8'd5) else $error("Data memory Error #6");
        assert(dut.counter == 5'd4) else $error("counter error #7");
        assert(dut.wr_ptr == 4'd5) else $error("wr_ptr error #6");
        assert(dut.rd_ptr == 4'd1) else $error("rd_ptr error #6");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b0) else $error("almost empty flag error");
        $display("Test 7 finished");

        // Test 8 - Write another entry with data = 8'd6
        wr_en = 1'b1;
        wr_data = 8'd6;
        #20;
        // [ null, 2, 3, 4, 5, 6, null, null, null, null, null, null, null, null, null, null ]
        assert(dut.memory[5] == 8'd6) else $error("Data memory Error #7");
        assert(dut.counter == 5'd5) else $error("counter error #8");
        assert(dut.wr_ptr == 4'd6) else $error("wr_ptr error #7");
        assert(dut.rd_ptr == 4'd1) else $error("rd_ptr error #7");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b0) else $error("almost empty flag error");
        $display("Test 8 finished");

        // Test 9 - Write another entry with data = 8'd7
        wr_en = 1'b1;
        wr_data = 8'd7;
        #20;
        // [ null, 2, 3, 4, 5, 6, 7, null, null, null, null, null, null, null, null, null ]
        assert(dut.memory[6] == 8'd7) else $error("Data memory Error #8");
        assert(dut.counter == 5'd6) else $error("counter error #9");
        assert(dut.wr_ptr == 4'd7) else $error("wr_ptr error #8");
        assert(dut.rd_ptr == 4'd1) else $error("rd_ptr error #8");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b0) else $error("almost empty flag error");
        $display("Test 9 finished");

        // Test 10 - Write another entry with data = 8'd8
        wr_en = 1'b1;
        wr_data = 8'd8;
        #20;
        // [ null, 2, 3, 4, 5, 6, 7, 8, null, null, null, null, null, null, null, null ]
        assert(dut.memory[7] == 8'd8) else $error("Data memory Error #8");
        assert(dut.counter == 5'd7) else $error("counter error #9");
        assert(dut.wr_ptr == 4'd8) else $error("wr_ptr error #8");
        assert(dut.rd_ptr == 4'd1) else $error("rd_ptr error #8");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b0) else $error("almost empty flag error");
        $display("Test 10 finished");

        // Test 11 - Write another entry with data = 8'd9
        wr_en = 1'b1;
        wr_data = 8'd9;
        #20;
        // [ null, 2, 3, 4, 5, 6, 7, 8, 9, null, null, null, null, null, null, null ]
        assert(dut.memory[8] == 8'd9) else $error("Data memory Error #9");
        assert(dut.counter == 5'd8) else $error("counter error #10");
        assert(dut.wr_ptr == 4'd9) else $error("wr_ptr error #9");
        assert(dut.rd_ptr == 4'd1) else $error("rd_ptr error #9");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b0) else $error("almost empty flag error");
        $display("Test 11 finished");

        // Test 12 - Write another entry with data = 8'd10
        wr_en = 1'b1;
        wr_data = 8'd10;
        #20;
        // [ null, 2, 3, 4, 5, 6, 7, 8, 9, 10, null, null, null, null, null, null ]
        assert(dut.memory[9] == 8'd10) else $error("Data memory Error #10");
        assert(dut.counter == 5'd9) else $error("counter error #11");
        assert(dut.wr_ptr == 4'd10) else $error("wr_ptr error #10");
        assert(dut.rd_ptr == 4'd1) else $error("rd_ptr error #10");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b0) else $error("almost empty flag error");
        $display("Test 12 finished");

        // Test 13 - Write another entry with data = 8'd11
        wr_en = 1'b1;
        wr_data = 8'd11;
        #20;
        // [ null, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, null, null, null, null, null ]
        assert(dut.memory[10] == 8'd11) else $error("Data memory Error #11");
        assert(dut.counter == 5'd10) else $error("counter error #12");
        assert(dut.wr_ptr == 4'd11) else $error("wr_ptr error #11");
        assert(dut.rd_ptr == 4'd1) else $error("rd_ptr error #11");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b0) else $error("almost empty flag error");
        $display("Test 13 finished");

        // Test 14 - Write another entry with data = 8'd12
        wr_en = 1'b1;
        wr_data = 8'd12;
        #20;
        // [ null, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, null, null, null, null ]
        assert(dut.memory[11] == 8'd12) else $error("Data memory Error #12");
        assert(dut.counter == 5'd11) else $error("counter error #13");
        assert(dut.wr_ptr == 4'd12) else $error("wr_ptr error #12");
        assert(dut.rd_ptr == 4'd1) else $error("rd_ptr error #12");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b0) else $error("almost empty flag error");
        $display("Test 14 finished");

        // Test 15 - Write another entry with data = 8'd13
        wr_en = 1'b1;
        wr_data = 8'd13;
        #20;
        // [ null, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, null, null, null ]
        assert(dut.memory[12] == 8'd13) else $error("Data memory Error #13");
        assert(dut.counter == 5'd12) else $error("counter error #14");
        assert(dut.wr_ptr == 4'd13) else $error("wr_ptr error #13");
        assert(dut.rd_ptr == 4'd1) else $error("rd_ptr error #13");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b0) else $error("almost empty flag error");
        $display("Test 15 finished");

        // Test 16 - Write another entry with data = 8'd14
        wr_en = 1'b1;
        wr_data = 8'd14;
        #20;
        // [ null, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, null, null ]
        assert(dut.memory[13] == 8'd14) else $error("Data memory Error #14");
        assert(dut.counter == 5'd13) else $error("counter error #15");
        assert(dut.wr_ptr == 4'd14) else $error("wr_ptr error #14");
        assert(dut.rd_ptr == 4'd1) else $error("rd_ptr error #14");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b0) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b0) else $error("almost empty flag error");
        $display("Test 16 finished");

        // Test 17 - Write another entry with data = 8'd15
        wr_en = 1'b1;
        wr_data = 8'd15;
        #20;
        // [ null, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, null ]
        assert(dut.memory[14] == 8'd15) else $error("Data memory Error #15");
        assert(dut.counter == 5'd14) else $error("counter error #16");
        assert(dut.wr_ptr == 4'd15) else $error("wr_ptr error #15");
        assert(dut.rd_ptr == 4'd1) else $error("rd_ptr error #15");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b1) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b0) else $error("almost empty flag error");
        $display("Test 17 finished");

        // Test 18 - Write another entry with data = 8'd16
        wr_en = 1'b1;
        wr_data = 8'd16;
        #20;
        // [ null, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 ]
        assert(dut.memory[15] == 8'd16) else $error("Data memory Error #16");
        assert(dut.counter == 5'd15) else $error("counter error #17");
        assert(dut.wr_ptr == 4'd0) else $error("wr_ptr error #16");
        assert(dut.rd_ptr == 4'd1) else $error("rd_ptr error #16");
        assert(dut.full == 1'b0) else $error("full flag error");
        assert(dut.almost_full == 1'b1) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b0) else $error("almost empty flag error");
        $display("Test 18 finished");

        // Test 19 - Write another entry with data = 8'd17
        wr_en = 1'b1;
        wr_data = 8'd17;
        #20;
        // [ 17, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 ]
        assert(dut.memory[0] == 8'd17) else $error("Data memory Error #17");
        assert(dut.counter == 5'd16) else $error("counter error #18");
        assert(dut.wr_ptr == 4'd1) else $error("wr_ptr error #17");
        assert(dut.rd_ptr == 4'd1) else $error("rd_ptr error #17");
        assert(dut.full == 1'b1) else $error("full flag error");
        assert(dut.almost_full == 1'b1) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b0) else $error("almost empty flag error");
        $display("Test 19 finished");

        // Test 20 - Write another entry with data = 8'd18 WHEN FIFO IS FULL
        // It should not write any new entries, no changes to ptr, counter and memory
        wr_en = 1'b1;
        wr_data = 8'd18;
        #20;
        // [ 17, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 ]
        assert(dut.memory[0] == 8'd17) else $error("Data memory Error #18");
        assert(dut.counter == 5'd16) else $error("counter error #19");
        assert(dut.wr_ptr == 4'd1) else $error("wr_ptr error #18");
        assert(dut.rd_ptr == 4'd1) else $error("rd_ptr error #18");
        assert(dut.full == 1'b1) else $error("full flag error");
        assert(dut.almost_full == 1'b1) else $error("almost_full flag error");
        assert(dut.empty == 1'b0) else $error("empty flag error");
        assert(dut.almost_empty == 1'b0) else $error("almost empty flag error");
        $display("Test 20 finished");





        // test reset

        // test empty read

        // test simultaneous read + write

        $display("All tests finished");
        $finish;
    end

    initial begin
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, FIFO_tb);
    end

endmodule