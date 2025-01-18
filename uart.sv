module uart (
  input  clk,//
  input  reset_n,//
  input  rx,//
  input  cts_n,
  output tx,
  output rts_n,//
  input  [7:0] tx_data,
  input  [1:0] data_bit_num,//
  input  stop_bit_num,//
  input  parity_en,//
  input  parity_type,//
  input  start_tx,
  output [7:0] rx_data,//
  output tx_done,
  output rx_done,//
  output parity_error//
);

  // Internal Wires
  wire clk_tx;
  wire clk_rx;
  wire Tpl_18;
  wire Tpl_19;
  wire Tpl_20;
  wire Tpl_21;
  wire [7:0] Tpl_22;
  wire [1:0] Tpl_23;
  wire Tpl_24;
  wire Tpl_25;
  wire Tpl_26;
  wire Tpl_27;
  logic Tpl_28;
  logic Tpl_29;
  logic [1:0] Tpl_30;
  logic [1:0] Tpl_31;
  logic [2:0] Tpl_32;
  logic [2:0] Tpl_33;
  logic [1:0] Tpl_34;
  logic [1:0] Tpl_35;
  logic [7:0] Tpl_36;
  wire Tpl_37;
  wire Tpl_38;
  wire Tpl_39;
  wire Tpl_40;
  wire [1:0] Tpl_41;
  wire Tpl_42;
  wire Tpl_43;
  wire Tpl_44;
  wire [7:0] Tpl_45;
  wire Tpl_46;
  logic Tpl_47;
  logic Tpl_48;
  logic [1:0] Tpl_49;
  logic [1:0] Tpl_50;
  logic [3:0] Tpl_51;
  logic [3:0] Tpl_52;
  logic [1:0] Tpl_53;
  logic [3:0] Tpl_54;
  logic [1:0] Tpl_55;
  logic [7:0] Tpl_56;
  wire Tpl_57;
  wire Tpl_58;
  wire Tpl_59;
  wire Tpl_60;
  wire Tpl_61;
  logic [4:0] Tpl_62;
  logic [8:0] Tpl_63;

  // Assigning inputs and outputs to internal signals
  assign Tpl_18 = clk;
  assign Tpl_19 = reset_n;
  assign Tpl_20 = clk_tx;
  assign Tpl_21 = cts_n;
  assign Tpl_22 = tx_data;
  assign Tpl_23 = data_bit_num;
  assign Tpl_24 = stop_bit_num;
  assign Tpl_25 = parity_en;
  assign Tpl_26 = parity_type;
  assign Tpl_27 = start_tx;
  assign tx = Tpl_28;
  assign tx_done = Tpl_29;

  assign Tpl_37 = clk;
  assign Tpl_38 = reset_n;
  assign Tpl_39 = clk_rx;
  assign Tpl_40 = rx;
  assign Tpl_41 = data_bit_num;
  assign Tpl_42 = stop_bit_num;
  assign Tpl_43 = parity_en;
  assign Tpl_44 = parity_type;
  assign rx_data = Tpl_45;
  assign rts_n = Tpl_46;
  assign rx_done = Tpl_47;
  assign parity_error = Tpl_48;

  assign Tpl_58 = clk;
  assign Tpl_59 = reset_n;
  assign clk_tx = Tpl_60;
  assign clk_rx = Tpl_61;

  // Determine the number of data bits
  //Tpl_32: Lưu trữ số bit dữ liệu được chọn. Giá trị này sẽ được dùng trong bộ đếm bit ở bộ truyền, để biết khi nào thì kết thúc quá trình truyền bit dữ liệu.
