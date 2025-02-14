module ALU(
    input [31:0] a, b,
    input [3:0] control,
    output reg [31:0] res,
    output zero
);
    assign zero = (res == 32'b0);  // Флаг нуля: равен ли результат нулю?
   
    always @(*) begin
        res = 32'b0;
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