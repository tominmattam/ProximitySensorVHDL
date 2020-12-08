library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity PWM_DAC_variDuty is
   Generic ( width              : integer := 13
			  );
   Port    ( reset_n      : in  STD_LOGIC;
             clk          : in  STD_LOGIC;
				 enable		  : in  STD_LOGIC;
				 duty_cycle   : in  STD_LOGIC_VECTOR(width downto 0);
             pwm_out      : out STD_LOGIC
           );
end PWM_DAC_variDuty;

architecture Behavioral of PWM_DAC_variDuty is

Signal counter    : unsigned(width-1 downto 0);
		 
begin
   count : process(clk,reset_n)
   begin
	 
       if( reset_n = '0') then
           counter <= (others => '0');
       elsif (rising_edge(clk)) then 
			  if (enable = '1') then
						counter <= counter + 1;
			  end if;
       end if;
   end process;
 
   compare : process(counter, duty_cycle)
   begin    
       if (counter < unsigned(duty_cycle)) then
           pwm_out <= '1';
       else 
           pwm_out <= '0';
       end if;
   end process;
  
end Behavioral;

