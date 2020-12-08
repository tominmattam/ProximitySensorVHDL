
-- In this example, we're going to map voltage to distance, using a linear 
-- approximation, according to the Sharp GP2Y0A41SK0F datasheet page 4. 
-- 
-- The relevant points we will select are:
-- 2.750 V is  4.00 cm (or 2750 mV and  40.0 mm)
-- 0.400 V is 33.00 cm (or  400 mV and 330.0 mm)
-- 
-- Mapping to the scales in our system
-- 2750 (mV) should map to  400 (10^-4 m)
--  400 (mV) should map to 3300 (10^-4 m)
-- and developing a linear equation, we find:
--
-- Distance = -2900/2350 * Voltage + 3793.617
-- Note this code implements linear function, you must map to the 
-- NON-linear relationship in the datasheet. This code is only provided 
-- for reference to help get you started.

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use work.LUT_pkg.all; -- note that this package stores the look up table, to make this code cleaner

ENTITY voltage2distance_array2 IS
   PORT(
      clk            :  IN    STD_LOGIC;                                
      reset_n        :  IN    STD_LOGIC;                                
      voltage        :  IN    STD_LOGIC_VECTOR(12 DOWNTO 0);                           
      distance       :  OUT   STD_LOGIC_VECTOR(12 DOWNTO 0));  
END voltage2distance_array2;

ARCHITECTURE behavior OF voltage2distance_array2 IS


begin
   -- This is the only statement required. It looks up the converted value of 
	-- the voltage input (in mV) in the v2d_LUT look-up table in the package, 
	-- and outputs the distance (in 10^-4 m) in std_logic_vector format.
    	
   distance <= std_logic_vector(to_unsigned(v2d_LUT(to_integer(unsigned(voltage))),distance'length));

end behavior;
