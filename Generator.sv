`include "Packet.sv"
class Generator;
	string  name;		
	Packet  pkt2send;	

  typedef mailbox #(Packet) in_box_type;
	in_box_type in_box;
	
	int		packet_number;
	int 	number_packets;
	extern function new(string name = "Generator", int number_packets);
	extern virtual task gen();
	extern virtual task start();

//   function int contains(string a, string b);
//     // checks if string A contains string B
//     int len_a;
//     int len_b;
//     len_a = a.len();
//     len_b = b.len();
//     $display("a (%s) len %d -- b (%s) len %d", a, len_a, b, len_b);
//     for( int i=0; i<len_a; i++) begin
//       if(a.substr(i,i+len_b-1) == b)
//            return 1;
//     end
//     return 0;
//   endfunction
endclass


function Generator::new(string name = "Generator", int number_packets);
	this.name = name;
	this.pkt2send = new();
	this.in_box = new;
	this.packet_number = 0;
	this.number_packets = number_packets;
endfunction

task Generator::gen();
    pkt2send.name = $psprintf("Packet[%0d]", packet_number++);
    if (!pkt2send.randomize()) 
    begin
      $display(" \n%m\n[ERROR]%0d gen(): Randomization Failed with all_op test!", $time);
      $finish;	
    end
    else begin
    $display(" \n%m\n[SUCCESS]%0d gen(): Randomization Successful", $time);
    end
endtask


task Generator::start();
	  $display ($time, "ns:  [GENERATOR] Generator Started");
	  fork
      begin
		  for (int i=0; i<number_packets || number_packets <= 0; i++)
		  begin
			  gen();
			  begin
			      Packet pkt = new pkt2send; 
			      in_box.put(pkt); 
			  end
		  end
      end
		  $display($time, "ns:  [GENERATOR] Generation Finished Creating %d Packets  ", number_packets);
      join_none
endtask