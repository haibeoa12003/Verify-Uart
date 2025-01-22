`include "Generator.sv"
`include "Driver.sv"
`include "ScoreBoard.sv"
`include "Receiver.sv"
program uart_test (uart_io.TB uart);

	Generator  	generator;	// generator object
	Driver     	drvr;		// driver objects
	Scoreboard 	sb;			// scoreboard object
	Receiver 	rcvr;		// Receiver Object
	
	Packet 		pkt_sent = new("Packet");
	int 		count = 0;
	int 		number_packets;
    // string 		test_name = TEST_NAME;
	
	initial begin
		number_packets 		 = 100;
    	generator			 = new("Generator", number_packets);
		sb					 = new(); // NOTE THAT THERE ARE DEFAULT VALUES FOR THE NEW FUNCTION 
					      // FOR THE SCOREBOARD 
		drvr 				 = new("drvr[0]", generator.in_box, sb.driver_mbox, uart);
		rcvr				 = new("rcvr[0]", sb.receiver_mbox, uart);  
		// reset();
    	// // $display("[%tns] Start test case for : %s",$time, test_name);
		generator.start();
		drvr.start(); 
		sb.start();
		rcvr.start();
		repeat((number_packets+1)*5655) @(uart.cb);
		sb.result();
		$display($time, "WE ARE DONE .. GO HOME AND SLEEP!!! .. ACTUALLY NOT YET .. ");
	end

	// task reset();
    // uart.cb.rx <= 1'b1;         
    // uart.reset_n <= 1'b0;          
    // repeat(435) @(posedge uart.clk);
    // uart.reset_n <= 1'b1;          
  	// endtask

// This is the end of the TB
endprogram
