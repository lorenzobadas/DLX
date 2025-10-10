import argparse
from typing import List

class ProcessorEmulator:
    def __init__(self, memory_size : int = 4096, debug_cycles : bool =False) -> None :
        # Register file (32 registers, initialized to 0)
        self.registers: List[int] = [0] * 32
        # byte-level access
        self.data_memory : bytearray = bytearray(memory_size)
        # PC
        self.pc : int = 0
        # Instruction memory
        self.instructions : List[int] = []
        # return address (R31)
        self.ra_register : int = 31
        # cycle-by-cycle register dumping
        self.debug_cycles : bool = debug_cycles

    def load_program(self, filename: str):
        try:
            with open(filename, 'r') as f:
                lines = [line.strip() for line in f if line.strip()]
                self.instructions = [int(line, 16) for line in lines]

            # Load same content into data memory (byte-level)
            data = bytes.fromhex(''.join(lines))
            size = min(len(data), len(self.data_memory))
            self.data_memory[:size] = data[:size]

            print(f"Program '{filename}' loaded successfully. {len(self.instructions)} instructions.")
            print(f"Data memory loaded with {size} bytes.")
        except FileNotFoundError:
            print(f"Error: Program file '{filename}' not found.")
            exit(1)
        except ValueError:
            print(f"Error: Invalid hexadecimal value in '{filename}'.")
            exit(1)

    def sign_extend(self, value : int, bits : int):
        sign_bit = 1 << (bits - 1)
        return (value & (sign_bit - 1)) - (value & sign_bit)

    def signed(self, value: int) -> int:
        value = value & 0xFFFFFFFF
        value = int.from_bytes(value.to_bytes(4, byteorder='big'), byteorder='big', signed=True)
        return value

    def unsigned(self, value: int) -> int:
        return value & 0xFFFFFFFF


    # ****************************************** INSTRUCTIONS ******************************************
    def instr_j(self, address : int):
        address = self.sign_extend(address, 26)
        self.pc += 4 + address

    def instr_jal(self, address : int):
        address = self.sign_extend(address, 26)
        self.registers[self.ra_register] = self.pc + 4
        self.pc += 4 + address

    def instr_jr(self, rs : int):
        self.pc = self.registers[rs]

    def instr_jalr(self, rs : int):
        self.registers[self.ra_register] = self.pc + 4
        self.pc = self.registers[rs]

    def instr_beqz(self, rs : int, offset : int):
        self.pc += 4 + self.sign_extend(offset, 16) if self.registers[rs] == 0 else 4

    def instr_bnez(self, rs : int, offset : int):
        self.pc += 4 + self.sign_extend(offset, 16) if self.registers[rs] != 0 else 4

    def instr_addi(self, rt : int, rs : int, immediate : int):
        self.registers[rt] = self.registers[rs] + self.sign_extend(immediate, 16);
        self.pc += 4

    def instr_subi(self, rt : int, rs : int, immediate : int):
        self.registers[rt] = self.registers[rs] - self.sign_extend(immediate, 16);
        self.pc += 4

    def instr_andi(self, rt : int, rs : int, immediate : int):
        self.registers[rt] = self.registers[rs] & (immediate & 0xFFFF)
        self.pc += 4

    def instr_ori(self, rt : int, rs : int, immediate : int):
        self.registers[rt] = self.registers[rs] | (immediate & 0xFFFF)
        self.pc += 4

    def instr_xori(self, rt : int, rs : int, immediate : int):
        self.registers[rt] = self.registers[rs] ^ (immediate & 0xFFFF)
        self.pc += 4

    def instr_slli(self, rt : int, rs : int, immediate : int):
        self.registers[rt] = self.registers[rs] << (immediate & 0x1F);
        self.pc += 4

    def instr_srli(self, rt : int, rs : int, immediate : int):
        self.registers[rt] = (self.registers[rs] & 0xFFFFFFFF) >> (immediate & 0x1F);
        self.pc += 4

    def instr_srai(self, rt: int, rs: int, immediate: int):
        signed_val = self.signed(self.registers[rs])
        shift_amount = immediate & 0x1F
        self.registers[rt] = signed_val >> shift_amount
        self.pc += 4

    def instr_slti(self, rt : int, rs : int, immediate : int):
        self.registers[rt] = self.signed(self.registers[rs]) < self.sign_extend(immediate, 16);
        self.pc += 4

    def instr_sgti(self, rt : int, rs : int, immediate : int):
        self.registers[rt] = self.signed(self.registers[rs]) > self.sign_extend(immediate, 16);
        self.pc += 4

    def instr_seqi(self, rt : int, rs : int, immediate : int):
        self.registers[rt] = self.registers[rs] == self.sign_extend(immediate, 16);
        self.pc += 4

    def instr_snei(self, rt : int, rs : int, immediate : int):
        self.registers[rt] = self.registers[rs] != self.sign_extend(immediate, 16);
        self.pc += 4

    def instr_slei(self, rt : int, rs : int, immediate : int):
        self.registers[rt] = self.signed(self.registers[rs]) <= self.sign_extend(immediate, 16);
        self.pc += 4

    def instr_sgei(self, rt : int, rs : int, immediate : int):
        self.registers[rt] = self.signed(self.registers[rs]) >= self.sign_extend(immediate, 16);
        self.pc += 4

    def instr_lw(self, rt : int, base : int, offset : int):
        address = self.registers[base] + self.sign_extend(offset, 16)
        address &= 0xFFFFFFFF
        if address % 4 != 0:
            print(f"Memory alignment error on LW at 0x{address:08x}");
            self.pc += 4;
            return
        if 0 <= address < len(self.data_memory) - 3:
            word_bytes = self.data_memory[address:address+4]
            self.registers[rt] = int.from_bytes(word_bytes, byteorder='big', signed=False)
        else:
            print(f"Error: Invalid memory read at address 0x{address:08x}")
        self.pc += 4

    def instr_sw(self, rt : int, base : int, offset : int):
        address = self.registers[base] + self.sign_extend(offset, 16)
        address &= 0xFFFFFFFF
        if address % 4 != 0:
            print(f"Memory alignment error on SW at 0x{address:08x}");
            self.pc += 4;
            return
        if 0 <= address < len(self.data_memory) - 3:
            word_bytes = self.registers[rt].to_bytes(4, byteorder='big', signed=False)
            self.data_memory[address:address+4] = word_bytes
        else:
            print(f"Error: Invalid memory write at address 0x{address:08x}")
        self.pc += 4

    def instr_lb(self, rt : int, base : int, offset : int):
        address = self.registers[base] + self.sign_extend(offset, 16)
        if 0 <= address < len(self.data_memory):
            byte_val = self.data_memory[address]
            self.registers[rt] = self.sign_extend(byte_val, 8)
        else:
            print(f"Error: Invalid memory read at address 0x{address:08x}")
        self.pc += 4

    def instr_sb(self, rt : int, base : int, offset : int):
        address = self.registers[base] + self.sign_extend(offset, 16)
        if 0 <= address < len(self.data_memory):
            byte_val = self.registers[rt] & 0xFF
            self.data_memory[address] = byte_val
        else:
            print(f"Error: Invalid memory write at address 0x{address:08x}")
        self.pc += 4

    def instr_lh(self, rt : int, base : int, offset : int):
        address = self.registers[base] + self.sign_extend(offset, 16)
        if address % 2 != 0:
            print(f"Memory alignment error on LH at 0x{address:08x}");
            exit()
        if 0 <= address < len(self.data_memory) - 1:
            halfword_bytes = self.data_memory[address:address+2]
            self.registers[rt] = int.from_bytes(halfword_bytes, byteorder='big', signed=True)
        else:
            print(f"Error: Invalid memory read at address 0x{address:08x}")
        self.pc += 4

    def instr_lbu(self, rt : int, base : int, offset : int):
        address = self.registers[base] + self.sign_extend(offset, 16)
        if 0 <= address < len(self.data_memory):
            byte_val = self.data_memory[address]
            self.registers[rt] = byte_val
        else:
            print(f"Error: Invalid memory read at address 0x{address:08x}")
        self.pc += 4

    def instr_lhu(self, rt : int, base : int, offset : int):
        address = self.registers[base] + self.sign_extend(offset, 16)
        if address % 2 != 0:
            print(f"Memory alignment error on LHU at 0x{address:08x}");
            exit()
        if 0 <= address < len(self.data_memory) - 1:
            halfword_bytes = self.data_memory[address:address+2]
            self.registers[rt] = int.from_bytes(halfword_bytes, byteorder='big', signed=False)
        else:
            print(f"Error: Invalid memory read at address 0x{address:08x}")
        self.pc += 4

    def instr_sh(self, rt : int, base : int, offset : int):
        address = self.registers[base] + self.sign_extend(offset, 16)
        if address % 2 != 0:
            print(f"Memory alignment error on SH at 0x{address:08x}");
            exit()
        if 0 <= address < len(self.data_memory) - 1:
            halfword_val = self.registers[rt] & 0xFFFF
            halfword_bytes = halfword_val.to_bytes(2, byteorder='big', signed=False)
            self.data_memory[address:address+2] = halfword_bytes
        else:
            print(f"Error: Invalid memory write at address 0x{address:08x}")
        self.pc += 4

    def instr_add(self, rd : int, rs : int, rt : int):
        self.registers[rd] = self.registers[rs] + self.registers[rt];
        self.pc += 4

    def instr_sub(self, rd : int, rs : int, rt : int):
        self.registers[rd] = self.registers[rs] - self.registers[rt];
        self.pc += 4

    def instr_and(self, rd : int, rs : int, rt : int):
        self.registers[rd] = self.registers[rs] & self.registers[rt];
        self.pc += 4

    def instr_or(self, rd : int, rs : int, rt : int):
        self.registers[rd] = self.registers[rs] | self.registers[rt];
        self.pc += 4

    def instr_xor(self, rd : int, rs : int, rt : int):
        self.registers[rd] = self.registers[rs] ^ self.registers[rt];
        self.pc += 4

    def instr_sll(self, rd: int, rs: int, rt: int):
        shift_amount = self.registers[rt] & 0x1F
        self.registers[rd] = self.registers[rs] << shift_amount
        self.pc += 4

    def instr_srl(self, rd: int, rs: int, rt: int):
        shift_amount = self.registers[rt] & 0x1F
        self.registers[rd] = (self.registers[rs] & 0xFFFFFFFF) >> shift_amount
        self.pc += 4

    def instr_sra(self, rd: int, rs: int, rt: int):
        shift_amount = self.registers[rt] & 0x1F

        signed_val = self.signed(self.registers[rs])

        self.registers[rd] = signed_val >> shift_amount
        self.pc += 4

    def instr_slt(self, rd : int, rs : int, rt : int):
        self.registers[rd] = self.signed(self.registers[rs]) < self.signed(self.registers[rt]);
        self.pc += 4

    def instr_sgt(self, rd : int, rs : int, rt : int):
        self.registers[rd] = self.signed(self.registers[rs]) > self.signed(self.registers[rt]);
        self.pc += 4

    def instr_seq(self, rd : int, rs : int, rt : int):
        self.registers[rd] = self.registers[rs] == self.registers[rt];
        self.pc += 4

    def instr_sne(self, rd : int, rs : int, rt : int):
        self.registers[rd] = self.registers[rs] != self.registers[rt];
        self.pc += 4

    def instr_sle(self, rd : int, rs : int, rt : int):
        self.registers[rd] = self.signed(self.registers[rs]) <= self.signed(self.registers[rt]);
        self.pc += 4

    def instr_sge(self, rd : int, rs : int, rt : int):
        self.registers[rd] = self.signed(self.registers[rs]) >= self.signed(self.registers[rt]);
        self.pc += 4

    def instr_addu(self, rd : int, rs : int, rt : int):
        self.registers[rd] = self.registers[rs] + self.registers[rt]
        self.pc += 4

    def instr_subu(self, rd : int, rs : int, rt : int):
        self.registers[rd] = self.registers[rs] - self.registers[rt]
        self.pc += 4

    def instr_sltu(self, rd : int, rs : int, rt : int):
        self.registers[rd] = self.unsigned(self.registers[rs]) < self.unsigned(self.registers[rt])
        self.pc += 4

    def instr_sgtu(self, rd : int, rs : int, rt : int):
        self.registers[rd] = self.unsigned(self.registers[rs]) > self.unsigned(self.registers[rt])
        self.pc += 4

    def instr_sleu(self, rd : int, rs : int, rt : int):
        self.registers[rd] = self.unsigned(self.registers[rs]) <= self.unsigned(self.registers[rt])
        self.pc += 4

    def instr_sgeu(self, rd : int, rs : int, rt : int):
        self.registers[rd] = self.unsigned(self.registers[rs]) >= self.unsigned(self.registers[rt])
        self.pc += 4

    def instr_addui(self, rt: int, rs: int, immediate: int):
        self.registers[rt] = self.registers[rs] + (immediate & 0xFFFF)
        self.pc += 4

    def instr_subui(self, rt: int, rs: int, immediate: int):
        self.registers[rt] = self.registers[rs] - (immediate & 0xFFFF)
        self.pc += 4

    def instr_sltui(self, rt: int, rs: int, immediate: int):
        self.registers[rt] = self.unsigned(self.registers[rs]) < (immediate & 0xFFFF)
        self.pc += 4

    def instr_sgtui(self, rt: int, rs: int, immediate: int):
        self.registers[rt] = self.unsigned(self.registers[rs]) > (immediate & 0xFFFF)
        self.pc += 4

    def instr_sleui(self, rt: int, rs: int, immediate: int):
        self.registers[rt] = self.unsigned(self.registers[rs]) <= (immediate & 0xFFFF)
        self.pc += 4

    def instr_sgeui(self, rt: int, rs: int, immediate: int):
        self.registers[rt] = self.unsigned(self.registers[rs]) >= (immediate & 0xFFFF)
        self.pc += 4

    def instr_nop(self):
        self.pc += 4

    def run(self, max_cycles : int = 500):
        if not self.instructions:
            print("No program loaded.");
            return
        cycles = 0
        while self.pc < len(self.instructions)*4 and cycles < max_cycles:
            # Fetch instruction
            assert (self.pc % 4) == 0, f"PC not aligned: {self.pc}"
            instruction_word = self.instructions[self.pc >> 2]

            # Decode fields
            opcode = (instruction_word >> 26) & 0x3F
            rs     = (instruction_word >> 21) & 0x1F
            rt     = (instruction_word >> 16) & 0x1F
            rd     = (instruction_word >> 11) & 0x1F
            func   =  instruction_word        & 0x7FF
            imm16  =  instruction_word        & 0xFFFF
            imm26  =  instruction_word        & 0x3FFFFFF

            if self.debug_cycles: self.print_cycle_state(cycles, instruction_word)

            if opcode == 0x00: # R-Type
                if   func == 0x20: self.instr_add(rd, rs, rt)
                elif func == 0x21: self.instr_addu(rd, rs, rt)
                elif func == 0x22: self.instr_sub(rd, rs, rt)
                elif func == 0x23: self.instr_subu(rd, rs, rt)
                elif func == 0x24: self.instr_and(rd, rs, rt)
                elif func == 0x25: self.instr_or(rd, rs, rt)
                elif func == 0x26: self.instr_xor(rd, rs, rt)
                elif func == 0x04: self.instr_sll(rd, rs, rt)
                elif func == 0x06: self.instr_srl(rd, rs, rt)
                elif func == 0x07: self.instr_sra(rd, rs, rt)
                elif func == 0x2a: self.instr_slt(rd, rs, rt)
                elif func == 0x2b: self.instr_sgt(rd, rs, rt)
                elif func == 0x28: self.instr_seq(rd, rs, rt)
                elif func == 0x29: self.instr_sne(rd, rs, rt)
                elif func == 0x2c: self.instr_sle(rd, rs, rt)
                elif func == 0x2d: self.instr_sge(rd, rs, rt)
                elif func == 0x3a: self.instr_sltu(rd, rs, rt)
                elif func == 0x3b: self.instr_sgtu(rd, rs, rt)
                elif func == 0x3c: self.instr_sleu(rd, rs, rt)
                elif func == 0x3d: self.instr_sgeu(rd, rs, rt)
                else:
                    print(f"\nERROR: Unsupported R-Type instruction at PC={self.pc} (0x{instruction_word:08x}) with func=0x{func:03x}")
                    exit(1)
            elif opcode == 0x02: self.instr_j(imm26)
            elif opcode == 0x03: self.instr_jal(imm26)
            elif opcode == 0x12: self.instr_jr(rs)
            elif opcode == 0x13: self.instr_jalr(rs)
            elif opcode == 0x04: self.instr_beqz(rs, imm16)
            elif opcode == 0x05: self.instr_bnez(rs, imm16)
            elif opcode == 0x08: self.instr_addi(rt, rs, imm16)
            elif opcode == 0x09: self.instr_addui(rt, rs, imm16)
            elif opcode == 0x0a: self.instr_subi(rt, rs, imm16)
            elif opcode == 0x0b: self.instr_subui(rt, rs, imm16)
            elif opcode == 0x0c: self.instr_andi(rt, rs, imm16)
            elif opcode == 0x0d: self.instr_ori(rt, rs, imm16)
            elif opcode == 0x0e: self.instr_xori(rt, rs, imm16)
            elif opcode == 0x14: self.instr_slli(rt, rs, imm16)
            elif opcode == 0x16: self.instr_srli(rt, rs, imm16)
            elif opcode == 0x17: self.instr_srai(rt, rs, imm16)
            elif opcode == 0x1a: self.instr_slti(rt, rs, imm16)
            elif opcode == 0x1b: self.instr_sgti(rt, rs, imm16)
            elif opcode == 0x18: self.instr_seqi(rt, rs, imm16)
            elif opcode == 0x19: self.instr_snei(rt, rs, imm16)
            elif opcode == 0x1c: self.instr_slei(rt, rs, imm16)
            elif opcode == 0x1d: self.instr_sgei(rt, rs, imm16)
            elif opcode == 0x3a: self.instr_sltui(rt, rs, imm16)
            elif opcode == 0x3b: self.instr_sgtui(rt, rs, imm16)
            elif opcode == 0x3c: self.instr_sleui(rt, rs, imm16)
            elif opcode == 0x3d: self.instr_sgeui(rt, rs, imm16)
            elif opcode == 0x15: self.instr_nop()
            elif opcode == 0x23: self.instr_lw(rt, rs, imm16)
            elif opcode == 0x2b: self.instr_sw(rt, rs, imm16)
            elif opcode == 0x20: self.instr_lb(rt, rs, imm16)
            elif opcode == 0x28: self.instr_sb(rt, rs, imm16)
            elif opcode == 0x21: self.instr_lh(rt, rs, imm16)
            elif opcode == 0x24: self.instr_lbu(rt, rs, imm16)
            elif opcode == 0x25: self.instr_lhu(rt, rs, imm16)
            elif opcode == 0x29: self.instr_sh(rt, rs, imm16)
            else:
                print(f"\nERROR: Unsupported instruction at PC={self.pc} (0x{instruction_word:08x}) with opcode=0x{opcode:02x}")
                exit(1)

            self.registers[0] = 0
            self.pc = self.pc & 0xFFFFFFFF
            for i in range(1, 32):
                self.registers[i] = self.registers[i] & 0xFFFFFFFF
            cycles += 1

        print("-" * 20)
        if cycles >= max_cycles:
            print(f"Execution stopped: Max cycles ({max_cycles}) reached.")
        else:
            print("Execution finished.")

    def print_cycle_state(self, cycle : int, instruction_word : int):
        print(f"\n---> Cycle {cycle} ---> PC={self.pc} ---> Executing: 0x{instruction_word:08x} ---")
        for i in range(0, 32, 4):
            r1,r2,r3,r4 = self.registers[i:i+4]
            print(f"R{i:02d}: {r1:<11d} R{i+1:02d}: {r2:<11d} R{i+2:02d}: {r3:<11d} R{i+3:02d}: {r4:<11d}")

    def print_final_state(self):
        print("\n**** Final processor state ****")
        print(f"Program Counter (PC): {self.pc}")
        print("\nRegister File:")
        for i in range(0, 32, 4):
            r1,r2,r3,r4 = self.registers[i:i+4]
            print(f"R{i:02d}: {r1:<11d} R{i+1:02d}: {r2:<11d} R{i+2:02d}: {r3:<11d} R{i+3:02d}: {r4:<11d}")
        print("\nData Memory:")
        for i in range(0, len(self.data_memory), 4):
            chunk = self.data_memory[i:i+4]
            hex_chunk = ' '.join(f"{byte:02x}" for byte in chunk)
            print(f"0x{i:04x}: {hex_chunk} = {int.from_bytes(chunk, byteorder='big', signed=True)}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="DLX emulator")
    parser.add_argument("program_file", help="Path to the .mem file")
    parser.add_argument("--debug", action="store_true", help="cycle-by-cycle regs dumping enable")
    parser.add_argument("--max_cycles", type=int, default=500, help="num cycles to run")
    args = parser.parse_args()

    emulator = ProcessorEmulator(debug_cycles=args.debug)
    emulator.load_program(args.program_file)
    emulator.run(max_cycles=args.max_cycles)
    emulator.print_final_state()
