module Adder_control(
    input [31:0] a,b,
    output [31] c
);
    assign c = a + b;
endmodule
module ALU(
    input [31:0] a, b,
    input [3:0] control,
    output reg [31:0] res,
    output zero
);
    assign zero = (res == 32'b0);  // Флаг нуля: равен ли результат нулю?

    always @(*) begin
        case(control)
            4'b0000: res = a & b;              // AND
            4'b0001: res = a | b;              // OR
            4'b0010: res = a + b;              // ADD
            4'b0011: res = a ^ b;              // XOR
            4'b0100: res = a << b[4:0];        // Сдвиг влево
            4'b0101: res = a >> b[4:0];        // Сдвиг вправо
            4'b0110: res = a - b;              // SUB
            4'b0111: res = (a < b) ? 1 : 0;    // Знаковое сравнение (a < b)
            4'b1000: res = $signed(a) >>> b[4:0];  // Арифметический сдвиг вправо
            4'b1100: res = ~(a | b);           // NOR
            4'b1110: res = ($unsigned(a) < $unsigned(b)) ? 1 : 0; // Беззнаковое сравнение (a < b)
            4'b1111: res = (a < b) ? 1 : 0;    // Знаковое сравнение (a < b)
            default: res = 32'b0;              // Если код команды не найден
        endcase
    end
endmodule
module Data_Memory #(parameter MEM_SIZE = 1024)(
    input clk,
    input WE,                   // Запись в память
    input [2:0] I,              // Указывает на команду (тип загрузки: байт, полуслово, слово и т.д.)
    input [31:0] A,             // Адрес памяти
    input [31:0] WD,            // Данные для записи
    output reg [31:0] RD        // Данные для чтения
);
    reg [31:0] memory [0:MEM_SIZE-1]; // Память на 1024 слова

    always @(posedge clk) begin
        if (WE) begin
            // Запись в память
            case(I)
                3'b000: begin
                    memory[A][7:0] <= WD[7:0];  // Записываем байт
                end
                3'b001: begin
                    memory[A][15:0] <= WD[15:0]; // Записываем полуслово
                end
                3'b010: begin
                    memory[A] <= WD;             // Записываем слово
                end
                3'b100: begin
                    memory[A][7:0] <= WD[7:0];  // Записываем байт (LBU)
                end
                3'b101: begin
                    memory[A][15:0] <= WD[15:0]; // Записываем полуслово (LHU)
                end
            endcase
        end
        
        // Чтение из памяти
        case(I)
            3'b000: begin
                RD <= {{24{memory[A][7]}}, memory[A][7:0]};  // LB: Загрузка байта с расширением знака
            end
            3'b001: begin
                RD <= {{16{memory[A][15]}}, memory[A][15:0]}; // LH: Загрузка полуслова с расширением знака
            end
            3'b010: begin
                RD <= memory[A]; // LW: Загрузка слова
            end
            3'b100: begin
                RD <= {24'b0, memory[A][7:0]};  // LBU: Загрузка байта без знака
            end
            3'b101: begin
                RD <= {16'b0, memory[A][15:0]}; // LHU: Загрузка полуслова без знака
            end
            default: begin
                RD <= 32'b0; // В случае невалидного состояния
            end
        endcase
    end
endmodule
module Instruction_memory #(parameter MEM_SIZE = 1024)
(
    input [31:0] addr,
    output [31:0] data_out
);
    reg [31:0] memory [0:MEM_SIZE-1];
    assign data_out = memory[add[31:2]];
    
    initial begin
        $readmemh("instruction.hex", memory);
    end
endmodule

module Main_Decoder(
    input [6:0] Opcode,
    input [2:0] func3,
    input [6:0] func7,
    output reg ws,
    output reg [1:0] memi,
    output reg mewe,
    output reg [3:0] aop, // ALU операция
    output reg [2:0] scrB,
    output reg [1:0] scrA,
    output reg jalr, enpc, jal, b, rfwe
);

    always @(*) begin
        ws = 0;
        memi = 2'b00;
        mewe = 0;
        aop = 4'b0000;
        scrB = 3'b000;
        scrA = 2'b00;
        jalr = 0;
        enpc = 0;
        jal = 0;
        b = 0;
        rfwe = 0;

        case (Opcode)
            7'b0110011: begin // R-type инструкции
                rfwe = 1;
                case (func3)
                    3'b000: begin
                        case (func7)
                            7'b0000000: aop = 4'b0010; // ADD
                            7'b0100000: aop = 4'b0110; // SUB
                        endcase
                    end
                    3'b001: aop = 4'b0100; // SLL
                    3'b010: aop = 4'b0111; // SLT
                    3'b011: aop = 4'b1111; // SLTU
                    3'b100: aop = 4'b0011; // XOR
                    3'b101: begin
                        case (func7)
                            7'b0000000: aop = 4'b0101; // SRL
                            7'b0100000: aop = 4'b1000; // SRA
                        endcase
                    end
                    3'b110: aop = 4'b0001; // OR
                    3'b111: aop = 4'b0000; // AND
                    default: aop = 4'b0000;
                endcase
            end

            7'b0010011: begin // I-type ALU инструкции
                rfwe = 1;
                scrB = 1;
                mewe = 0;
                scrA = 0;
                case (func3)
                    3'b000: aop = 4'b0010; // ADDI
                    3'b010: aop = 4'b0111; // SLTI
                    3'b011: aop = 4'b1111; // SLTIU
                    3'b100: aop = 4'b0011; // XORI
                    3'b110: aop = 4'b0001; // ORI
                    3'b111: aop = 4'b0000; // ANDI
                    3'b001: aop = 4'b0100; // SLLI
                    3'b101: begin
                        case (func7)
                            7'b0000000: aop = 4'b0101; // SRLI
                            7'b0100000: aop = 4'b1000; // SRAI
                        endcase
                    end
                    default: aop = 4'b0000;
                endcase
            end

            7'b0000011: begin // Load инструкции
                scrB = 1;
                scrA = 0;
                ws = 1;
                rfwe = 1;
                case (func3)
                    3'b000: begin
                        aop = 4'b0010; // LB
                        memi = 3'b000;
                    end
                    3'b001: begin
                        aop = 4'b0010; // LH
                        memi = 3'b001;
                    end
                    3'b010: begin
                        aop = 3'b010; // LW
                        memi = 3'b010;
                    end
                    3'b100: begin
                        aop = 3'b100; // LBU
                        memi = 3'b100;
                    end
                    3'b101: begin
                        aop = 4'b0010; // LHU
                        memi = 3'b101;
                    end
                    default: aop = 4'b0000;
                endcase
            end

            7'b0100011: begin // Store инструкции
                scrA = 0;
                scrB = 3;
                rfwe = 0;
                mewe = 1;
                case (func3)
                    3'b000: begin
                        aop = 4'b0010; // SB
                        memi = 3'b000;
                    end
                    3'b001: begin
                        aop = 4'b0010; // SH
                        memi = 3'b001;
                    end
                    3'b010: begin
                        aop = 3'b010; // SW
                        memi = 3'b010;
                    end
                    default: aop = 4'b0000;
                endcase
            end

            7'b1100011: begin // Branch инструкции
                scrA = 0;
                scrB = 0;
                case (func3)
                    3'b000: begin
                        b = 1;
                        aop = 4'b0010; // BEQ
                    end
                    3'b001: begin
                        b = 1;
                        aop = 4'b0111; // BNE
                    end
                    3'b100: begin
                        b = 1;
                        aop = 4'b0111; // BLT
                    end
                    3'b101: begin
                        b = 1;
                        aop = 4'b1111; // BGE
                    end
                    3'b110: begin
                        b = 1;
                        aop = 4'b0001; // BLTU
                    end
                    3'b111: begin
                        b = 1;
                        aop = 4'b0000; // BGEU
                    end
                    default: aop = 4'b0000;
                endcase
            end

            7'b0110111: begin // LUI инструкция (U-type)
                rfwe = 1;
                aop = 4'b0010; // ADDI, для вычислений с 20-битной константой
                scrB = 2; // Указание на константу в инструкции
            end

            7'b0010111: begin // AUIPC инструкция (U-type)
                rfwe = 1;
                aop = 4'b0010; // ADDI, вычисление адреса
                scrB = 2; // Указание на константу в инструкции
            end

            7'b1101111: begin // JAL инструкция (J-type)
                jal = 1;
                rfwe = 1;
                aop = 4'b0010; // Добавить смещение
                enpc = 1; // Установить флаг для перехода
            end

            7'b1100111: begin // JALR инструкция (I-type)
                jalr = 1;
                rfwe = 1;
                aop = 4'b0010; // Добавить смещение
                enpc = 1; // Установить флаг для перехода
            end

            default: begin
                aop = 4'b0000;
                rfwe = 0;
                mewe = 0;
                ws = 0;
                scrA = 0;
                scrB = 0;
                jalr = 0;
                enpc = 0;
                jal = 0;
                b = 0;
            end
        endcase
    end
endmodule
module Mux2 #(parameter WIDTH = 32) (
    input [WIDTH-1:0] in0,   
    input [WIDTH-1:0] in1,   
    input sel,                
    output reg [WIDTH-1:0] out  
);

    always @(*) begin
        if (sel)               
            out = in1;
        else                   
            out = in0;
    end

endmodule
module Mux3 #(parameter WIDTH = 32) (
    input [WIDTH-1:0] in0, in1, in2,    
    input [1:0] scrA,                    
    output reg [WIDTH-1:0] out          
);

    always @(*) begin
        case(scrA)
            2'b00: out = in0;  
            2'b01: out = in1;  
            2'b10: out = in2;  
            default: out = {WIDTH{1'b0}}; 
        endcase
    end

endmodule
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
module PC(
    input jalr, enpc, jal, comp, b, clk,
    input [31:0] RD1, imm_j, imm_b,
    output [31:0] pc
);
    wire [31:0] mux2_pc, addr_control_mux2, pc_addr_control, const_4, mux2_imm_j_imm_b, adrr_input;
    wire c;
    assign const_4 = 32'd6;
    assign c = jal |(comp & b);
    Mux2  mux_4_mux2(
        .in0(const_4),        
        .in1(mux2_imm_j_imm_b),       
        .sel(c),        
        .out(adrr_input)        
    );
    Mux2  mux2_mux_4_imm_j_imm_b(
        .in0(imm_j),        
        .in1(imm_b),       
        .sel(b),        
        .out(mux2_imm_j_imm_b)        
    );
    Adder_control addr(
        .a(adrr_input),
        .b(pc),
        .c(addr_control_mux2)
    );
    Mux2  mux_RD1_addr(
        .in0(addr_control_mux2),        
        .in1(RD1),       
        .sel(jalr),        
        .out(mux2_pc)        
    );
    //pc
    always @(posedge clk) begin
        if (enpc) begin
            pc <= mux2_pc; 
        end
    end


endmodule
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

    // Исправление расширения сигнала
    assign in2_mux5 = {{12{pc_imem[31]}}, pc_imem[31:12]}; // Расширение сигнала

    // Подключение декодера
    Main_Decoder decoder_inst (
        .Opcode(pc_imem[6:0]),
        .func3(pc_imem[2:0]),
        .func7(pc_imem[31:25]),
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
        .comp(comp),
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
        .A1(pc_imem[24:20]),
        .A2(pc_imem[24:20]),       
        .A3(pc_imem[11:7]),      
        .WD3(WD3),     
        .RD1(RD1),     
        .RD2(RD2)      
    );

    // Подключение расширителей
    SE_B se_b_inst (
        .imm_11(pc_imem[7]),
        .imm_12(pc_imem[31]),
        .imm_4_1(pc_imem[11:8]),
        .imm_10_5(pc_imem[30:25]),
        .imm_b(imm_b)
    );

    SE_I #(
        .IN_WIDTH(12),   
        .OUT_WIDTH(32)   
    ) se_i_inst (
        .in(pc_imem[31:20]),  
        .Imm_I(imm_i)            
    );

    SE_J #(
        .OUT_WIDTH(32)  
    ) se_j_inst (
        .imm_20(pc_imem[20]),      
        .imm_19_12(pc_imem[19:12]),
        .imm_11(pc_imem[11]),      
        .imm_10_1(pc_imem[10:1]),  
        .imm_j(imm_j)       
    );

    SE_S #(
        .OUT_WIDTH(32)  
    ) se_s_inst (
        .imm_11_5(pc_imem[11:5]),  
        .imm_4_0(pc_imem[4:0]),   
        .imm_s(imm_s)         
    );

    // Подключение мультиплексора для ALU
    Mux5 #(
        .WIDTH(32)  
    ) mux5_inst (
        .in0(RD2),    
        .in1(imm_i),    
        .in2(in2_mux5),    
        .in3(imm_s),    
        .in4(4),    
        .scrB(scrB),  
        .out(mux5_alu)     
    );

    // Подключение второго мультиплексора для ALU
    Mux3 #(
        .WIDTH(32)  
    ) mux3_inst (
        .in0(RD1),    
        .in1(pc_imem),    
        .in2(0),    
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
        .MEM_SIZE(1024)  
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
module Register_File#(parameter OUT_WIDTH = 32)(
    input clk,
    input WE3, 
    input [4:0] A1, A2, A3, 
    // это адресы. дял адресации 32 ячеек регистров нужно 5 бит (2^5 = 32)
    input [OUT_WIDTH-1:0] WD3,
    output [OUT_WIDTH-1:0] RD1, RD2
);
    reg[OUT_WIDTH-1:0] registers [OUT_WIDTH-1:0];
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
module SE_B #(parameter OUT_WIDTH = 32)
(
    input imm_11,
    input imm_12,
    input [3:0] imm_4_1, 
    input [6:0] imm_10_5,
    output [OUT_WIDTH-1:0] imm_b
);
    wire [12:0] full_imm;
    
    assign full_imm = {imm_12, imm_11, imm_10_5, imm_4_1, 1'b0};
    
    assign imm_b = {{(OUT_WIDTH-13){full_imm[12]}}, full_imm};
endmodule
module SE_B #(parameter OUT_WIDTH = 32)
(
    input imm_11,
    input imm_12,
    input [3:0] imm_4_1, 
    input [6:0] imm_10_5,
    output [OUT_WIDTH-1:0] imm_b
);
    wire [12:0] full_imm;
    
    assign full_imm = {imm_12, imm_11, imm_10_5, imm_4_1, 1'b0};
    
    assign imm_b = {{(OUT_WIDTH-13){full_imm[12]}}, full_imm};
endmodule
module SE_I #(parameter  IN_WIDTH=12, parameter OUT_WIDTH = 32)
(input [IN_WIDTH-1:0] in, output [OUT_WIDTH-1:0] Imm_I);
    assign Imm_I = {{(OUT_WIDTH-12){in[IN_WIDTH-1]}}, in};
endmodule
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
module SE_S #(parameter OUT_WIDTH = 32)
(input [6:0] imm_11_5, input [4:0] imm_4_0,
 output [OUT_WIDTH-1: 0] imm_s);
   wire [11:0] full_imm;
   assign full_imm = {imm_11_5, imm_4_0};
   assign imm_s = {{(OUT_WIDTH-12){full_imm[11]}}, full_imm};
endmodule