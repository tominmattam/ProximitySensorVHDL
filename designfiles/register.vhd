-- VHDL file for register
library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.ALL;

entity Reg is
  port ( CLK, LD, RST:  in std_logic;
			D: 				in std_logic_vector(15 downto 0);
         Q: 				out std_logic_vector(15 downto 0)
		  );
end Reg;


architecture BEHAV of Reg is 

Constant blank_value: unsigned(15 downto 0):= "0000000000000000";

  begin 
    process(CLK, RST)
	   begin 
		  if RST = '0' then								--Active low reset
		    Q <= std_logic_vector(blank_value);
	     elsif rising_edge(CLK) then
		    if LD = '1' then								--Active high load
			    Q <= D;
			 end if;
		end if;
	end process;
end BEHAV;
		    
		  