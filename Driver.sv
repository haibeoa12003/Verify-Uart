`include "Packet.sv"
class Driver ;
    virtual   uart_io.TB uart;	
	string    name;		
	Packet    pkt2send;	

	reg  [7:0] payload_rx;
    reg [1:0] payload_data_bit_num;
	reg payload_stop_bit_num;
	reg payload_parity_en;
	reg payload_parity_type;
    reg payload_parity_bit;

  //mailbox in_box;	// Generator mailbox // QUESTA QUIRK
  typedef mailbox #(Packet) in_box_type;
  in_box_type in_box = new;
  //mailbox out_box;	// Scoreboard mailbox // QUESTA QUIRK
  typedef mailbox #(Packet) out_box_type;
  out_box_type out_box = new;
  //semaphore sem[];	// output port arbitration

  extern function new(string name = "Driver", in_box_type in_box, out_box_type out_box, virtual uart_io.TB uart);
  extern virtual task send_payload();
  extern virtual task start();
endclass

function Driver::new(string name= "Driver", in_box_type in_box, out_box_type out_box, virtual uart_io.TB uart);
    this.name=name;
    this.uart = uart;
    this.in_box = in_box;
    this.out_box = out_box;
endfunction


task Driver::start();

	int packets_sent = 0;
	$display ($time, "ns:  [DRIVER] Driver Started");
    fork
	    forever
	    begin
	      in_box.get(pkt2send); // grab the packet in the q
        packets_sent++;
        $display ($time, "[DRIVER] Sending in new packet BEGIN");
		  	this.payload_rx = pkt2send.rx;
            this.payload_data_bit_num = pkt2send.data_bit_num;
            this.payload_stop_bit_num = pkt2send.stop_bit_num;
            this.payload_parity_en = pkt2send.parity_en;
            this.payload_parity_type = pkt2send.parity_type;
            this.payload_parity_bit = pkt2send.parity_bit;				
        send_payload();
        
        $display ($time, "[DRIVER] Sending payload %h", payload_rx);
        $display ($time, "ns:  [DRIVER] Sending in new packet END");
        $display ($time, "ns:  [DRIVER] Number of packets sent = %d", packets_sent);
        out_box.put(pkt2send);
        $display ($time,  "ns:  [DRIVER] The number of Packets in the Generator Mailbox = %d", in_box.num());
        $display ($time,  "ns:  [DRIVER] The number of Packets in the Driver Mailbox = %d", out_box.num());
        if(in_box.num() == 0) begin
				  break;
			  end
		  	// repeat(435) @(posedge uart.clk);
	    end
        
	join_none	
	$display ($time,  "[DRIVER] DRIVER Forking of process is finished");		
endtask


task Driver::send_payload();
    int clock_divide = 435;
    int count_data_bit_num = 0;
    bit [7:0] temp_8_data;
    bit [6:0] temp_7_data;
    bit [5:0] temp_6_data;
    bit [4:0] temp_5_data;
    if(payload_data_bit_num == 2'b11) temp_8_data = payload_rx;
    else if(payload_data_bit_num == 2'b10) begin
        for(int i=0;i<7;i++) begin
            temp_7_data[i] = payload_rx[i];
        end
    end
    else if(payload_data_bit_num == 2'b01) begin
        for(int i=0;i<6;i++) begin
            temp_6_data[i] = payload_rx[i];
        end
    end
    else if(payload_data_bit_num == 2'b00) begin
        for(int i=0;i<5;i++) begin
            temp_5_data[i] = payload_rx[i];
        end
    end
    //count data_bit_num
    if(payload_data_bit_num == 2'b00) count_data_bit_num=5;
    else if (payload_data_bit_num == 2'b01) count_data_bit_num = 6;
    else if(payload_data_bit_num == 2'b10) count_data_bit_num = 7;
    else if (payload_data_bit_num == 2'b11) count_data_bit_num = 8;
    //count stop_bit_num

	$display($time, "ns:  [DRIVER] Sending Payload Begin");
        uart.cb.parity_en <= payload_parity_en;
        uart.cb.parity_type <= payload_parity_type;
        uart.cb.data_bit_num <= payload_data_bit_num;
        uart.cb.stop_bit_num <= payload_stop_bit_num;
        
         @(posedge uart.clk);
         uart.cb.rx <= 1'b1;
        repeat(clock_divide) @(posedge uart.clk);
         //start_bit
        uart.cb.rx <= 1'b0;
        repeat(clock_divide) @(posedge uart.clk);
        //data
	    for(int i=0 ; i < count_data_bit_num ; i++) begin
	        if(count_data_bit_num == 8) begin
                uart.cb.rx <= temp_8_data[i];
                 repeat(clock_divide) @(posedge uart.clk);
            end
            else if(count_data_bit_num == 7) begin
            uart.cb.rx <= temp_7_data[i];
             repeat(clock_divide) @(posedge uart.clk);
            end
            else if(count_data_bit_num == 6) begin
            uart.cb.rx <= temp_6_data[i];
             repeat(clock_divide) @(posedge uart.clk);
            end
            else if(count_data_bit_num == 5) begin
             uart.cb.rx <= temp_5_data[i];
              repeat(clock_divide) @(posedge uart.clk);
        end
	    end
        //parity_bit
        if(payload_parity_en == 1) begin
            uart.cb.rx <= payload_parity_bit;
            repeat(clock_divide) @(posedge uart.clk);
        end
        // stop_bit
        if(payload_stop_bit_num == 1'b0) begin
            uart.cb.rx <= 1'b1;
            repeat(clock_divide) @(posedge uart.clk);
        end
        else if(payload_stop_bit_num == 1'b1) begin
            uart.cb.rx <= 1'b1;
            repeat(clock_divide) @(posedge uart.clk);
            uart.cb.rx <= 1'b1;
            repeat(clock_divide) @(posedge uart.clk);
        end
        
	// This is where we would be sending the data out into a queue for the Scoreboard
endtask

