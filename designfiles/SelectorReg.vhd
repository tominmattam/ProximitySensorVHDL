library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SelectorReg is
    port ( CLK, LD, RST: in std_logic;
           D:            in std_logic_vector(1 downto 0);
           Q:            out std_logic_vector(1 downto 0)
        );
end SelectorReg;

architecture BEHAV of SelectorReg is

Constant blank_value: unsigned(1 downto 0):= "00";

begin
    process(CLK, RST)
        begin
            if RST = '0' then
                Q <= std_logic_vector(blank_value);
            elsif rising_edge(CLK) then
                if LD = '1' then
                    Q <= D;
                end if;
            end if;
    end process;
end BEHAV;
