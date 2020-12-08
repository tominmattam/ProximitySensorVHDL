library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity LEDR_module is
	generic ( dist_width       : integer := 13;
	          dist_upper_limit : integer := 4000;
				 step			      : integer := 8
	        );
   port    ( clk            :  IN     STD_LOGIC;                                
             reset_n        :  IN     STD_LOGIC;                                
             input_distance :  IN     STD_LOGIC_VECTOR(dist_width-1 DOWNTO 0); 	 
             LEDR_out       :  OUT    STD_LOGIC_VECTOR(9 downto 0)
			  ); 
end LEDR_module;

architecture structural of LEDR_module is

 -- Signals --
 
Signal pwm_dac_out:     STD_LOGIC;
Signal out_of_range:    STD_LOGIC;
Signal enable:          STD_LOGIC;
Signal actual_distance: STD_LOGIC_VECTOR(step downto 0);
 
 -- Component Declaration --

component PWM_DAC_variDuty is
  generic ( width			       : integer := 12	
			  );
  Port    ( reset_n       : in  STD_LOGIC;
             clk          : in  STD_LOGIC;
				 enable		  : in  STD_LOGIC;
             duty_cycle   : in  STD_LOGIC_VECTOR (step downto 0);
             pwm_out      : out STD_LOGIC
           );
end component;

 -- Signal Matching --
 
begin
	
	enable <= '1';
	
	distance_limit : process(input_distance)
			begin
				if unsigned(input_distance) < to_unsigned(dist_upper_limit, input_distance'length) then
					actual_distance <= input_distance(step downto 0);
				else
					actual_distance <= (others => '1');
				end if;
			end process;
	
	LEDR_out(9) <= not pwm_dac_out;
	LEDR_out(8) <= not pwm_dac_out;
	LEDR_out(7) <= not pwm_dac_out;
	LEDR_out(6) <= not pwm_dac_out;
	LEDR_out(5) <= not pwm_dac_out;
	LEDR_out(4) <= not pwm_dac_out;
	LEDR_out(3) <= not pwm_dac_out;
	LEDR_out(2) <= not pwm_dac_out;
	LEDR_out(1) <= not pwm_dac_out;
	LEDR_out(0) <= not pwm_dac_out;
	
 -- Component Instantiation --

PWM_DAC_variDuty_ins: PWM_DAC_variDuty
			 generic map( width     => step
							)
          PORT MAP(
			           clk          => clk,
						  reset_n      => reset_n,
						  enable       => enable,
						  duty_cycle   => actual_distance,
						  pwm_out      => pwm_dac_out
						);
   
end structural;