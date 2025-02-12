module SE_I #(parameter  IN_WIDTH=12, parameter OUT_WIDTH = 32)
(input [IN_WIDTH-1:0] in, output [OUT_WIDTH-1:0] Imm_I);
    assign Imm_I = {{(OUT_WIDTH-12){in[IN_WIDTH-1]}}, in};
endmodule