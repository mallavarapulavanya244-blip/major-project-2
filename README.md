# Major Project 2 - UART TX/RX Loopback

UART Transmitter + Receiver in SystemVerilog with Loopback Testing.

## How it Works
TX sends 8-bit data -> RX receives same data (Loopback)
Start bit (0) + 8 Data bits + Stop bit (1)

## Result
Sent A5, Received = a5 -> PASS: A5 Correct!
Sent 3C, Received = 3c -> PASS: 3C Correct!

## Files
- `design.sv` - UART TX + RX modules
- `testbench.sv` - Testbench with Loopback
- `waveform(2).png` - Simulation Waveform

## Tools
SystemVerilog, EDA Playground, GitHub

## Concepts
UART Protocol, FSM, Baud Timing, Loopback Testing

![Simulation Waveform](waveform(2).png)








