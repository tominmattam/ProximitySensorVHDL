library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity buzzermodule is
  generic( dist_width       : integer := 13;
			  dist_upper_limit : integer := 4000;
           period		       : integer := 1
         );
     Port( clk            : in std_logic;
           reset_n        : in std_logic;
           input          : in std_logic_vector(dist_width-1 downto 0);
           pwm_output     : out std_logic
        );
end  buzzermodule;

architecture behav of buzzermodule is

    -- Signals --

Signal pwm_dac_input:     std_logic_vector(dist_width-1 downto 0);
Signal pwm_dac_output:    std_logic;
Signal zero_output:       std_logic;
Signal enable:				  std_logic;
Signal out_of_range:      std_logic;

-- Component Declaration --
    
Component PWM_DAC_half is
    generic( width              : integer := 12;
             out_of_range_count : integer := 4000	 
 	        );
           
       PORT( reset_n      : in std_logic;
             clk          : in std_logic;
				 enable		  : in std_logic;
				 out_of_range : in std_logic;
             max_count    : in std_logic_vector(dist_width-1 downto 0);
             pwm_out      : out std_logic
           );
end Component;

Component downcounter is
	Generic ( period  : natural := 1000); -- number to count       
      PORT ( clk      : in  STD_LOGIC; -- clock to be divided
             reset_n  : in  STD_LOGIC; -- active-high reset
             enable   : in  STD_LOGIC; -- active-high enable
             zero     : out STD_LOGIC  -- creates a positive pulse every time current_count hits zero
                                       -- useful to enable another device, like to slow down a counter
              -- value  : out STD_LOGIC_VECTOR(integer(ceil(log2(real(period)))) - 1 downto 0) -- outputs the current_count value, if needed
         );
end Component;

begin
		  
	enable <= '1';
		  
	distance_limit : process(input)
		begin
			if unsigned(input) < to_unsigned(dist_upper_limit, input'length) then
				pwm_dac_input <= input;
				out_of_range  <= '0';
			else
				pwm_dac_input <= std_logic_vector(to_unsigned(dist_upper_limit, pwm_dac_input'length));
				out_of_range  <= '1';
		end if;
	end process;
		  
	pwm_output <=  pwm_dac_output;
	    
    -- Component Instantiation --
    
PWM_DAC_half_ins: PWM_DAC_half
    generic map( width              => dist_width,
					  out_of_range_count => dist_upper_limit
					 )
    PORT MAP( reset_n    => reset_n,
              clk        => clk,
		        enable     => zero_output,
				  out_of_range => out_of_range,
              max_count  => pwm_dac_input,
              pwm_out    => pwm_dac_output
            );
					 
downcounter_ins: downcounter			 
    generic map( period  => period)      -- number to count       
       PORT MAP( clk     => clk,         -- clock to be divided
                 reset_n => reset_n,     -- active-high reset
                 enable  => enable,      -- active-high enable
                 zero    => zero_output  -- creates a positive pulse every time current_count hits zero
                                       -- useful to enable another device, like to slow down a counter
              -- value  : out STD_LOGIC_VECTOR(integer(ceil(log2(real(period)))) - 1 downto 0) -- outputs the current_count value, if needed
         );
			
end behav;