`ifndef OUTPUT_PACKET_SV
`define OUTPUT_PACKET_SV
 class OutputPacket;
    string name;
	reg rx;
	reg [1:0] data_bit_num;
	reg  stop_bit_num;
	reg parity_en;
	reg parity_type;
    reg [7:0] rx_data;
    reg rts_n;
    reg rx_done;
    reg parity_error;
    extern function new(string name = "Outputpacket");
	endclass

function OutputPacket::new(string name);
	this.name = name;
endfunction
`endif