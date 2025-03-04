# ALU Operations

## Supported Functions
| Code | Operation | Description          |
|------|-----------|----------------------|
| 0x0  | ADD       | Addition             |
| 0x1  | SUB       | Subtraction          |
| 0x2  | MUL       | Multiplication       |
| ...  | ...       | ...                  |

## Block Signals
```verilog
// ALU port
ALU #(
        parameter OP_WIDTH = 8,
        parameter FUN_WIDTH = 4,
        parameter OUT_WIDTH = OP_WIDTH + OP_WIDTH
    ) (
        input   wire    [OP_WIDTH-1:0]      A, B,
        input   wire                        CLK, RST, Enable,
        input   wire    [FUN_WIDTH-1:0]     ALU_FUN,
        output  reg                         OUT_VALID,
        output  reg     [OUT_WIDTH-1:0]     ALU_OUT
    );
