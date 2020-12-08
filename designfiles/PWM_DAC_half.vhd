library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity PWM_DAC_half is
   Generic ( width              : integer := 12;
				 out_of_range_count : integer := 2000
				);
   Port    ( reset_n      : in  STD_LOGIC;
             clk          : in  STD_LOGIC;
				 enable		  : in  STD_LOGIC;
				 out_of_range : in  STD_LOGIC;
				 max_count    : in std_logic_vector(width-1 downto 0);
             pwm_out      : out STD_LOGIC
           );
end PWM_DAC_half;

architecture Behavioral of PWM_DAC_half is

Signal counter    : unsigned(width-1 downto 0);
Signal counter_max: unsigned(width-1 downto 0);
Signal duty50	   : unsigned(width-1 downto 0);
		 
begin
   count : process(clk,reset_n)
   begin
	
	if (out_of_range = '0') then
		counter_max <= unsigned(max_count);
	   duty50 <= unsigned(max_count) srl 1;
	else
		counter_max <= to_unsigned(out_of_range_count, counter_max'length);
		duty50 <= to_unsigned(out_of_range_count, duty50'length) srl 1;
	end if;
	
       if( reset_n = '0') then
           counter <= (others => '0');
       elsif (rising_edge(clk)) then 
			  if (enable = '1') then
					if (counter < counter_max) then
						counter <= counter + 1;
					else
						counter <= (width-1 downto 0 => '0', others => '0');
					end if;
			  end if;
       end if;
   end process;
 
   compare : process(counter, duty50)
   begin    
       if (counter < unsigned(duty50)) then
           pwm_out <= '1';
       else 
           pwm_out <= '0';
       end if;
   end process;
  
end Behavioral;

