library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity write_back is
    generic (
        nbit : integer := 32
    );
    port (
        aluout_i    : in  std_logic_vector(nbit-1 downto 0);
        lmd_i       : in  std_logic_vector(nbit-1 downto 0);
        rdest_i     : in  std_logic_vector(4 downto 0);
        wbdata_o    : out std_logic_vector(nbit-1 downto 0);
        wbaddr_o    : out std_logic_vector(4 downto 0);
        -- Control signals
        memToReg_i  : in std_logic;
        jalEn_i     : in std_logic;
        regWrite_o  : out std_logic;
    );
end entity;

architecture struct of write_back is
    component mux2to1 is
        generic(
            nbit: integer := 32
        );
        port(
            in0_i:  in  std_logic_vector(nbit-1 downto 0);
            in1_i:  in  std_logic_vector(nbit-1 downto 0);
            sel_i:  in  std_logic;
            out_o:  out std_logic_vector(nbit-1 downto 0)
        );
    end component;
begin
    rdest_o <= rdest_i;
    mux_mem2reg: mux2to1
        generic map (
            nbit => nbit
        )
        port map (
            in0_i => aluout_i,
            in1_i => lmd_i,
            sel_i => memToReg_i,
            out_o => wbdata_o
        );

    mux_jalEn: mux2to1
        generic map (
            nbit => 5
        )
        port map (
            in0_i => std_logic_vector(to_unsigned(31, 5)),
            in1_i => rdest_i,
            sel_i => jalEn_i,
            out_o => wbaddr_o
        );
    
end architecture;