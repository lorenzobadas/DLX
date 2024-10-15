# Testbench methodology for Execution Reservation Station
### Test: Add instruction, get value from CDB, stall ALU, send to ALU, remove from RS, check RS state
#### Time 10 ns
DUT is reset.
All enable inputs are set to zero.

#### Time 20 ns
Reset is released.

#### Time 30 ns
Add instruction is inserted with
- ROB address: 0x0
- Source 1 register: 0x1
- Valid Source 1
- Invalid Source 2
- Operation: 0x0 (Add)
- Source 2 Register: 0x1

#### Time 40 ns
Get value from CDB:
- ROB address: 0x1 (matches with source 2 register)
- Value: 0x1

#### Time 50 ns
Set ALU stall signal to one.

#### Time 60 ns
Set ALU stall signal to zero.
Send to ALU:
- ROB address: 0x0
- Source 1: 0x1
- Source 2: 0x1
- Operation: 0x0 (Add)

#### Time 70 ns
RS is now empty.

### Test: Out of order execution and full state
#### Time 80
Insert instruction 1 with:
- ROB address: 0x0
- Source 1 register: 0x1
- Valid Source 1
- Invalid Source 2
- Operation: 0x0
- Source 2 register: 0x1

#### Time 90
Insert instruction 2 with:
- ROB address: 0x1
- Invalid Source 1
- Source 2 register: 0x2
- Valid Source 2
- Operation: 0x1
- Source 1 register: 0x2

#### Time 100
Insert instruction 3 with:
- ROB address: 0x2
- Source 1 register: 0x3
- Valid Source 1
- Invalid Source 2
- Operation: 0x2
- Source 2 register: 0x3

#### Time 110
Insert instruction 4 with:
- ROB address: 0x3
- Source 1 register: 0x4
- Valid Source 1
- Invalid Source 2
- Operation: 0x3
- Source 2 register: 0x4

#### Time 120
Try to insert instruction 5 with:
- ROB address: 0x4
- Source 1 register: 0x5
- Valid Source 1
- Invalid Source 2
- Operation: 0x4
- Source 2 register: 0x5

This should fail as the RS is full.

#### Time 130
Get value from CDB:
- ROB address: 0x4
- Value: 0x4

#### Time 140
Send to ALU:
- ROB address: 0x3
- Source 1: 0x4
- Source 2: 0x4
- Operation: 0x3

Get value from CDB:
- ROB address: 0x3
- Value: 0x3

#### Time 150
Again try to insert instruction 5 with:
- ROB address: 0x4
- Source 1 register: 0x5
- Valid Source 1
- Invalid Source 2
- Operation: 0x4
- Source 2 register: 0x5

This should fail as the RS is still full.

Send to ALU:
- ROB address: 0x2
- Source 1: 0x3
- Source 2: 0x3
- Operation: 0x2

Get value from CDB:
- ROB address: 0x2
- Value: 0x2

#### Time 160
Send to ALU:
- ROB address: 0x1
- Source 1: 0x2
- Source 2: 0x2
- Operation: 0x1

Get value from CDB:
- ROB address: 0x1
- Value: 0x1

#### Time 170
Send to ALU:
- ROB address: 0x0
- Source 1: 0x1
- Source 2: 0x1
- Operation: 0x0

All instructions should now be executed

#### Time 180
Tail pointer incremented to 0x2

#### Time 190
Tail pointer incremented to 0x3

#### Time 200
Tail pointer incremented to 0x0

#### Time 210
Tail pointer incremented to 0x1
The RS is now empty.
