`timescale 1ns / 1ps



module Test_Banch;

   
    reg clk;  

    
    wire [31:0] pc_imem, imem_out, instruction, RD1, RD, res_alu, 
                RD2, WD3, imm_b, imm_i, imm_j, imm_s, mux5_alu, 
                in2_mux5, mux3_alu;
    wire [6:0] opcode, func7;
    wire [2:0] func3, scrB, memi;
    wire [4:0] A1, A2, A3;
    wire [3:0] aop;
    wire jal, jalr, enpc, b, rfwe, comp, mewe, ws;
    wire [1:0] scrA;

   
    Processor uut (
        .clk(clk)
        
    );

    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  
    end

 
    initial begin
        
        $display("Starting simple test...");
        $dumpfile("wavefrom.vcd");
        $dumpvars(0, Test_Banch);
       
        $readmemh("instruction/instruction.hex", uut.imem.memory);  

        
        #0;  // Задержка 

        
        $monitor("Time = %0t | PC = %b | ALU inputs: a = %b, b = %b, control = %b, result = %b", 
                 $time, uut.pc_imem, uut.mux3_alu, uut.mux5_alu, uut.aop, uut.res_alu);

 
        if (uut.pc_imem != 32'h0) begin
            $display("Processor is running correctly, PC = %b", uut.pc_imem);
        end else begin
            $display("Processor is not running correctly.");
        end

        
        #50; 
        $display("State after 1st instruction:");
        $display("PC = %b, ALU Result = %h", uut.pc_imem, uut.res_alu);
        
        #50;  
        $display("State after 2nd instruction:");
        $display("PC = %b, ALU Result = %h", uut.pc_imem, uut.res_alu);

        #50;  
        $display("State after 3rd instruction:");
        $display("PC = %b, ALU Result = %h", uut.pc_imem, uut.res_alu);

        
        $stop;  
    end

    
    initial begin
        #1000; 
        $finish;
    end
endmodule