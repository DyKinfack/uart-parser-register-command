Project Overview

This project implements a UART-based command interface for an FPGA using pure Verilog HDL.
It allows an external host (e.g. PC, microcontroller) to read and write internal registers via simple UART commands.
The design was developed and verified without any physical FPGA board, using simulation-driven development.
Project Goals

Design a complete UART communication chain in Verilog
Implement a command parser FSM for protocol decoding
Provide a scalable register file with read/write access
Clean separation between RX, parser, register logic, and TX
Full verification using self-written testbenches

System Architecture

UART_RX  →  CMD_PARSER  →  REGISTER_FILE  →  UART_TX
│                │
└── control ─────┘

Incoming bytes are received via UART_RX
The CMD_PARSER decodes commands and addresses
REGISTER_FILE performs read/write operations
UART_TX sends read data back to the host

Module Descriptions

1- uart_parser_register_TOP

Top-level module integrating all submodules.
Responsibilities:
Connect UART RX → parser → register file → UART TX
Provide clean system-level interfaces

2- UART_RX

Receives serial UART data and outputs valid parallel bytes.
Key signals:
rx_valid – pulses when a byte is received
rx_data[7:0] – received data Byte

3- cmd_parser

Finite State Machine (FSM) that decodes UART commands.
Supported commands:
WRITE: write data to a register
READ: read data from a register
Outputs:
reg_we, reg_re
w_addr, r_addr
w_data

4- register_file

Implements a small memory-mapped register bank.
Features:
Independent read/write addressing
Status signal generation
TX trigger generation for read operations

5- UART_TX

Transmits parallel data bytes serially via UART.
Key signals:
TX_start – starts transmission
TX – serial output
busy – transmission Status

Testbenches

✔ cmd_parser_tb
Verifies FSM behavior
Ensures correct command decoding
Checks correct generation of control signals

✔ register_file_tb
Verifies register write/read functionality
Confirms address decoding
Validates output data Consistency

✔ uart_parser_register_TOP_tb
Full system-level verification
UART stimulus generation (bit-accurate)
End-to-end write & read command testing

Tools & Technologies

Language: Verilog HDL
Simulation: ModelSim / Questa / Vivado Simulator
Target: FPGA-independent

Possible Extensions
Interrupt support
Burst read/write commands
AXI-lite interface
FIFO buffering
CRC / checksum support

DEUTSCHE VERSION

Projektübersicht

Dieses Projekt implementiert eine UART-basierte Befehlsschnittstelle für ein FPGA in reinem Verilog HDL.
Über UART können interne Register gelesen und beschrieben werden.
Die Entwicklung erfolgte ohne reales FPGA-Board, ausschließlich simulationsbasiert.

Projektziele

Entwicklung einer vollständigen UART-Kommunikationskette
Entwurf eines FSM-basierten Command Parsers
Skalierbares Register-File mit Lese-/Schreibzugriff
Saubere Modultrennung
Vollständige Verifikation durch Testbenches

Systemarchitektur

UART_RX  →  CMD_PARSER  →  REGISTER_FILE  →  UART_TX

Modulbeschreibung

1- uart_parser_register_TOP
Top-Modul zur Integration aller Komponenten.

2- UART_RX
Empfängt serielle UART-Daten und stellt parallele Bytes bereit.

3-  cmd_parser
FSM zur Auswertung von UART-Befehlen.
Funktionen:
Erkennung von READ- und WRITE-Kommandos
Adress- und Datenauswertung

4-  register_file
Registerbank mit separaten Lese- und Schreibzugriffen.

5- UART_TX
Sendet gelesene Registerdaten per UART zurück.
Testbenches
✔ cmd_parser_tb
Verifikation der FSM-Zustände
Korrekte Signalsteuerung
✔ register_file_tb
Test von Schreib-/Leseoperationen
✔ uart_parser_register_TOP_tb
Gesamtsystem-Test mit realistischem UART-Timing

Werkzeuge

Verilog HDL
ModelSim / Questa / Vivado Simulator

Erweiterungsmöglichkeiten

Interrupt-Logik
Erweiterte Protokolle
AXI-Integration
FIFO-Strukturen

Author: Dylann Kinfack
Project Type: FPGA / RTL Design / UART Interface
