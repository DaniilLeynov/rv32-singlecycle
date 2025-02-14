module PC(
    input jalr, enpc, jal, comp, b, clk,
    input [31:0] RD1, imm_j, imm_b,
    output reg [31:0] pc
);
    wire [31:0] mux2_pc, addr_control_mux2, pc_addr_control, const_4, mux2_imm_j_imm_b, adrr_input;
    wire c;
    assign const_4 = 32'b00000000000000000000000000000100;
    assign c = jal |(comp & b);
    initial begin
        pc = 32'b0;
    end
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
    // always @(posedge clk or negedge clk) begin
    //     if (~clk) begin  // условие сброса (положительный фронт)
    //         pc <= 32'b0;  // Устанавливаем PC в 0 при сбросе
    //     end else if (enpc) begin
    //         pc <= mux2_pc;  // В противном случае обновляем PC
    //     end
    // end
     always @(posedge clk) begin
        if (enpc) begin
            pc <= mux2_pc;  // Переход по адресу
        end else begin
            pc <= pc + const_4;  // Автоматическое увеличение на 4 для обычных инструкций
        end
    end

endmodule