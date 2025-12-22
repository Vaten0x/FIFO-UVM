# FIFO-UVM
Register based FIFO tested with UVM

Requirements of this FIFO:

- Synchronous
- Register based
- Data width: 8 bits
- Depth: 16 entries 
- Total size: 8*16 = 128 bits
- Full, Empty, Almost Full, Almost Empty flags (almost full when 14 or more entries are filled, almost empty when 2 entries or less are filled)
- write enable, write data, read enable, read data signals
- Ignores illegal operations (write when full, read when empty)

Inputs:

- clk: Clock signal
- rst_n: Active low reset signal
- wr_en: Write enable signal
- wr_data[7:0]: 8-bit write data input
- rd_en: Read enable signal

Outputs:
- rd_data[7:0]: 8-bit read data output
- full: FIFO full flag
- empty: FIFO empty flag
- almost_full: FIFO almost full flag
- almost_empty: FIFO almost empty flag

UVM Testbench Features: