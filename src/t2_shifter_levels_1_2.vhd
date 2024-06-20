library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

entity t2_shifter_levels_1_2 is
    generic(
        nbit: integer := 64
    );
    port(
        data_i:        in  std_logic_vector(nbit-1 downto 0);
        selection:     in  std_logic_vector(clog2(nbit/8)-1 downto 0);
        logic_arith_i: in  std_logic;
        left_right_i:  in  std_logic;
        data_o:        out std_logic_vector((nbit+8)-2 downto 0)
    );
end entity;

architecture behav of t2_shifter_levels_1_2 is
    constant nbit_mask: integer := (nbit+8)-1; -- number of bits in a single mask
    constant n_masks := (nbit/8); -- number of masks
    type array2d is array(0 to n_masks-1) of std_logic_vector(nbit_mask-1 downto 0);
    signal mask: array2d;
begin
    process (data_i, logic_arith_i, left_right_i)
        variable nbit_cut: integer; -- defines the number of bits to cut
    begin
        for i in 0 to n_masks-1 loop
            nbit_cut := ((i+1)*8)-1;
            if left_right_i = '0' then -- left shift
                for j in 0 to nbit_mask-1 loop
                    if j >= nbit_cut then
                        mask(i)(j) <= data_i(j-(nbit_cut));
                    else
                        mask(i)(j) <= '0';
                    end if;
                end loop;
            else -- right shift
                if logic_arith_i = '0' then -- logical shift
                    for j in 0 to nbit_mask-1 loop
                        if j <= (nbit_mask-1)-(nbit_cut) then
                            mask(i)(j) <= data_i(j+(i*8));
                        else
                            mask(i)(j) <= '0';
                        end if;
                    end loop;
                else -- arithmetic shift
                    for j in 0 to nbit_mask-1 loop
                        if j <= (nbit_mask-1)-(nbit_cut) then
                            mask(i)(j) <= data_i(j+(i*8));
                        else
                            mask(i)(j) <= data_i(nbit-1);
                        end if;
                    end loop;
                end if;
            end if;
        end loop;
    end process;

    data_o <= mask(to_integer(unsigned(selection)));
end behav;