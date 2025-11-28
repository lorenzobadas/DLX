# DLX Processor

This repository contains an RTL implementation, verification infrastructure and toolchain used to develop and validate a pipelined DLX-like processor.

Navigate to the `scripts/` directory to learn how to build the project, run simulations, and launch the synthesis and PnR flow.

## What this project contains
- **RTL (VHDL):** full processor datapath and control in `src/`.
- **Testbenches:** a collection of testbenches under `src/tb/` .  Use the `Makefile` simulation targets to build and run them.
- **Python emulator:** a single-cycle emulator at `emulator/dlx_emulator.py` used for fast software-level debugging and producing cycle-by-cycle traces that can be compared against simulation waveforms.
- **Assembler / tooling:** Assembly test programs in `asm/`. `scripts/instructions.json` and `scripts/instructions_pkg_generator.py` to generate the VHDL instruction package used by the RTL.
- **Synthesis & Place-and-Route (PnR):** scripts and automation for synthesis and place-and-route.
- **Automation:** a top-level `Makefile` wires the whole flow: simulation, synthesis, post-synthesis simulation, PnR, emulator runs and log generation.

## Architecture & Features
- The design implements a classic 5-stage pipeline with full datapath and control in VHDL (IF, ID, EX, MEM, WB).
- **Hazard handling:** the core implements full hazard handling in hardware:
  - A dedicated Hazard Unit detects load-use and other hazards and inserts NOPs / stalls automatically.
  - A Forwarding Unit provides EX/MEM and MEM/WB forwarding to avoid unnecessary stalls.
- **Branch/Jump resolution in ID stage:** branch/jump decisions are resolved in the Instruction Decode stage to minimize control stalls.

## Supported Instructions

| Mnemonic | Type | Notes |
|----------|:----:|-------|
| ADD      | R    | Add |
| SUB      | R    | Subtract |
| AND      | R    | Bitwise AND |
| OR       | R    | Bitwise OR |
| XOR      | R    | Bitwise XOR |
| SLL      | R    | Shift left |
| SRL      | R    | Shift right logical |
| SRA      | R    | Shift right arithmetic |
| SEQ      | R    | Set equal |
| SNE      | R    | Set not-equal |
| SLT      | R    | Set less-than |
| SGT      | R    | Set greater-than |
| SLE      | R    | Set less-or-equal |
| SGE      | R    | Set greater-or-equal |
| ADDU     | R    | Add unsigned |
| SUBU     | R    | Sub unsigned |
| SLTU     | R    | Set less-than unsigned |
| SGTU     | R    | Set greater-than unsigned |
| SLEU     | R    | Set less-or-equal unsigned |
| SGEU     | R    | Set greater-or-equal unsigned |
| NOP      | R    | No operation |
| J        | J    | Jump |
| JAL      | I    | Jump-and-link (writes link to R31) |
| JR       | I    | Jump-register |
| JALR     | I    | Jump-and-link register (writes link to R31) |
| BEQZ     | I    | Branch if register == 0 |
| BNEZ     | I    | Branch if register != 0 |
| ADDI     | I    | Add immediate |
| SUBI     | I    | Subtract immediate |
| ANDI     | I    | Bitwise AND immediate |
| ORI      | I    | Bitwise OR immediate |
| XORI     | I    | Bitwise XOR immediate |
| SLLI     | I    | Shift-left immediate |
| SRLI     | I    | Shift-right logical immediate |
| SRAI     | I    | Shift-right arithmetic immediate |
| SEQI     | I    | Set-equal immediate |
| SNEI     | I    | Set-not-equal immediate |
| SLTI     | I    | Set-less-than immediate |
| SGTI     | I    | Set-greater-than immediate |
| SLEI     | I    | Set-less-or-equal immediate |
| SGEI     | I    | Set-greater-or-equal immediate |
| ADDUI    | I    | Add unsigned immediate |
| SUBUI    | I    | Subtract unsigned immediate |
| SLTUI    | I    | Set-less-than unsigned immediate |
| SGTUI    | I    | Set-greater-than unsigned immediate |
| SLEUI    | I    | Set-less-or-equal unsigned immediate |
| SGEUI    | I    | Set-greater-or-equal unsigned immediate |
| LB       | I    | Load byte signed |
| LBU      | I    | Load byte unsigned |
| LH       | I    | Load halfword signed |
| LHU      | I    | Load halfword unsigned |
| LW       | I    | Load word |
| SB       | I    | Store byte |
| SH       | I    | Store halfword |
| SW       | I    | Store word |

## Emulator
- The Python emulator `emulator/dlx_emulator.py` loads an assembled `.mem` program and can run in plain or `--debug` mode to print cycle-by-cycle register dumps and a final processor state snapshot. This trace is intended to be compared against waveform/simulator outputs to speed up debugging.

## Synthesis & Place-and-Route
- Synthesis and place-and-route are automated via the `Makefile`
- The flow supports three synthesis options (controlled by the `FLATTEN` variable in the `Makefile`): `all`, `auto`, and `none`. These options are provided to trade off flattening behavior for debugability vs optimization.

## Synthesis & PnR Results

Key figures from the `all` (full-flattening) configuration:

- Post-synthesis clock period: 1.50 ns
- Post-PnR theoretical minimum period: 1.38 ns ≈ 724.6 MHz
- Post-synthesis total cell area: 14,434.8 µm²
- Post-synthesis total power: 7.5492 mW
  - Internal Power: 6.8274 mW
  - Switching Power: 463.743 µW
  - Leakage Power: 258.00 µW

- Critical path:
  1. EX-MEM pipeline registers (source flip-flop)
  2. Forwarding unit (forwardB logic)
  3. Execution stage multiplexers (mux rdata2 etc.)
  4. ALU block (p4 adder sub-block: XOR layer, carry generator, sum generator)
  5. ALU comparator and final logic
  6. Final multiplexer
  7. EX-MEM pipeline register input (destination flip-flop)

  - The largest incremental delays are inside the ALU sub-blocks (adder and comparator logic).

## Key files & locations
- RTL: `src/`
- Makefile and scripts: `scripts/`
- Testbench sources: `src/tb/`
- Assembly tests: `asm/`
- Simulation results: `sim/`
- Synthesis results: `syn/`
- PnR results: `pnr/`
- Emulator: `emulator/dlx_emulator.py`
