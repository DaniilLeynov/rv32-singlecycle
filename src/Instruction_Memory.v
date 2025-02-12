module Instruction_memory #(parameter MEM_SIZE = 1)
(
    input [31:0] addr,
    output [31:0] data_out
);
    reg [31:0] memory [0:MEM_SIZE-1];
    assign data_out = memory[addr[31:2]];
    
    initial begin
        $readmemh("instruction.hex", memory);
        $display("Memory initialized from instruction.hex.");
    end
endmodule