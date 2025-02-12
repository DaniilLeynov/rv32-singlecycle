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