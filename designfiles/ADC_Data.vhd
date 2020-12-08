library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity ADC_Data is
    Port( clk      : in STD_LOGIC;
	       reset_n  : in STD_LOGIC; -- active-low
			 voltage  : out STD_LOGIC_VECTOR (12 downto 0); -- Voltage in milli-volts
			 distance : out STD_LOGIC_VECTOR (12 downto 0); -- distance in 10^-4 cm (e.g. if distance = 33 cm, then 3300 is the value)
			 ADC_raw  : out STD_LOGIC_VECTOR (11 downto 0); -- the latest 12-bit ADC value
          ADC_out  : out STD_LOGIC_VECTOR (11 downto 0)  -- moving average of ADC value, over 256 samples,
         );                                              -- number of samples defined by the averager module
End ADC_Data;

architecture rtl of ADC_Data is

constant X : integer := 4; -- 4; -- X = log4(2**N), e.g. log4(2**8) = log4(4**4) = log4(256) = 4 (bits of resolution gained)

signal response_valid_out : STD_LOGIC;
signal ADC_raw_temp,ADC_out_ave : STD_LOGIC_VECTOR(11 DOWNTO 0);
signal voltage_temp       : STD_LOGIC_VECTOR(12 DOWNTO 0);
signal temp               : STD_LOGIC_VECTOR(11 DOWNTO 0);
signal Q_high_res         : STD_LOGIC_VECTOR(X+11 downto 0); -- (4+11 DOWNTO 0); -- first add (i.e. X) is log4(2**N), e.g. log4(2**8) = log4(256) = 4, must match X constant

component ADC_Conversion_wrapper is -- this brings in the ADC module, either as a hardware peripheral or as a simulation model
    Port( MAX10_CLK1_50      : in STD_LOGIC;
          response_valid_out : out STD_LOGIC;
          ADC_out            : out STD_LOGIC_VECTOR (11 downto 0)
         );
end component;
--******************************************************************************************************************************************
-- Comment out one of the two lines below, to select whether you want RTL (for DE10-Lite board) or simulation (for testbench) for the ADC **
--******************************************************************************************************************************************
for ADC_ins : ADC_Conversion_wrapper use entity work.ADC_Conversion_wrapper(RTL);        -- selects the RTL architecture
--for ADC_ins : ADC_Conversion_wrapper use entity work.ADC_Conversion_wrapper(simulation); -- selects the simulation architecture
--******************************************************************************************************************************************

Component voltage2distance_array2 IS -- converts ADC's voltage value to distance value
	PORT(                             -- according to Sharp GP2Y0A41SK0F Distance Sensor datasheet
		clk				:	IN		STD_LOGIC;											
		reset_n			:	IN		STD_LOGIC;											
		voltage			:	IN		STD_LOGIC_VECTOR(12 DOWNTO 0);									
		distance			:	OUT	STD_LOGIC_VECTOR(12 DOWNTO 0)
		);	
END Component;

component averager256 is -- calculates moving average of 256 12-bit samples
  generic(
	     N    : INTEGER;
        X    : INTEGER;
		  bits : INTEGER); 
	port (
		  clk     : in  std_logic;
		  EN      : in  std_logic; -- takes a new sample when high for each clock cycle
		  reset_n : in  std_logic; -- active-low
		  Din     : in  std_logic_vector(bits downto 0); -- input sample for moving average calculation
		  Q       : out std_logic_vector(bits downto 0)  -- 12-bit moving average of 256 samples
		  );
end component;


begin

voltage2distance_ins: voltage2distance_array2 
						PORT MAP( 
									 clk		 => clk,											
									 reset_n	 => reset_n,											
									 voltage	 => voltage_temp,									
									 distance => distance
									);

ADC_ins: ADC_Conversion_wrapper  PORT MAP(     
                       MAX10_CLK1_50      => clk,
                       response_valid_out => response_valid_out,
                       ADC_out            => ADC_raw_temp -- normally ADC_out_temp
									 );	

averager : averager256 generic map( -- change here to modify the number of samples to average
                       N    => 8,  -- 8, 10, -- log2(number of samples to average over), e.g. N=8 is 2**8 = 256 samples
							  X    => 4,  -- 4, 5, -- X = log4(2**N), e.g. log4(2**8) = log4(4**4) = log4(256) = 4 (bit of resolution gained)
							  bits => 11) -- 11 -- number of bits in the input data to be averaged
                       PORT MAP(
                       clk        => clk,
							  EN         => response_valid_out,
							  reset_n    => reset_n,
							  Din        => ADC_raw_temp,
							  Q          => ADC_out_ave
							  );
												
ADC_out <= ADC_out_ave;

ADC_raw <= ADC_raw_temp;

voltage_temp <= '0' & std_logic_vector(resize(unsigned(ADC_out_ave)*2500*2/(2**12),voltage_temp'length-1));  -- Converting ADC_out_ave, a 12-bit binary value, to voltage value (in mV), using type conversions
-- Above equation:  2**12 represents 2^12 = 4096, and this is scaling factor to normalize the ADC 12-bit value to 1 (technically 4095/4096 = 0.9997559). 
--                    Dividing by 4096 is trivial for digital hardware, it's just a shift of the binary point. Dividing by 4095 is difficult, resulting a complex divider that reduces the Fmax to 21.1 MHz.
--                    The difference in accuracy between /4096 and /4095 is neglible for this application. If you are curious, talk to Denis Onen about how to efficiently do /4095, he is an expert in these kinds of calculations.
--                  2500*2 represents the scaling factor to convert the normalized 12-bit ADC value to the ratiometric voltage value, in milli-volts (mV). 
--                     The ADC accepts a 2.5 V input signal (2500 mV) and converts it to a 12-bit ratiometric number. However, there is a 2:1 voltage divider before the ADC input, so the actual 
--                     input voltage range is 0V - 5V, which gets converted to a 12-bit ratiometric number. So, 2500*2 is 5000, but is written as 2500*2 to give the user the hint that there is voltage
--                     division going on at the ADC input. 

voltage <= voltage_temp;

end rtl;
