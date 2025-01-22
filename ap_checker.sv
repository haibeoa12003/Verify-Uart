`include "uart_if.sv"
module rx_checker_module (uart_io uart);

    
//     property rx_done_implies_rts_n;
//     @(posedge uart.cb) 
//     (uart.cb.rx_done == 1) |-> (uart.cb.rts_n == 0);
//   endproperty

//   property rx_not_done_implies_rts_n_high;
//     @(posedge uart.cb) 
//     (uart.cb.rx_done == 0) |-> (uart.cb.rts_n == 1);
//   endproperty

//   ap_rx_done_rts_n_1: assert property (rx_done_implies_rts_n)
//   else $error("[ASSERTION FAIL] When rx_done is 1, rts_n should be 0");

//   ap_rx_done_rts_n_0: assert property (rx_not_done_implies_rts_n_high)
//   else $error("[ASSERTION FAIL] When rx_done is 0, rts_n should be 1");
    
    // property check_rx_done_prop;
    //   @(posedge uart.clk)
    // endproperty

    // AP_RX_DONE : assert property (check_rx_done_prop);  
endmodule