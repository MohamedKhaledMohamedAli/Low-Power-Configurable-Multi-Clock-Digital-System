# Pulse Generator

## Description
Generates a pulse signal when a level signal is detected.

## Block Diagram

![PULSE_GEN](docs/PULSE_GEN.png)

## Interface and Signal Description

| Port | Direction | Width | Description |
|---|---|---|---|
| CLK | IN | 1 | Clock Signal (UART_TX Clock) |
| RST | IN | 1 | Active Low Reset |
| LVL_SIG | IN | 1 | Level Signal from UART_TX |
| PULSE_SIG | OUT | 1 | Generated Pulse Signal |
