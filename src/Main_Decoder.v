
module Main_Decoder(
    input [6:0] Opcode,
    input [2:0] func3,
    input [6:0] func7,
    output reg ws,
    output reg [2:0] memi,
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