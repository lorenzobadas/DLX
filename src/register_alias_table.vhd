library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;
use work.o3_pkg.all;

entity register_alias_table is
    port (
        clk_i:   in  std_logic;
        reset_i: in  std_logic;
        flush_i: in  std_logic;

        -- ROB renaming interface
        rename_i:          in std_logic; -- actually comes from issue unit
        rename_address_i:  in std_logic_vector(4 downto 0); -- also comes from issue unit (decoded destination register)
        rename_physical_i: in std_logic_vector(clog2(n_entries_rob)-1 downto 0); -- issue pointer of ROB

        -- ROB commit interface
        commit_i:          in std_logic;
        commit_address_i:  in std_logic_vector(4 downto 0); -- destination field of ROB entry
        commit_physical_i: in std_logic_vector(clog2(n_entries_rob)-1 downto 0); -- commit pointer of ROB

        -- RS interface (actually from issue unit but related to RS)
        register1_i: in  std_logic_vector(4 downto 0);
        alias1_o:    out rat_entry;
        register2_i: in  std_logic_vector(4 downto 0);
        alias2_o:    out rat_entry
    );
end entity;

architecture beh of register_alias_table is
    type rat_array is array(0 to 31) of rat_entry;
begin
    rename_proc: process(clk_i, reset_i)
    begin
        if reset_i = '1' then
            for i in 0 to 31 loop
                rat_array(i).physical <= (others => '0');
                rat_array(i).valid <= '0';
            end loop;
        elsif rising_edge(clk_i) then
            if flush_i = '1' then
                for i in 0 to 31 loop
                    rat_array(i).physical <= (others => '0');
                    rat_array(i).valid <= '0';
                end loop;
            elsif rename_i = '1' then
                rat_array(to_integer(unsigned(rename_address_i))).physical <= rename_physical_i;
                rat_array(to_integer(unsigned(rename_address_i))).valid <= '1';
            elsif commit_i = '1' then
                if rat_array(to_integer(unsigned(commit_address_i))).physical = commit_physical_i then
                    rat_array(to_integer(unsigned(commit_address_i))).valid <= '0';
                end if;
            end if;
            -- register 0 is never renamed so never valid
            rat_array(0).valid <= '0';
        end if;
    end process rename_proc;

    read_proc: process(register1_i, register2_i)
    begin
        alias1_o <= rat_array(to_integer(unsigned(register1_i)));
        alias2_o <= rat_array(to_integer(unsigned(register2_i)));
    end process read_proc;
end beh;

