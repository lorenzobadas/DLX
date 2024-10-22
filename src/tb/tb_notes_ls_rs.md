# Testbench methodology for Load-Store Reservation Station
### Test: Load instruction, check result from CDB, send to memory, remove from RS, check RS state
#### Time 10 ns
DUT is reset.
All enable inputs are set to zero.

#### Time 20 ns
Reset is released.

#### Time 30 ns
Load instruction is inserted with
- ROB address: 0x0
- Invalid source 2
- Immediate value: 0x5
- Width field: Word
- Source 2 register: 0x3

#### Time 40 ns
A result is available for the load instruction from the CDB:
- ROB address: 0x3 (same as source 2 register of the load instruction)
- Result: 0x5

It is consequently expected that the load instruction sets the source2 field to immediate + cdb result = 0x5 + 0x5 = 0xA.
And that the valid2 bit is set to 1.
The load instruction is the only load instruction ready to execute so it is sent to memory.
Memory Read Enable is expected to be set to 1.
Values of signals going to memory have to be stable until the acknowledgement signal is received.
These signals are:
- ROB address: 0x0
- Memory Format: Word (signedness is not relevant)
- Memory Address: 0xA

#### Time 50 ns
Enable signal is assumed to be received by memory.

#### Time 60 ns
Acknowledgement signal is received from memory.
The load instruction is expected to be removed from the reservation station.
That means that the state of the RS is expected to be "Empty" (since the load instruction was the only one in the RS) and the entry of the load instruction is expected to have the busy bit set to 0.

### Test: Verify that the load instruction is not sent to memory if a previous store does not have a valid address or when the addresses overlap

#### Time 70 ns
Insert a store instruction with:
- ROB address: 0x1
- Valid Source 1
- Invalid Source 2
- Immediate value: 0x4
- Width field: Halfword
- Source 1 register: 0x2
- Source 2 register: 0x3

#### Time 80 ns
Insert a load instruction with:
- ROB address: 0x2
- Valid Source 2: 0x5 (simply not to test again CDB)
- Width field: Byte

The load instruction is not sent to memory because the store instruction has not yet provided a valid address.

#### Time 90 ns
Insert a load instruction with:
- ROB address: 0x3
- Valid Source 2: 10 (simply not to test again CDB)
- Width field: Byte

Insert result for the store instruction:
- ROB address: 0x3
- Result: 0x0 (so the address is 0x0 + 0x4 = 0x4)

Head pointer is expected to be 0.

And since the width of the store instruction is halfword, the address covers 0x4 and 0x5.
The store instruction is sent to the LSU arbiter.
The LSU Arbiter enable signal is expected to be set to 1.
All signals going to the LSU arbiter have to be stable until the acknowledgement signal is received.
The first load instruction is not sent to memory because the store instruction overlaps with its address.
The second load instruction is sent to memory because the store instruction has provided a valid address and it does not overlap with the address of the second load instruction.

#### Time 100 ns
LSU Arbiter receives the enable signal.
Memory receives the enable signal for the second load instruction.

#### Time 110 ns
Send acknowledgement signal from LSU arbiter for the store instruction.
Send acknowledgement signal from memory for the second load instruction.

The store instruction is expected to be marked as waiting for commit.
The second load instruction is expected to be removed from the reservation station.
The first load instruction still remains in the reservation station waiting for the store instruction to be committed.

#### Time 120 ns
Send Commit signal for the store instruction.
The store instruction is expected to be removed from the reservation station.

#### Time 130 ns
The first load instruction can now be executed and sent to memory.

#### Time 140 ns

#### Time 150 ns
Send acknowledgement signal from memory for the first load instruction.
The first load instruction is expected to be removed from the reservation station.
Tail pointer is expected to be 2.

#### Time 160 ns
Tail pointer is expected to be 3.

#### Time 170 ns
The reservation station is expected to be empty.
