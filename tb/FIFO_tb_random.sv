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

            do_write = $urandom(0, 1);
            do_read = $urandom(0, 1);
            test_data = $urandom(0, 255);

            wr_en = do_write;
            rd_en = do_read;
            wr_data = test_data;

            if (do_write && !dut.full) begin
                queue_ref.push_back(test_data);
            end

            @(posedge clk);

            if ($past(do_read) && $past(!dut.empty)) begin
                logic [7:0] expected_result;
                expected_result = queue_ref.pop_front();

                assert(rd_data == expected_result) else $error("Data Output Mismatch Counter=%0d, Queue=%0d", dut.counter, queue_ref.size());
            end
        end

        $finish;
    end

    initial begin
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpvars(0, FIFO_tb);
    end

    property counter_in_range;
        @(posedge clk) dut.counter <= DEPTH;
    endproperty

    assert property (counter_in_range);

endmodule