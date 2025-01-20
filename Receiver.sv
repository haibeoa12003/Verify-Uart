`include "OutputPacket.sv"
class Receiver ;
    string name;    
    virtual uart_io.TB uart;
    OutputPacket  			pkt2cmp;

    reg [7:0] rx_data_cmp;
    reg rts_n_cmp;
	reg rx_done_cmp;
	reg parity_error_cmp; 

//  mailbox out_box;	// Scoreboard mailbox
  	typedef mailbox #(OutputPacket) rx_box_type;
  	rx_box_type 	rx_out_box;		// mailbox for Packet objects To Scoreboard 
	// int 			numpackets;
   	extern function new(string name ="Receiver" , rx_box_type rx_out_box, virtual uart_io.TB uart);
   	extern virtual task start();
    extern virtual task recv();
	extern virtual task get_payload();
endclass

function Receiver::new(string name, rx_box_type rx_out_box, virtual uart_io.TB uart);
  this.name = name;
  this.uart = uart;
  this.rx_out_box = rx_out_box;
  pkt2cmp = new();
//   this.numpackets = numpackets;
endfunction

task Receiver::start();
	int i;
	i = 0;
  //if (TRACE_ON) $display("[TRACE]%0d %s:%m", $time, name);
	$display($time, "[RECEIVER]  RECEIVER STARTED");
	 @(uart.cb); // to cater to the one cycle delay in the pipeline
	fork
		forever
		begin
			recv();
			
			rx_out_box.put(pkt2cmp);
			
			$display($time, "[RECEIVER]  Payload Obtained");
			i++;
			// if (i == numpackets)
			// begin
			// 	break;
			// end
		end	
	join_none
	$display ($time, "[RECEIVER] Forking of Process Finished");
endtask

task Receiver::recv();
    
    int pkt_cnt = 0;
    get_payload();
    
    pkt2cmp.name        = $psprintf("rcvdPkt[%0d]", pkt_cnt++);
    pkt2cmp.rx_data     = rx_data_cmp;
    pkt2cmp.rts_n       = rts_n_cmp;
    pkt2cmp.rx_done     = rx_done_cmp;
    pkt2cmp.parity_error= parity_error_cmp;
    
endtask

task Receiver::get_payload();
  // Wait for rx_done to become 1
  @(posedge uart.cb.rx_done);
  // Now that rx_done is 1, sample the data.
  rx_data_cmp = uart.cb.rx_data;
  rts_n_cmp = uart.cb.rts_n;
  rx_done_cmp = uart.cb.rx_done; //This will be 1
  parity_error_cmp = uart.cb.parity_error;

  $display ($time, "[RECEIVER]  Getting Payload");
  $display ($time, "[RECEIVER]  Payload Contents: rx_data = %b", rx_data_cmp);
endtask