library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity dist_checker is
   Port    ( reset_n  : in  STD_LOGIC;
             clk      : in  STD_LOGIC;
	          raw_dist : in  STD_LOGIC_VECTOR(12 downto 0);
             pwm_dist : out STD_LOGIC_VECTOR(12 downto 0)
           );
end dist_checker;

architecture Behavioral of dist_checker is

Constant dist_max: integer := 4230;
		 
begin
   compare: process(clk,reset_n)
   begin
		if (reset_n = '0') then
			pwm_dist <= (others => '0');
		elsif (rising_edge(clk)) then
			if (unsigned(raw_dist) < to_unsigned(dist_max, raw_dist'length)) then
				pwm_dist <= raw_dist;
			else
				pwm_dist <= std_logic_vector(to_unsigned(dist_max, pwm_dist'length));
			end if;
		end if;
   end process;  
end Behavioral;