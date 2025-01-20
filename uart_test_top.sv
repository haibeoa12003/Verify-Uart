
// `timescale 1ns/1ps
module uart_test_top;
	parameter simulation_cycle = 20;

	reg  SysClock;
	
	uart_io top_io(SysClock);
  rx_checker_module rx_checker(top_io);
reg cts_n;
reg tx;
reg tx_done;
  uart dut(
		.clk				(top_io.clk), 
		.reset_n				(top_io.reset_n), 
		.rx				(top_io.rx),   
		.data_bit_num				(top_io.data_bit_num),
	  .stop_bit_num				(top_io.stop_bit_num),
		.parity_en			(top_io.parity_en),
		.parity_type	(top_io.parity_type), 
		.rx_data	(top_io.rx_data),
		.rts_n		(top_io.rts_n),
		.rx_done				(top_io.rx_done),
		.parity_error				(top_io.parity_error),
        .cts_n(cts_n),
        .tx(tx),
        .tx_data(8'b11111111),
        .start_tx(1'b0),
        .tx_done(tx_done)
	);
    
  /* ------------- TEST NAME ------------------------
  1. all_top                            // Generate all operations

  2. arith_logic                        // Generate all arithmetic operations
    2.1 arith_logic_and_only_add        // Only add operation
    2.2 arith_logic_and_only_hadd       // Only hadd operation
    2.3 arith_logic_and_only_sub        // Only sub operation
    2.4 arith_logic_and_only_not        // Only not operation
    2.5 arith_logic_and_only_and        // Only and operation
    2.6 arith_logic_and_only_or         // Only or operation
    2.7 arith_logic_and_only_xor        // Only xor operation
    2.8 arith_logic_and_only_lhg        // Only lhg operation
    
  3. shift_reg                          // Generate all shift register operations
    3.1 shift_reg_and_only_shleftlog    // Only shift left logic
    3.2 shift_reg_and_only_shleftart    // Only shift left arithmetic
    3.3 shift_reg_and_only_shrghtlog    // Only shift right logigc
    3.4 shift_reg_and_only_shrghtart    // Only shift right arithmetic
    
  4. mem_read                           // Generate all memory read operations
    4.1 mem_read_and_only_loadbyte      // Only load byte operation
    4.1 mem_read_and_only_loadbyteu     // Only load byte unsigned operation
    4.1 mem_read_and_only_loadhalf      // Only load half operation
    4.1 mem_read_and_only_loadhalfu     // Only load half unsigned operation
    4.1 mem_read_and_only_loadword      // Only load word operation
      
  5. mem_write                          // Generate all memory write operation
  6. arith_and_shift
  7. testlab4
	----------------------------------------------------*/
  

	uart_test test(top_io);   		
	
	initial
	begin
		SysClock = 0;

		forever 
		begin
			#(simulation_cycle/2)
			SysClock = ~SysClock;
		end
	end
  initial begin
    top_io.reset_n = 0;
    # 100
   top_io.reset_n = 1;
  end
endmodule
