
`include "Packet.sv"
`include "OutputPacket.sv"
class Scoreboard;
  string							name;			// unique identifier
  Packet							pkt_sent = new();	// Packet object from Driver
  OutputPacket						pkt_cmp = new();		// Packet object from Receiver

  typedef mailbox #(Packet)			out_box_type;
  out_box_type						driver_mbox;		// mailbox for Packet objects from Drivers

  typedef mailbox #(OutputPacket)	rx_box_type;
  rx_box_type						receiver_mbox;		// mailbox for Packet objects from Receiver

  int								num_tests;
  int								num_tests_passed;
  int								num_tests_failed;

	// Declare the signals to be compared over here.
  reg [7:0] rx_data_chk;
//----------------------------------------------------Define CG---------------------------------------------------------------------------------------------

 




//----------------------------------------------------------------------------------------------------------------------------------------------------------
  extern         function new(string name = "Scoreboard", out_box_type driver_mbox =null, rx_box_type receiver_mbox = null);
  extern virtual task start();
  extern virtual task check();
  extern         task result();
endclass

function Scoreboard::new(string name, out_box_type driver_mbox, rx_box_type receiver_mbox);
  this.name           = name;
  if (driver_mbox == null) 
  driver_mbox         = new();
  if (receiver_mbox == null) 
  receiver_mbox       = new();
  this.driver_mbox    = driver_mbox;
  this.receiver_mbox  = receiver_mbox;
endfunction

task Scoreboard::start();
       $display ($time, "[SCOREBOARD] Scoreboard Started");

       $display ($time, "[SCOREBOARD] Receiver Mailbox contents = %d", receiver_mbox.num());
       fork
	       forever 
	       begin
          
		       if(receiver_mbox.try_get(pkt_cmp)) begin
			       $display ($time, "[SCOREBOARD] Grabbing Data From both Driver and Receiver");
			       //receiver_mbox.get(pkt_cmp);
			       driver_mbox.get(pkt_sent);
			       check();
		       end
		       else 
		       begin
			       #1;
		       end
	       end
       join_none
       $display ($time, "[SCOREBOARD] Forking of Process Finished");
endtask

task Scoreboard::check();

  $display($time, "ns: [CHECKER] Checker Start\n\n");
  $display($time, "ns:  	[CHECK_RX_DATA] Golden Incoming rx_data = %b", pkt_sent.rx);
  rx_data_chk = pkt_sent.rx;		
  // Grab packet sent from scoreboard 				
  $display($time, "ns:   [CHECKER] Pkt Contents: rx_data= %b, ", pkt_sent.rx);
  $display($time, "ns:   [CHECKER] Pkt_cmp Contents: rx_data= %b, rx_done = %b,parity_error= %b ,rts_n = %b ", pkt_cmp.rx_data,pkt_cmp.rx_done,pkt_cmp.parity_error,pkt_cmp.rts_n);
  assert (pkt_cmp.rx_data == rx_data_chk) $display("[CHECKER CORRECT] RX_DATA CORRECT\n\n");
  else $display("[FAIL]RX_DATA FAIL");
endtask

task Scoreboard::result();
  $display("Number tests : %0d, Pass: %0d, Fail: %0d",num_tests,num_tests_passed, num_tests_failed);
endtask

