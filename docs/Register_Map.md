# Register Map

| Address | Name    | Description                     | Default |
|---------|---------|---------------------------------|---------|
| 0x0     | REG0    | ALU Operand A                   | -       |
| 0x1     | REG1    | ALU Operand B                   | -       |
| 0x2     | REG2    | UART Configuration              | 0x81    |
| 0x3     | REG3    | Clock Divider Ratio             | 0x20    |
| 0x4-0x15| RF      | General Purpose Registers       | -       |

**UART Configuration (REG2)**
```verilog
REG2[0]   : Parity Enable (1=Enabled)
REG2[1]   : Parity Type (0=Even, 1=Odd)
REG2[7:2] : Prescale Value
```
