# DLX Architecture Outline
## Introduction
The architecture for the developed DLX is based on the Tomasulo Algorithm.
Additionally, the architecture implements speculative execution and in-order commit.
It can be divided into the two following blocks:
1. Frontend
2. Backend

These two blocks can be further divided into the differents stages of the instruction pipeline.
## Frontend
The frontend is responsible for the following steps:
1. Fetch
2. Decode
3. Issue

The main components of the frontend are:
- Program Counter (PC)
- Instruction Cache
- Branch Predictor
- Decode Unit
- Register File
- Register Alias Table (RAT)
- Reorder Buffer (ROB)

The ROB plays a crucial role both in the frontend and the backend. In particular in the frontend, it is in charge of keeping the original order of the instructions.

## Backend
The backend is responsible for the following steps:
- Execute
- Memory Access
- Commit

The main components of the backend are:
- Reservation Stations (RS)
    - Load/Store Unit RS
    - ALU RS
    - Multiplier RS
- Data Cache
- Common Data Bus (CDB)
- Reorder Buffer (ROB)

In the backend, the ROB commits the instructions in the same order as they were issued. The commit operation is the only operation in the architecture that changes the state of the microprocessor. This makes the execution easy to recover in case of branch mispredictions or exceptions (however exception handling is yet to be implemented).

## Instruction Execution Flow
Every instruction goes through the following steps.
The instruction is fetched from the instruction cache, concurrently the PC is also used to get a prediction from the branch predictor (this is independent of the actual instruction, in case of a branch instruction the prediction is used to update the PC, else it is ignored).
The instruction is then decoded.
After decoding, the instruction is tagged with a ROB entry ID, the destination register is renamed using the RAT. For source registers there are three possibilities:
1. The source register is not renamed, in this case the value is read from the register file and the source value entry marked as valid.
2. The source register is renamed and the CDB contains the value, in this case the value is read from the CDB and again the source value entry marked as valid.
3. The source register is renamed but the CDB does not contain the value, in this case source value entry is marked as invalid.

The instruction is then issued to the reservation station of the corresponding unit and also to the ROB.

Every reservation station works in parallel. Their job is to wait for the source values to be ready and send the instruction to the execution unit. Priority is given to the oldest ready instruction in the reservation station.
This task is a bit more complex for the Load/Store Unit, but the overall concept is the same. Details will be provided in the corresponding section.

Once the instruction is executed, the result is broadcasted on the CDB. Since more execution units can produce results at the same time, a CDB arbiter is used to select the next result to be broadcasted. Priority is statically assigned to the different units, with the following order:
1. Load/Store Unit
2. Multiplier Unit
3. ALU Unit

This priority is based on the latency of the different units. The Load/Store Unit potentially has the highest latency, so it is given the highest priority, followed by the Multiplier Unit which is a long-latency unit, and finally the ALU Unit which is the fastest.

The ROB continuously reads the CDB and whenever the CDB contains a valid entry, it marks the corresponding instruction as ready to commit. The ROB commits at most one instruction per cycle. In the commit step the following units may be updated depending on the instruction:
- Register File
- RAT
- PC
- Branch Predictor
- Data Cache
