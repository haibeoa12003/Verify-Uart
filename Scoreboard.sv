
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
    bit [7:0] temp_in_8_data;
    bit [6:0] temp_in_7_data;
    bit [5:0] temp_in_6_data;
    bit [4:0] temp_in_5_data;

    bit [7:0] temp_out_8_data;
    bit [6:0] temp_out_7_data;
    bit [5:0] temp_out_6_data;
    bit [4:0] temp_out_5_data;

    bit parity_error_chk;
    bit parity_bit_chk;

	// Declare the signals to be compared over here.
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
  int count_data_bit_num =0;
if(pkt_sent.data_bit_num == 2'b11) temp_in_8_data = pkt_sent.rx;
    else if(pkt_sent.data_bit_num == 2'b10) begin
        for(int i=0;i<7;i++) begin
            temp_in_7_data[i] = pkt_sent.rx[i];
            temp_out_7_data[i] = pkt_cmp.rx_data[i];
        end
    end
    else if(pkt_sent.data_bit_num == 2'b01) begin
        for(int i=0;i<6;i++) begin
            temp_in_6_data[i] = pkt_sent.rx[i];
            temp_out_6_data[i] = pkt_cmp.rx_data[i];
        end
    end
    else if(pkt_sent.data_bit_num == 2'b00) begin
        for(int i=0;i<5;i++) begin
            temp_in_5_data[i] = pkt_sent.rx[i];
            temp_out_5_data[i] = pkt_cmp.rx_data[i];
        end
    end
//tính số bit data 
if(pkt_sent.data_bit_num == 2'b00) count_data_bit_num=5;
    else if (pkt_sent.data_bit_num == 2'b01) count_data_bit_num = 6;
    else if(pkt_sent.data_bit_num == 2'b10) count_data_bit_num = 7;
    else if (pkt_sent.data_bit_num == 2'b11) count_data_bit_num = 8;

    //tính bit parity
    if(pkt_sent.parity_en == 1) begin
        case(count_data_bit_num)
            5: begin
                parity_bit_chk <= ((^temp_in_5_data) ^ pkt_sent.parity_type);

            end
            6:begin
                parity_bit_chk <= ((^temp_in_6_data) ^ pkt_sent.parity_type);
            end
            7:begin
                parity_bit_chk <= ((^temp_in_7_data) ^ pkt_sent.parity_type);
            end
            8:begin
                parity_bit_chk <= ((^temp_in_8_data) ^ pkt_sent.parity_type);
            end
            default: begin
                $display("Error: Parity bit not set");
                parity_bit_chk <= 1'b0;
            end
        endcase
        end
        else begin
            parity_bit_chk <= 1'b0;
        end


 
if(pkt_sent.data_bit_num == 2'b11) begin
   $display($time, "ns: [CHECKER] Checker Start\n\n");
  $display($time, "ns:  	[CHECK_RX_DATA] Golden Incoming rx_data = %b", temp_in_8_data);				
  $display($time, "ns:   [CHECKER] Pkt Contents: rx_data= %b,data_bit_num = %b,stop_bit_num = %b,parity_en = %b,parity_type = %b,parity_bit = %b", temp_in_8_data,pkt_sent.data_bit_num,pkt_sent.stop_bit_num,pkt_sent.parity_en,pkt_sent.parity_type,pkt_sent.parity_bit);
  $display($time, "ns:   [CHECKER] Pkt_cmp Contents: rx_data= %b, rx_done = %b,parity_error= %b ,rts_n = %b ", pkt_cmp.rx_data,pkt_cmp.rx_done,pkt_cmp.parity_error,pkt_cmp.rts_n);
  
  if(pkt_sent.parity_en ==1) begin
  if((parity_bit_chk == pkt_sent.parity_bit)&&(temp_in_8_data == pkt_cmp.rx_data)) parity_error_chk = 0;
  else parity_error_chk = 1;
  end
  else parity_error_chk = 0;

  AP_RX_DATA8_CHECKER: assert (temp_in_8_data == pkt_cmp.rx_data) $display("[CHECKER CORRECT] RX_DATA CORRECT");
  else $display("[CHECK RX FAIL]RX_DATA FAIL");
end
    else if(pkt_sent.data_bit_num == 2'b10) begin
        $display($time, "ns: [CHECKER] Checker Start\n\n");
        $display($time, "ns:  	[CHECK_RX_DATA] Golden Incoming rx_data = %b", temp_in_7_data);				
        $display($time, "ns:   [CHECKER] Pkt Contents: rx_data= %b,data_bit_num = %b,stop_bit_num = %b,parity_en = %b,parity_type = %b,parity_bit = %b", temp_in_7_data,pkt_sent.data_bit_num,pkt_sent.stop_bit_num,pkt_sent.parity_en,pkt_sent.parity_type,pkt_sent.parity_bit);
        $display($time, "ns:   [CHECKER] Pkt_cmp Contents: rx_data= %b, rx_done = %b,parity_error= %b ,rts_n = %b ", pkt_cmp.rx_data,pkt_cmp.rx_done,pkt_cmp.parity_error,pkt_cmp.rts_n);
  
  if(pkt_sent.parity_en ==1) begin
  if((parity_bit_chk == pkt_sent.parity_bit)&&(temp_in_7_data == temp_out_7_data)) parity_error_chk = 0;
  else parity_error_chk = 1;
  end
  else parity_error_chk = 0;

  AP_RX_DATA7_CHECKER:assert (temp_in_7_data == temp_out_7_data) $display("[CHECKER CORRECT] RX_DATA CORRECT");
  else $display("[CHECK RX FAIL]RX_DATA FAIL");
    end
    else if(pkt_sent.data_bit_num == 2'b01) begin
        $display($time, "ns: [CHECKER] Checker Start\n\n");
        $display($time, "ns:  	[CHECK_RX_DATA] Golden Incoming rx_data = %b", temp_in_6_data);			
        $display($time, "ns:   [CHECKER] Pkt Contents: rx_data= %b,data_bit_num = %b,stop_bit_num = %b,parity_en = %b,parity_type = %b,parity_bit=%b", temp_in_6_data,pkt_sent.data_bit_num,pkt_sent.stop_bit_num,pkt_sent.parity_en,pkt_sent.parity_type,pkt_sent.parity_bit);
        $display($time, "ns:   [CHECKER] Pkt_cmp Contents: rx_data= %b, rx_done = %b,parity_error= %b ,rts_n = %b ", pkt_cmp.rx_data,pkt_cmp.rx_done,pkt_cmp.parity_error,pkt_cmp.rts_n);
  
  if(pkt_sent.parity_en ==1) begin
  if((parity_bit_chk == pkt_sent.parity_bit)&&(temp_in_6_data == temp_out_6_data)) parity_error_chk = 0;
  else parity_error_chk = 1;
  end
  else parity_error_chk = 0;

  AP_RX_DATA6_CHECKER:assert (temp_in_6_data == temp_out_6_data) $display("[CHECKER CORRECT] RX_DATA CORRECT");
  else $display("[CHECK RX FAIL]RX_DATA FAIL");
    end
    else if(pkt_sent.data_bit_num == 2'b00) begin
        $display($time, "ns: [CHECKER] Checker Start\n\n");
        $display($time, "ns:  	[CHECK_RX_DATA] Golden Incoming rx_data = %b", temp_in_5_data);			
        $display($time, "ns:   [CHECKER] Pkt Contents: rx_data= %b,data_bit_num = %b,stop_bit_num = %b,parity_en = %b,parity_type = %b,parity_bit = %b", temp_in_5_data,pkt_sent.data_bit_num,pkt_sent.stop_bit_num,pkt_sent.parity_en,pkt_sent.parity_type,pkt_sent.parity_bit);
        $display($time, "ns:   [CHECKER] Pkt_cmp Contents: rx_data= %b, rx_done = %b,parity_error= %b ,rts_n = %b ", pkt_cmp.rx_data,pkt_cmp.rx_done,pkt_cmp.parity_error,pkt_cmp.rts_n);
  
  if(pkt_sent.parity_en ==1) begin
  if((parity_bit_chk == pkt_sent.parity_bit)&&(temp_in_5_data == temp_out_5_data)) parity_error_chk = 0;
  else parity_error_chk = 1;
  end
  else parity_error_chk = 0;

  RX_DATA5_CHECKER:assert (temp_in_5_data == temp_out_5_data) $display("[CHECK RX CORRECT] RX_DATA CORRECT");
  else $display("[CHECK RX FAIL]RX_DATA FAIL");
  end


 AP_RTS_CHECKER:assert(((pkt_cmp.rx_done == 1)&&(pkt_cmp.rts_n ==1)) ||((pkt_cmp.rx_done == 0)&&(pkt_cmp.rts_n ==0)))  $display("[CHECKER RTS_N CORRECT ]RTS_N CORRECT");
 else $display("[FAIL]RTS_N FAIL");
 AP_PARITY_BIT_CHECKER: assert (parity_bit_chk == pkt_sent.parity_bit) $display("[CHECKER PARITY_BIT CORRECT] PARITY_BIT CORRECT");
   else $display($time,"[CHECKER PARITY_BIT FAIL] PARITY_BIT ERROR");
  AP_PARITY_ERROR_CHECKER: assert(parity_error_chk == pkt_cmp.parity_error) $display("[CHECK PARITY_ERROR CORRECT] PARITY_ERROR CORRECT");
else $display("[CHECK PARITY_ERROR ERROR] PARITY_ERROR ERROR \n\n");
endtask

task Scoreboard::result();
  $display("Number tests : %0d, Pass: %0d, Fail: %0d",num_tests,num_tests_passed, num_tests_failed);
endtask

