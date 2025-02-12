`timescale 1ns / 1ps

module Test_Banch;

    // Параметры
    reg clk;  // Тактовый сигнал

    // Сигналы процессора
    wire [31:0] pc_imem, imem_out, instruction, RD1, RD, res_alu, 
                RD2, WD3, imm_b, imm_i, imm_j, imm_s, mux5_alu, 
                in2_mux5, mux3_alu;
    wire [6:0] opcode, func7;
    wire [2:0] func3, scrB, memi;
    wire [4:0] A1, A2, A3;
    wire [3:0] aop;
    wire jal, jalr, enpc, b, rfwe, comp, mewe, ws;
    wire [1:0] scrA;

    // Создание экземпляра процессора
    Processor uut (
        .clk(clk)
    );

    // Генерация тактового сигнала
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Тактовый сигнал с периодом 10ns
    end

    // Процесс инициализации и применения тестов
    initial begin
        // Инициализация сигналов
        $display("Starting simple test...");

        // Подготовка и загрузка инструкций из файла
        // Убедитесь, что файл "instruction.hex" существует и находится в каталоге симулятора
        $readmemh("instruction.hex", uut.imem.memory);  // Загружаем инструкции в память

        // Добавляем задержку, чтобы процессор успел начать работу
        #110;  // Задержка 10 тактов

        // Проверка на выходе ALU
        $monitor("ALU inputs: a = %b, b = %b, control = %b, result = %b", ///////////////////////////////////////////////////
                 uut.mux3_alu, uut.mux5_alu, uut.aop, uut.res_alu);
	//$writememh("memory_dump.txt", data_memory);
        //$monitor("ALU inputs: func3 = %b, func7 = %b, control = %b, result = %b", 
                // uut.imem_out[14:12], uut.imem_out[31:25], uut.aop, uut.res_alu);
        // Пример проверки состояния: если PC не равен нулю, то процессор начал работать
        if (uut.pc_imem != 32'h0) begin
            $display("Processor is running correctly, PC = %h", uut.pc_imem);
        end else begin
            $display("Processor is not running correctly.");
        end

        // Завершаем тест
        #50; // Подождем немного для выполнения инструкций
        $stop;  // Остановка симуляции
    end

    // Завершение симуляции
    initial begin
        #1000; // Время симуляции (например, 1000ns)
        $finish;
    end
endmodule
