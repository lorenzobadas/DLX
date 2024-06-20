import json
# open instructions.json

print("library ieee;")
print("use ieee.std_logic_1164.all;")
print("package instructions_pkg is")
opcode_string = "    constant opcode_{}: {}std_logic_vector(5 downto 0) := \"{}\";       -- {}"
func_string   = "    constant func_{}: {}std_logic_vector(10 downto 0) := \"{}\"; -- {}"
with open('instructions.json', 'r') as f:
    instructions = json.load(f)
    max_name_len = 0
    for instruction in instructions:
        # get max length of name field
        name_len = len(instruction["name"])
        if name_len > max_name_len:
            max_name_len = name_len
    for mandatory in [True, False]:
        if mandatory:
            print("-- MANDATORY INSTRUCTIONS")
        else:
            print("-- OPTIONAL INSTRUCTIONS")
        print("    -- OPCODE FIELD")
        for instruction in instructions:
            name = instruction["name"]
            opcode = instruction["opcode"]
            func = instruction["func"]
            block = instruction["block"]
            if instruction["mandatory"] == mandatory:
                print(opcode_string.format(name, " "*(max_name_len-len(name)), format(int(opcode, 16), '06b'), opcode))
        print()
        print("    -- FUNC FIELD")
        for instruction in instructions:
            name = instruction["name"]
            opcode = instruction["opcode"]
            func = instruction["func"]
            block = instruction["block"]
            if block != "g-i" and instruction["mandatory"] == mandatory:
                print(func_string.format(name, " "*(max_name_len-len(name)+(len("opcode")-len("func"))), format(int(func, 16), '011b'), func))
        print()

print("end instructions_pkg;")