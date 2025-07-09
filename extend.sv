module extend(input logic [2:0] immCntrl,
                input logic [24:0] immSrc,
                output logic [31:0] immExt
               );

  localparam [2:0]
             IMM_TYPE_SHAMT   = 3'b001,
             IMM_TYPE_I    = 3'b010,
             IMM_TYPE_S    = 3'b011,
             IMM_TYPE_B    = 3'b100,
             IMM_TYPE_U    = 3'b101,
             IMM_TYPE_J    = 3'b110;
  always_comb
  begin
    case (immCntrl)
      IMM_TYPE_SHAMT:
        immExt = {27'b0,immSrc[17:13]};
      IMM_TYPE_I:
        immExt = {{20{immSrc[24]}},immSrc[24:13]};
      IMM_TYPE_S:
        immExt = {{20{immSrc[24]}},immSrc[24:18],immSrc[4:0]};
      IMM_TYPE_B:
        immExt = {{20{immSrc[24]}},immSrc[0],immSrc[23:18],immSrc[4:1],1'b0};
      IMM_TYPE_U:
        immExt = {immSrc[24:5],12'b0};
      IMM_TYPE_J:
        immExt = {{12{immSrc[24]}},immSrc[12:5],immSrc[13],immSrc[23:14],1'b0};
      default:
        immExt = 0;
    endcase
  end
endmodule
