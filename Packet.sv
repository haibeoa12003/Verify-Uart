`ifndef PACKET_SV
`define PACKET_SV
 class Packet;
    string name;

	rand reg [7:0] rx;
	randc reg [1:0] data_bit_num;
	randc reg  stop_bit_num;
	randc reg parity_en;
	randc reg parity_type;
  randc reg parity_bit;
    extern function new(string name = "Packet");

    constraint base_test {
		 rx dist	{0:=1000,[1:4]:=1,8'h05:=1000, [6:9]:=1000,8'h0A:=1000, [11:159]:=1, 8'hA0:=1000,[161:254]:=1 , 8'hff:=1000};
    // rx inside {8'b10101010};
        data_bit_num inside {[0:3]};
        stop_bit_num inside {[0:1]};
        parity_en inside {[0:1]};
        parity_type inside {[0:1]};
        parity_bit inside {[0:1]};
  }
    // constraint data_bit_num {
    //     data_bit_num inside {[5:8]};
    // }
    // constraint stop_bit {
    //     stop_bit_num inside {[0:1]};
    // }
    // constraint parity_en{
    //     parity_en inside {[0:1]};
    // }
    // constraint parity_type {
    //     parity_type inside {[0:1]} ;
    // }
    // constrant rx{
    //     rx inside {[0:8'hff]};
    // }
    // constraint limit{
    //     rx dist	{0:=1000,[1:4]:=1,8'h05:=1000, [6:9]:=1000,8'h0A:=1000, [11:159]:=1, 8'hA0:=1000,[161:254]:=1 , 8'hff:=1000};
    //     data_bit_num inside {[5:8]};
    //     stop_bit_num inside {[0:1]};
    //     parity_en inside {[0:1]};
    //     parity_type inside {[0:1]};
    //     parity_bit inside {[0:1]};
    // }
endclass

function Packet::new(string name = "Packet");
	this.name = name;
endfunction
`endif