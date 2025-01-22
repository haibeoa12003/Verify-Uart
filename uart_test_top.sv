
// `timescale 1ns/1ps
`include "baurate_config.sv"
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
     repeat(435) @(posedge SysClock);
    top_io.reset_n = 1;
   end
endmodule
