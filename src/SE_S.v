module SE_S #(parameter OUT_WIDTH = 32)
(input [6:0] imm_11_5, input [4:0] imm_4_0,
 output [OUT_WIDTH-1: 0] imm_s);
   wire [11:0] full_imm;
   assign full_imm = {imm_11_5, imm_4_0};
   assign imm_s = {{(OUT_WIDTH-12){full_imm[11]}}, full_imm};
endmodule