//Tpl_36: Lưu trữ các bit dữ liệu thực tế được chọn từ Tpl_22.
  always @(*)
  begin
    case (Tpl_23)
      2'b00: begin
        Tpl_32 = 3'd4;
        Tpl_36 = Tpl_22[4:0];
      end
      2'b01: begin
        Tpl_32 = 3'd5;
        Tpl_36 = Tpl_22[5:0];
      end
      2'b10: begin
        Tpl_32 = 3'd6;
        Tpl_36 = Tpl_22[6:0];
      end
      2'b11: begin
        Tpl_32 = 3'd7;
        Tpl_36 = Tpl_22[7:0];
      end
      default: Tpl_32 = 3'd7;
    endcase
  end

  // Determine the number of stop bits and parity bit (if enabled)
  always @(*)
  begin
    case ({{Tpl_25, Tpl_24}})
      2'b00: Tpl_34 = 2'd0; // 0 bit parity, 1 stop bit
      2'b01: Tpl_34 = 2'd1; // 0 bit parity, 2 stop bits     => count from 0 -> tpl_34
      2'b10: Tpl_34 = 2'd1; //1 bit parity, 1 stop bits
      2'b11: Tpl_34 = 2'd2; //1 bit parity, 2 stop bits
      default: Tpl_34 = 2'd0;
    endcase
  end

  // State machine for transmitter
  always @(posedge Tpl_18 or negedge Tpl_19)
  begin
    if (~Tpl_19)
    begin
      Tpl_30 <= 2'b00;
    end
    else
    begin
      Tpl_30 <= Tpl_31;
      case (Tpl_30)
        2'b00: begin
          Tpl_33 <= 0;
          Tpl_35 <= 0;
        end
        2'b10: begin
          if (Tpl_20)
          begin
            Tpl_33 <= (Tpl_33 + 1);
          end
          else
            Tpl_33 <= Tpl_33;
        end
        2'b11: begin
          if (Tpl_20)
          begin
            Tpl_35 <= (Tpl_35 + 1);
          end
          else
            Tpl_35 <= Tpl_35;
        end
        default: begin
          Tpl_33 <= 0;
          Tpl_35 <= 0;
        end
      endcase
    end
  end

  // Next state logic for transmitter state machine
  always @(*)
  begin
    case (Tpl_30)
      2'b00: begin
        if (((Tpl_27 && (!Tpl_21)) && Tpl_20))
        begin
          Tpl_31 = 2'b01;
        end
        else
          Tpl_31 = 2'b00;
      end
      2'b01: begin
        if (Tpl_20)
        begin
          Tpl_31 = 2'b10;
        end
        else
          Tpl_31 = 2'b01;
      end
      2'b10: begin
        if (Tpl_20)
        begin
          if ((Tpl_33 == Tpl_32))
          begin
            Tpl_31 = 2'b11;
          end
          else
            Tpl_31 = 2'b10;
        end
        else
          Tpl_31 = 2'b10;
      end
      2'b11: begin
        if (Tpl_20)
        begin
          if ((Tpl_35 == Tpl_34))
          begin
            Tpl_31 = 2'b00;
          end
          else
            Tpl_31 = 2'b11;
        end
        else
          Tpl_31 = 2'b11;
      end
      default: Tpl_31 = 2'b00;
    endcase
  end

  // Output logic for the transmitter
  always @(*)
  begin
    case (Tpl_30)
      2'b00: begin
        Tpl_28 = 1'b1;
      end
      2'b01: begin
        Tpl_28 = 1'b0;
      end
      2'b10: begin
        Tpl_28 = Tpl_22[Tpl_33];
      end
      2'b11: begin
        if (Tpl_25)
        begin
          Tpl_28 = (Tpl_26 ? (^Tpl_36) : (~^Tpl_36));
        end
        else
          Tpl_28 = 1'b1;
      end
      default: Tpl_28 = 1'b1;
    endcase
  end

  // Transmitter Done flag
  //Reset: Khi có reset ( Tpl_19 - tương ứng reset_n ở mức thấp).
  //Kết thúc truyền: Khi bộ truyền đã hoàn tất việc truyền tất cả các bit dữ liệu và các bit stop/parity.
  //Trạng thái tiếp theo là trạng thái nghỉ: Khi bộ trạng thái đã chuyển về trạng thái nghỉ.
  always @(posedge Tpl_18 or negedge Tpl_19)
  begin
    if (~Tpl_19)
    begin
      Tpl_29 <= 1'b1;
    end
    else
    begin
      if (((Tpl_20 && (Tpl_30 == 2'b11)) && (Tpl_35 == Tpl_34)))
      begin
        Tpl_29 <= 1'b1;
      end
      else if ((Tpl_31 == 2'b00))
      begin
        Tpl_29 <= 1'b1;
      end
      else
        Tpl_29 <= 1'b0;
    end
  end
//  RECEIVER
  // Determine the number of bits for receiving based on data_bit_num
  always @(*)
  begin
    case (Tpl_41)
      2'b00: Tpl_52 = 4'd5;
      2'b01: Tpl_52 = 4'd6;
      2'b10: Tpl_52 = 4'd7;
      2'b11: Tpl_52 = 4'd8;
      default: Tpl_52 = 4'd8;
    endcase
  end

  // Determine how many stop bits are required
  always @(*)
  begin
    case ({{Tpl_43, Tpl_42}})
      2'b00: Tpl_53 = 2'd1;
      2'b01: Tpl_53 = 2'd2;
      2'b10: Tpl_53 = 2'd2;
      2'b11: Tpl_53 = 2'd3;
      default: Tpl_53 = 2'd1;
    endcase
  end

  // Next state logic for receiver state machine
  always @(*)
  begin
    case (Tpl_49)
      2'b00: begin
        if ((Tpl_51 == 15))
        begin
          Tpl_50 = 2'b01;
        end
        else
          Tpl_50 = 2'b00;
      end
      2'b01: begin
        if (((Tpl_51 == 15) && (Tpl_54 == Tpl_52)))
        begin
          Tpl_50 = 2'b10;
        end
        else
          Tpl_50 = 2'b01;
      end
      2'b10: begin
        if (((Tpl_51 == 15) && (Tpl_55 == Tpl_53)))
        begin
          Tpl_50 = 2'b00;
        end
        else
          Tpl_50 = 2'b10;
      end
      default: Tpl_50 = 2'b00;
    endcase
  end

  // Receiver State machine
  always @(posedge Tpl_37 or negedge Tpl_38)
  begin
    if (~Tpl_38)
    begin
      Tpl_49 <= 2'b00;
      Tpl_54 <= 0;
      Tpl_55 <= 0;
      Tpl_51 <= 0;
    end
    else
    begin
      Tpl_49 <= Tpl_50;
      case (Tpl_49)
        2'b00: begin
          Tpl_54 <= 0;
          Tpl_55 <= 0;
          if (Tpl_39)
          begin
            if (((!Tpl_40) || (Tpl_51 != 0)))
            begin
              Tpl_51 <= (Tpl_51 + 1'b1);
            end
            else if ((Tpl_51 == 15))
            begin
                Tpl_51 <= 0;
            end
          end
          else
            Tpl_51 <= Tpl_51;
        end
        2'b01: begin
          if (Tpl_39)
          begin
            Tpl_51 <= (Tpl_51 + 1'b1);
            if ((Tpl_51 == 8))
            begin
              Tpl_54 <= (Tpl_54 + 1);
              Tpl_56[Tpl_54] <= Tpl_40;
            end
            else if ((Tpl_51 == 15))
            begin
                Tpl_51 <= 0;
            end
          end
          else
            Tpl_51 <= Tpl_51;
        end
        2'b10: begin
          if (Tpl_39)
          begin
            Tpl_51 <= (Tpl_51 + 1);
            if ((Tpl_51 == 8))
            begin
              Tpl_55 <= (Tpl_55 + 1);
            end
             else if ((Tpl_51 == 15))
            begin
                Tpl_51 <= 0;
            end
          end
          else
            Tpl_51 <= Tpl_51;
        end
      endcase
    end
  end

  // Determine if receiver is done and if there is a parity error
  always @(*)
  begin
    case (Tpl_49)
      2'b00: begin
        Tpl_47 = 0;
      end
      2'b01: begin
        Tpl_47 = 0;
      end
      2'b10: begin
        Tpl_47 = ((Tpl_51 == 15) && (Tpl_55 == Tpl_53));
        Tpl_48 = Tpl_57;
      end
      default: begin
        Tpl_47 = 0;
      end
    endcase
  end
  //parity_en = 0 => parity_error=0
  //Assigning values for various signals
  assign Tpl_46 = Tpl_47; //rts_n is set to high when the receiver is done receiving
  assign Tpl_45 = Tpl_56; // received data is passed out to rx_data
  assign Tpl_57 = (Tpl_43 ? ((^Tpl_45) == Tpl_44) : 1'b0); // parity error is calculated here
  assign Tpl_61 = (Tpl_62 == 0);
  assign Tpl_60 = (Tpl_63 == 0);

  // Create clock for Receiver
  always @(posedge Tpl_58 or negedge Tpl_59)
  begin
    if (~Tpl_59)
    begin
      Tpl_62 <= 0;
    end
    else
    begin
      if ((Tpl_62 == 27))
      begin
        Tpl_62 <= 0;
      end
      else
        Tpl_62 <= (Tpl_62 + 1);
    end
  end

  // Create clock for Transmitter
  always @(posedge Tpl_58 or negedge Tpl_59)
  begin
    if (~Tpl_59)
    begin
      Tpl_63 <= 0;
    end
    else
    begin
      if ((Tpl_63 == 434))
      begin
        Tpl_63 <= 0;
      end
      else
        Tpl_63 <= (Tpl_63 + 1);
    end
  end

endmodule
