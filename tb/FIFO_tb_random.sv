module FIFO_tb_random();
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

    logic [7:0] queue_ref [$];

    logic prev_rd_en;
    logic prev_empty;

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
        @(posedge clk);

        repeat(500) begin
            logic do_write, do_read;
            logic [7:0] test_data;

            do_write = $urandom_range(0, 1);
            do_read = $urandom_range(0, 1);
            test_data = $urandom_range(0, 255);

            wr_en = do_write;
            rd_en = do_read;
            wr_data = test_data;

            prev_rd_en = do_read;
            prev_empty = empty;

            if (do_write && !dut.full) begin
                queue_ref.push_back(test_data);
            end

            @(posedge clk);

            if (prev_rd_en && !prev_empty) begin
                logic [7:0] expected_result;
                expected_result = queue_ref.pop_front();

                assert(rd_data == expected_result) else $error("Data Output Mismatch Counter=%0d, Queue=%0d", dut.counter, queue_ref.size());
            end

            assert(dut.counter == queue_ref.size()) else $error("Counter Size Mismatch Counter=%0d, Queue=%0d", dut.counter, queue_ref.size());
        end

        $finish;
    end

    initial begin
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, FIFO_tb_random);
    end

endmodule