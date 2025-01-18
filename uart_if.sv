
 interface uart_io(input logic clk);
   logic reset_n;
   logic  rx;
  logic [1:0] data_bit_num;
	logic stop_bit_num;
	logic parity_en;
	logic parity_type;
   logic [7:0] rx_data;
   logic rts_n;
   logic rx_done;
   logic parity_error;

 clocking cb @(posedge clk);
   default input #1 output #1;
   output rx;
   output data_bit_num;
   output stop_bit_num;
   output parity_en;
   output parity_type;
   input rx_data;
   input rts_n;
   input rx_done;
   input parity_error;
endclocking

modport TB (clocking cb,output reset_n,clk);

endinterface
