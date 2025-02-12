module SE_B #(parameter OUT_WIDTH = 32)
(
    input imm_11,
    input imm_12,
    input [3:0] imm_4_1, 
    input [5:0] imm_10_5,
    output [OUT_WIDTH-1:0] imm_b
);
    wire [12:0] full_imm;
    
    assign full_imm = {imm_12, imm_11, imm_10_5, imm_4_1, 1'b0};
    
    assign imm_b = {{(OUT_WIDTH-13){full_imm[12]}}, full_imm};
endmodule