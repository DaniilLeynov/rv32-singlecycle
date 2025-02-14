module Mux2 #(parameter WIDTH = 32) (
    input [WIDTH-1:0] in0,   
    input [WIDTH-1:0] in1,   
    input sel,                
    output reg [WIDTH-1:0] out  
);

    always @(*) begin
        case(sel)
        1'b0: out = in0;
        1'b1: out = in1;
        endcase    
    end

endmodule