# Low-Power-Configurable-Multi-Clock-Digital-System

A UART-controlled system with ALU operations and register file management.

## System Overview

- Receives commands from a master via **UART_RX**.
- Executes commands using ALU and Register File.
- Sends results back via **UART_TX**.
  
## Features
- Dual clock domain architecture
- 14 ALU operations
- UART communication interface
- Register file with 16 addressable locations
- Clock gating and synchronization

## Block Diagram
![System Diagram](docs/image/block_diagram.png)

## Clock Domains
1. **REF_CLK (50MHz) Domain**
   - Register File
   - ALU
   - System Controller
   - Clock Gating

2. **UART_CLK (3.6864MHz) Domain**
   - UART TX/RX
   - Clock Divider
   - Pulse Generator

## Supported Operations

### ALU Operations
- Addition, Subtraction, Multiplication, Division
- AND, OR, NAND, NOR, XOR, XNOR
- Comparisons: (A = B), (A > B)
- Shifts: A >> 1, A << 1

### Register File Operations
- Write and Read

## Command Format

| Command | Frames | Description |
|---|---|---|
| RF Write | 3 | Addr + Data |
| RF Read | 2 | Addr |
| ALU Op (with operands) | 4 | Operands + Function |
| ALU Op (no operands) | 2 | Function Only |

[Details of Each Block](docs/)
