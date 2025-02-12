`include "Main_Decoder.v"
`include "PC.v"
`include "Instruction_memory.v"
`include "Register_File.v"
`include "SE_B.v"
`include "ALU.v"
`include "Data_Memory.v"
`include "SE_J.v"
`include "SE_I.v"
`include "SE_S.v"
`include "Adder_Control.v"
`include "Mux2.v"
`include "Mux3.v"
`include "Mux5.v"
module Processor(
    input clk
);
    
    wire [31:0] pc_imem, imem_out, instruction, RD1, RD, res_alu, 
                RD2, WD3, imm_b, imm_i, imm_j, imm_s, mux5_alu, 
                in2_mux5, mux3_alu;
    wire [6:0] opcode, func7;
    wire [2:0] func3, scrB, memi;
    wire [4:0] A1, A2, A3;
    wire [3:0] aop;
    wire jal, jalr, enpc, b, rfwe, comp, mewe, ws;
    wire [1:0] scrA;

    // Расширение сигнала (можно оставить, если требуется)
    assign in2_mux5 = {{12{imem_out[31]}}, imem_out[31:12]}; // Расширение сигнала

    // Подключение декодера
    Main_Decoder decoder_inst (
        .Opcode(imem_out[6:0]),
        .func3(imem_out[14:12]),
        .func7(imem_out[31:25]),
        .ws(ws),
        .memi(memi),
        .mewe(mewe),
        .aop(aop),
        .scrB(scrB),
        .scrA(scrA),
        .jalr(jalr),
        .enpc(enpc),
        .jal(jal),
        .b(b),
        .rfwe(rfwe)
    );

    // Подключение счетчика команд (PC)
    PC pc(
        .jalr(jalr),
        .enpc(enpc),
        .jal(jal),
        .comp(comp),     // Здесь также нужно подключить сигнал comp
        .b(b),
        .clk(clk),
        .RD1(RD1),
        .imm_j(imm_j),
        .imm_b(imm_b),
        .pc(pc_imem)
    );

    // Подключение памяти инструкций
    Instruction_memory imem(
        .addr(pc_imem),
        .data_out(imem_out)
    );

    // Подключение регистра файлов
    Register_File #(.OUT_WIDTH(32)) reg_file (
        .clk(clk),
        .A1(imem_out[19:15]),
        .A2(imem_out[24:20]),
        .A3(imem_out[11:7]),
        .WD3(WD3),
        .RD1(RD1),
        .RD2(RD2),
        .WE3(rfwe)
    );

    // Подключение расширителей
    SE_B se_b_inst (
        .imm_11(imem_out[7]),
        .imm_12(imem_out[31]),
        .imm_4_1(imem_out[11:8]),
        .imm_10_5(imem_out[30:25]),
        .imm_b(imm_b)
    );

    SE_I #(
        .IN_WIDTH(12),   
        .OUT_WIDTH(32)   
    ) se_i_inst (
        .in(imem_out[31:20]),
        .Imm_I(imm_i)            
    );

    SE_J #(
        .OUT_WIDTH(32)  
    ) se_j_inst (
        .imm_20(imem_out[20]),
        .imm_19_12(imem_out[19:12]),
        .imm_11(imem_out[11]),
        .imm_10_1(imem_out[10:1]),
        .imm_j(imm_j)       
    );

    SE_S #(
        .OUT_WIDTH(32)  
    ) se_s_inst (
        .imm_11_5(imem_out[11:5]),
        .imm_4_0(imem_out[4:0]),
        .imm_s(imm_s)         
    );

    // Подключение мультиплексоров для ALU
    Mux5 #(
        .WIDTH(32)  
    ) mux5_inst (
        .in0(RD2),
        .in1(imm_i),
        .in2(in2_mux5),
        .in3(imm_s),
        .in4(32'd4),
        .scrB(scrB),
        .out(mux5_alu)     
    );

    Mux3 #(
        .WIDTH(32)  
    ) mux3_inst (
        .in0(RD1),
        .in1(pc_imem), ///что
        .in2(32'd0),
        .scrA(scrA),
        .out(mux3_alu)      
    );

    // Подключение ALU
    ALU alu_inst (
        .a(mux3_alu),
        .b(mux5_alu),
        .control(aop),
        .res(res_alu),
        .zero(comp)
    );

    // Подключение памяти данных
    Data_Memory #(
        .MEM_SIZE(3)  // Увеличиваем размер памяти до 1024
    ) data_mem_inst (
        .clk(clk),
        .WE(mewe),
        .I(memi),
        .A(res_alu),
        .WD(RD2),
        .RD(RD)
    );

    // Подключение мультиплексора для данных
    Mux2 #(
        .WIDTH(32)  
    ) mux2_inst (
        .in0(res_alu),
        .in1(RD),
        .sel(ws),
        .out(WD3)
    );
endmodule