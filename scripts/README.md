# DLX CPU Project Makefile

## Table of Contents
- [Introduction](#introduction)
- [Included Directories and Files](#included-directories-and-files)
- [Makefile Targets and Instructions](#makefile-targets-and-instructions)
    - [Instructions Package Generation](#instructions-package-generation)
    - [Simulation Targets](#simulation-targets)
    - [Synthesis Targets](#synthesis-targets)
    - [Place and Route Targets](#place-and-route-targets)
    - [Emulator Targets](#emulator-targets)
    - [Cleaning Up](#cleaning-up)
- [Execution Instructions](#execution-instructions)

## Introduction

This Makefile automates the complete digital design flow for the DLX CPU project, including simulation, synthesis, place and route, and emulation. It provides a comprehensive set of targets to build, test, and implement the DLX processor design.

## Included Directories and Files

The Makefile interacts with several key directories and files within the project:

- **Source Directories:**
  - **`src/`**: Contains all VHDL source files for the DLX CPU components
  - **`src/pkg/`**: Package files including instructions, ALU instructions, control signals, and memory packages
  - **`src/tb/`**: Testbench files for various components
  - **`asm/`**: Assembly programs for testing the CPU

- **Scripts and Tools:**
  - **`scripts/`**: Contains TCL and Python scripts for simulation control, instruction package generation, and assembly processing
  - **`emulator/`**: Python-based DLX emulator for reference simulation

- **Build Directories:**
  - **`sim/`**: Simulation outputs, compiled objects, and waveform data
  - **`syn/`**: Synthesis results and reports
  - **`pnr/`**: Place and route results

## Makefile Targets and Instructions

The Makefile provides several targets that cover different stages of the digital design flow:

### Instructions Package Generation
- **Automatic Generation**  
  The `instructions_pkg.vhd` file is automatically generated from JSON instructions definition using Python script before simulation targets.

### Simulation Targets

- **`t2-shifter-tb`**  
  Compiles and simulates the T2 shifter testbench using QuestaSim.

- **`p4-adder-tb`**  
  Compiles and simulates the P4 adder testbench using QuestaSim.

- **`alu-tb`**  
  Compiles and simulates the ALU testbench, which integrates both T2 shifter and P4 adder components.

- **`cpu-tb`**  
  Compiles and simulates the complete CPU testbench:
  - Automatically assembles the specified ASM file into instruction memory
  - Runs the DLX emulator to generate reference outputs
  - Simulates the complete CPU with the test program

- **`post-syn-cpu-tb`**  
  Performs post-synthesis simulation of the CPU using the gate-level netlist generated from synthesis.

### Synthesis Targets

- **`synthesis`**  
  Runs logic synthesis using Design Compiler with configurable flattening options:
  - **`FLATTEN=all`**: Full flattening (default)
  - **`FLATTEN=auto`**: Automatic flattening for delay optimization
  - **`FLATTEN=none`**: No flattening
  
  Results are stored in `syn/results_$(FLATTEN)/` directory.

### Place and Route Targets

- **`pnr`**  
  Performs automated place and route using Innovus with batch mode.
  - **`FLATTEN=all`**: Full flattening (default)
  - **`FLATTEN=auto`**: Automatic flattening for delay optimization
  - **`FLATTEN=none`**: No flattening

### Emulator Targets

- **Automatic Emulation**
  The DLX emulator is automatically run during CPU testbench preparation to generate reference outputs for simulation comparison.

### Cleaning Up

- **`clean_sim`**  
  Removes all simulation-generated files and directories.

- **`clean_syn`**  
  Cleans synthesis results for the current flattening configuration.

- **`clean_pnr`**  
  Cleans place and route results for the current flattening configuration.

- **`purge_syn`**  
  Removes all synthesis results regardless of configuration.

- **`purge_pnr`**  
  Removes all place and route results regardless of configuration.

- **`clean`**  
  Comprehensive clean that removes all generated files from simulation, synthesis, and place and route.

## Execution Instructions

1. **Navigate to the Project Root:**  
   Ensure you are in the git repository root directory containing the Makefile.

2. **Run Component Simulations:**  
   To simulate individual components:
   ```bash
   $ make t2-shifter-tb
   $ make p4-adder-tb  
   $ make alu-tb
   ```

3. **Run CPU Simulation with Custom Assembly:**  
   To simulate the complete CPU with a specific assembly program:
   ```bash
   $ make cpu-tb ASM_FILE=../asm/my_program.asm
   ```

4. **Run Complete Synthesis Flow:**  
   To perform synthesis with specific flattening:
   ```bash
   $ make synthesis FLATTEN=auto
   ```

5. **Run Post-Synthesis Simulation:**  
   To verify the gate-level netlist with specific flattening:
   ```bash
   $ make post-syn-cpu-tb FLATTEN=auto
   ```

6. **Run Place and Route:**  
   To perform automated place and route with specific flattening:
   ```bash
   $ make pnr FLATTEN=auto
   ```

7. **Clean Build Environment:**  
   To remove all generated files:
   ```bash
   $ make clean
   ```

> **Note:** The Makefile requires QuestaSim for simulation, Design Compiler for synthesis, and Innovus for place and route. Ensure these tools are properly installed and licensed before execution.