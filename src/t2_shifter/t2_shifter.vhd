library ieee;
use ieee.std_logic_1164.all;
use work.utils_pkg.all;

entity t2_shifter is
    generic(
        nbit: integer := 64
    );
    port(
        data_i:        in  std_logic_vector(nbit-1 downto 0);
        amount_i:      in  std_logic_vector(clog2(nbit)-1 downto 0);
        logic_arith_i: in  std_logic;
        left_right_i:  in  std_logic;
        data_o:        out std_logic_vector(nbit-1 downto 0)
    );
end entity;

architecture struct of t2_shifter is
    -- Components
    component t2_shifter_levels_1_2 is
        generic(
            nbit: integer := 64
        );
        port(
            data_i:        in  std_logic_vector(nbit-1 downto 0);
            selection_i:   in  std_logic_vector(clog2(nbit/8)-1 downto 0);
            logic_arith_i: in  std_logic;
            left_right_i:  in  std_logic;
            data_o:        out std_logic_vector((nbit+8)-2 downto 0)
        );
    end component;

    component t2_shifter_level_3 is
        generic(
            nbit: integer := 64
        );
        port(
            data_i:        in  std_logic_vector((nbit+8)-2 downto 0);
            selection_i:   in  std_logic_vector(clog2(8)-1 downto 0);
            left_right_i:  in  std_logic;
            data_o:        out std_logic_vector(nbit-1 downto 0)
        );
    end component;
    -- Constants
    constant data_intermediate_width: integer := nbit+8-1;
    constant amount_width:            integer := clog2(nbit);
    constant selection1_width:        integer := clog2(nbit/8);
    constant selection2_width:        integer := clog2(8);
    -- Signals
    signal data_intermediate: std_logic_vector(data_intermediate_width-1 downto 0);
    signal selection1:        std_logic_vector(selection1_width-1 downto 0);
    signal selection2:        std_logic_vector(selection2_width-1 downto 0);
begin
    selection1 <= amount_i(amount_width-1 downto selection2_width);
    selection2 <= amount_i(selection2_width-1 downto 0);

    t2_shifter_levels_1_2_inst: t2_shifter_levels_1_2
        generic map(
            nbit => nbit
        )
        port map(
            data_i        => data_i,
            selection_i   => selection1,
            logic_arith_i => logic_arith_i,
            left_right_i  => left_right_i,
            data_o        => data_intermediate
        );

    t2_shifter_level_3_inst: t2_shifter_level_3
            generic map(
                nbit => nbit
            )
            port map(
                data_i       => data_intermediate,
                selection_i  => selection2,
                left_right_i => left_right_i,
                data_o       => data_o
            );

end struct;