module Mux5 #(parameter WIDTH = 32) (
    input [WIDTH-1:0] in0, in1, in2, in3, in4,  
    input [2:0] scrB,                            
    output reg [WIDTH-1:0] out                 
);

    always @(*) begin
        case(scrB)
            3'b000: out = in0;  
            3'b001: out = in1;  
            3'b010: out = in2;  
            3'b011: out = in3;  
            3'b100: out = in4;  
            default: out = {WIDTH{1'b0}};  
        endcase
    end

endmodule