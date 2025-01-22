
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

  int								num_tests = 0;
  int								num_tests_passed = 0;
  int								num_tests_failed = 0;
    bit [7:0] temp_in_8_data;
    bit [6:0] temp_in_7_data;
    bit [5:0] temp_in_6_data;
    bit [4:0] temp_in_5_data;

    bit [7:0] temp_out_8_data;
    bit [6:0] temp_out_7_data;
    bit [5:0] temp_out_6_data;
    bit [4:0] temp_out_5_data;

    bit parity_error_chk;
    bit parity_bit_chk=1'b0;

	// Declare the signals to be compared over here.
//----------------------------------------------------Define CG---------------------------------------------------------------------------------------------



//----------------------------------------------------------------------------------------------------------------------------------------------------------
  extern         function new(string name = "Scoreboard", out_box_type driver_mbox =null, rx_box_type receiver_mbox = null);
  extern virtual task start();
  extern virtual task check();
  extern         task result();
  real coverage1,coverage2;

  covergroup all_opeation_receive;
    CVP_PARITY_ERROR:coverpoint pkt_cmp.parity_error{
      option.auto_bin_max = {0};
      bins Noerror = {0};
      bins Error = {1};
    }
    CVP_RX_DONE:coverpoint pkt_cmp.rx_done{
      option.auto_bin_max = {0};
      bins Nodone = {0};
      bins Done = {1};
    }
    CVP_RTS_N:coverpoint pkt_cmp.rts_n{
      option.auto_bin_max = {0};
      bins Request = {0};
      bins Norequest = {1};
    }
    rx_data_cov:coverpoint pkt_cmp.rx_data {
      option.auto_bin_max = {0};
      bins zero ={0};
      bins allfs = {8'hff};
      bins specia1 = {8'h0a};
      bins special2 = {8'h05};
    }
    rx_cov: coverpoint pkt_sent.rx {
      option.auto_bin_max = {0};
      bins zero ={0};
      bins allfs = {8'hff};
      bins specia1 = {8'h0a};
      bins special2 = {8'h05};
    }
    data_bit_num_cov: coverpoint pkt_sent.data_bit_num {
      option.auto_bin_max = {0};
      bins fives_data_bit ={0};
      bins sixs_data_bit = {1};
      bins sevens_data_bit = {2};
      bins eights_data_bit = {3};
    }
    stop_bit_num_cov: coverpoint pkt_sent.stop_bit_num {
      option.auto_bin_max = {0};
      bins one_stop_bit ={0};
      bins two_stop_bit = {1};
    }
    parity_en_cov: coverpoint pkt_sent.parity_en {
      option.auto_bin_max = {0};
      bins enable ={0};
      bins ddisable = {1};
    }
    parity_type_cov: coverpoint pkt_sent.parity_type {
      option.auto_bin_max = {0};
      bins odd_parity ={0};
      bins even_parity = {1};
    }
    CVP_PARITY_EN: cross parity_en_cov, parity_type_cov,rx_cov,data_bit_num_cov,stop_bit_num_cov{
      option.cross_auto_bin_max = 0;
      bins Disable = binsof(parity_en_cov.enable) && binsof(parity_type_cov)&&
                     binsof(stop_bit_num_cov)&&binsof(data_bit_num_cov) &&binsof(rx_cov);
      bins Enable = binsof(parity_en_cov.ddisable) && binsof(parity_type_cov)&&
                      binsof(stop_bit_num_cov)&&binsof(data_bit_num_cov) &&binsof(rx_cov);
    }
    CVP_DATA_BIT_NUM: cross   parity_en_cov, parity_type_cov,rx_cov,data_bit_num_cov,stop_bit_num_cov{
      option.cross_auto_bin_max = 0;
      bins fives = binsof(data_bit_num_cov.fives_data_bit) && binsof(parity_en_cov)&&
                     binsof(stop_bit_num_cov)&&binsof(parity_type_cov) &&binsof(rx_cov);
      bins sixs = binsof(data_bit_num_cov.sixs_data_bit) && binsof(parity_en_cov)&&
                      binsof(stop_bit_num_cov)&&binsof(parity_type_cov) &&binsof(rx_cov);
      bins sevens = binsof(data_bit_num_cov.sevens_data_bit) && binsof(parity_en_cov)&&
                      binsof(stop_bit_num_cov)&&binsof(parity_type_cov) &&binsof(rx_cov);
      bins eights = binsof(data_bit_num_cov.eights_data_bit) && binsof(parity_en_cov)&&
                      binsof(stop_bit_num_cov)&&binsof(parity_type_cov) &&binsof(rx_cov);
    }
    CVP_STOP_BIT_NUM: cross   parity_en_cov, parity_type_cov,rx_cov,data_bit_num_cov,stop_bit_num_cov{
      // option.cross_auto_bin_max = 0;
      bins one = binsof(stop_bit_num_cov.one_stop_bit) && binsof(parity_en_cov)&&
                     binsof(data_bit_num_cov)&&binsof(parity_type_cov) &&binsof(rx_cov);
      bins two = binsof(stop_bit_num_cov.two_stop_bit) && binsof(parity_en_cov)&&
                      binsof(data_bit_num_cov)&&binsof(parity_type_cov) &&binsof(rx_cov);
    }
    CVP_PARITY_TYPE: cross   parity_en_cov, parity_type_cov,rx_cov,data_bit_num_cov,stop_bit_num_cov{
      option.cross_auto_bin_max = 0;
      bins odd = binsof(parity_type_cov.odd_parity) && binsof(parity_en_cov.enable)&&
                     binsof(data_bit_num_cov)&&binsof(stop_bit_num_cov) &&binsof(rx_cov);
      bins even = binsof(parity_type_cov.even_parity) && binsof(parity_en_cov.enable)&&
                      binsof(data_bit_num_cov)&&binsof(stop_bit_num_cov) &&binsof(rx_cov);
    }

  endgroup
endclass

function Scoreboard::new(string name, out_box_type driver_mbox, rx_box_type receiver_mbox);
  this.name           = name;
  if (driver_mbox == null) 
  driver_mbox         = new();
  if (receiver_mbox == null) 
  receiver_mbox       = new();
  this.driver_mbox    = driver_mbox;
  this.receiver_mbox  = receiver_mbox;


  all_opeation_receive =new();
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
  bit parity = 1'b0;
if(pkt_sent.data_bit_num == 2'b11) begin
    for(int i=0;i<8;i++) begin
            parity = parity ^ pkt_sent.rx[i];
            temp_in_8_data[i] = pkt_sent.rx[i];
            temp_out_8_data[i] = pkt_cmp.rx_data[i];
        end
end
    else if(pkt_sent.data_bit_num == 2'b10) begin
        for(int i=0;i<7;i++) begin
            parity = parity ^ pkt_sent.rx[i];
            temp_in_7_data[i] = pkt_sent.rx[i];
            temp_out_7_data[i] = pkt_cmp.rx_data[i];
        end
    end
    else if(pkt_sent.data_bit_num == 2'b01) begin
        for(int i=0;i<6;i++) begin
            parity = parity ^ pkt_sent.rx[i];
            temp_in_6_data[i] = pkt_sent.rx[i];
            temp_out_6_data[i] = pkt_cmp.rx_data[i];
        end
    end
    else if(pkt_sent.data_bit_num == 2'b00) begin
        for(int i=0;i<5;i++) begin
            parity = parity ^ pkt_sent.rx[i];
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
                parity_bit_chk = (parity ^ (~pkt_sent.parity_type));

            end
            6:begin
                parity_bit_chk = (parity ^ (~pkt_sent.parity_type));
            end
            7:begin
                parity_bit_chk = (parity ^ (~pkt_sent.parity_type));
            end
            8:begin
                parity_bit_chk = (parity ^ (~pkt_sent.parity_type));
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

  AP_RX_DATA8_CHECKER: assert (temp_in_8_data == pkt_cmp.rx_data) begin
    num_tests++;
    num_tests_passed++;
  $display("[CHECKER CORRECT] RX_DATA CORRECT");
  end
  else begin
    num_tests++;
    num_tests_failed++;
  $display("[CHECK RX FAIL]RX_DATA FAIL");
  end
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

  AP_RX_DATA7_CHECKER:assert (temp_in_7_data == temp_out_7_data) begin
    num_tests++;
    num_tests_passed++;
  $display("[CHECKER CORRECT] RX_DATA CORRECT");
    end
  else begin
    num_tests++;
    num_tests_failed++;
    $display("[CHECK RX FAIL]RX_DATA FAIL");
  end
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

  AP_RX_DATA6_CHECKER:assert (temp_in_6_data == temp_out_6_data) begin
    num_tests++;
    num_tests_passed++;
  $display("[CHECKER CORRECT] RX_DATA CORRECT");
    end
  else begin
    num_tests++;
    num_tests_failed++;
    $display("[CHECK RX FAIL]RX_DATA FAIL");
  end
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

  AP_RX_DATA5_CHECKER:assert (temp_in_5_data == temp_out_5_data) begin
    num_tests++;
    num_tests_passed++;
  $display("[CHECKER CORRECT] RX_DATA CORRECT");
    end
  else begin
    num_tests++;
    num_tests_failed++;
    $display("[CHECK RX FAIL]RX_DATA FAIL");
  end
  end

 AP_RTS_CHECKER:assert(((pkt_cmp.rx_done == 0)&&(pkt_cmp.rts_n ==1)) ||((pkt_cmp.rx_done == 1)&&(pkt_cmp.rts_n ==0))) begin
   num_tests++;
    num_tests_passed++;
  $display("[CHECKER RTS_N CORRECT ]RTS_N CORRECT");
 end
 else begin
    num_tests++;
    num_tests_failed++;
    $display("[FAIL]RTS_N FAIL");
 end
 AP_PARITY_BIT_CHECKER: assert (parity_bit_chk == pkt_sent.parity_bit) $display("[CHECKER PARITY_BIT CORRECT] PARITY_BIT CORRECT parity_bit_chk = %b, pkt_sent.parity_bit = %b,pkt_sent.rx_data=%b, pkt_sent.parity_bit=%b,parity_type=%b",parity_bit_chk,pkt_sent.parity_bit,pkt_sent.rx,pkt_sent.parity_bit,pkt_sent.parity_type);
   else $display("[CHECKER PARITY_BIT FAIL] PARITY_BIT ERROR parity_bit_chk = %b, pkt_sent.parity_bit = %b",parity_bit_chk,pkt_sent.parity_bit);
  AP_PARITY_ERROR_CHECKER: assert(parity_error_chk == pkt_cmp.parity_error) begin
    num_tests++;
    num_tests_passed++;
  $display("[CHECK PARITY_ERROR CORRECT] PARITY_ERROR CORRECT");
  end
else begin 
    num_tests++;
    num_tests_failed++;
    $display("[CHECK PARITY_ERROR ERROR] PARITY_ERROR ERROR \n\n");
end



all_opeation_receive.sample();
coverage1 = all_opeation_receive.get_coverage();
$display ($time, "      [SCOREBOARD -> COVERAGE] Coverage Result for cover 1 At present = %d", coverage1);
  // $display ($time, "      [SCOREBOARD -> COVERAGE] Coverage Result for cover 2 At present = %d", coverage_value2);
endtask

task Scoreboard::result();
  $display("Number tests : %0d, Pass: %0d, Fail: %0d",num_tests,num_tests_passed, num_tests_failed);
endtask



