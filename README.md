# rv32-singlecycle
Этот репозиторий содержит реализацию однотактного 32-битного процессора на основе архитектуры RISC-V

<h2>Реализованные инструкции</h2>

Процессор поддерживает следующие инструкции из набора **RV32I** (базовый набор инструкций RISC-V):

| Тип инструкций         | Инструкция | Описание                                                                 |
|------------------------|------------|--------------------------------------------------------------------------|
| **Арифметические**      | `ADD`      | Сложение двух регистров.                                                |
|                        | `SUB`      | Вычитание одного регистра из другого.                                   |
|                        | `ADDI`     | Сложение регистра с константой (immediate).                             |
|                        | `SLT`      | Установка флага, если значение одного регистра меньше другого.           |
|                        | `SLTI`     | Установка флага, если значение регистра меньше константы.               |
|                        | `SLTU`     | Беззнаковое сравнение (set less than unsigned).                         |
|                        | `SLTIU`    | Беззнаковое сравнение с константой.                                     |
| **Логические**          | `AND`      | Побитовое И.                                                            |
|                        | `OR`       | Побитовое ИЛИ.                                                          |
|                        | `XOR`      | Побитовое исключающее ИЛИ.                                              |
|                        | `ANDI`     | Побитовое И с константой.                                               |
|                        | `ORI`      | Побитовое ИЛИ с константой.                                             |
|                        | `XORI`     | Побитовое исключающее ИЛИ с константой.                                 |
| **Операции сдвига**     | `SLL`      | Логический сдвиг влево.                                                 |
|                        | `SRL`      | Логический сдвиг вправо.                                                |
|                        | `SRA`      | Арифметический сдвиг вправо.                                            |
|                        | `SLLI`     | Логический сдвиг влево с константой.                                    |
|                        | `SRLI`     | Логический сдвиг вправо с константой.                                   |
|                        | `SRAI`     | Арифметический сдвиг вправо с константой.                               |
| **Операции с памятью**  | `LW`       | Загрузка слова (32 бита) из памяти.                                     |
|                        | `SW`       | Сохранение слова (32 бита) в память.                                    |
| **Управляющие**         | `BEQ`      | Переход, если значения двух регистров равны.                            |
|                        | `BNE`      | Переход, если значения двух регистров не равны.                         |
|                        | `BLT`      | Переход, если значение одного регистра меньше другого.                  |
|                        | `BGE`      | Переход, если значение одного регистра больше или равно другому.        |
|                        | `BLTU`     | Беззнаковый переход, если значение одного регистра меньше другого.      |
|                        | `BGEU`     | Беззнаковый переход, если значение одного регистра больше или равно.    |
|                        | `JAL`      | Безусловный переход с сохранением адреса возврата (jump and link).      |
|                        | `JALR`     | Переход по регистру с сохранением адреса возврата (jump and link register). |
| **Прочие**              | `LUI`      | Загрузка верхних бит константы (load upper immediate).                  |
|                        | `AUIPC`    | Добавление константы к текущему значению PC (add upper immediate to PC). |

---

<h2>Требования</h2>

**Синтез и симуляция:** Для работы с проектом требуется установленный симулятор Icarus Verilog

**Тестовые программы:** Для тестирования используется ассемблер RISC-V

<h4>Загружайти иснструкции в `test\instruction\instruction.hex`</h4>

Укажите в `src/Instruction_Memory.v` в параметрах `parameter MEM_SIZE = 30` нужный размер памяти

<h2>Как использовать</h2>

**Клонируйте репозиторий:**

```bash
https://github.com/DaniilLeynov/rv32-singlecycle.git 
```

**Перейдите в директорию проекта:**

```bash
cd riscv-singlecycle\test
```

**Запустите симуляцию:**

```bash
iverilog -I ../src -o processor_tb -s Test_Banch ./Test_Banch.v ../src/Processor.v
vvp processor_tb
```
