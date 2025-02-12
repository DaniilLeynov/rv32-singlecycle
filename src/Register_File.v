module Register_File#(parameter OUT_WIDTH = 32)(
    input clk,
    input WE3, 
    input [4:0] A1, A2, A3, 
    input [OUT_WIDTH-1:0] WD3,
    output [OUT_WIDTH-1:0] RD1, RD2
);
    reg[OUT_WIDTH-1:0] registers [31:0];
    
    assign RD1 = registers[A1];
    assign RD2 = registers[A2];
    always @(posedge clk) begin
        if(WE3 && A3 != 0) begin
            registers[A3] <= WD3;
            end
    end
    initial begin
        registers[0] = 32'b0;
    end
endmodule
