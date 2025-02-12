module SE_J #(parameter OUT_WIDTH = 32)
(input imm_20, 
input [9:0] imm_10_1,
input imm_11,
input [7:0] imm_19_12,
output [OUT_WIDTH-1:0] imm_j);
    wire  [20:0] full_imm;
    assign full_imm = {imm_20, imm_19_12, imm_11, imm_10_1, 1'b0};
    assign imm_j = {{(OUT_WIDTH-21){full_imm[20]}},full_imm};
endmodule