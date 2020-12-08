-- --- Seven segment component
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SevenSegment_decoder is
    Port ( 
           H        : out STD_LOGIC_VECTOR (7 downto 0);
           input    : in  STD_LOGIC_VECTOR (3 downto 0);
           DP,Blank : in  STD_LOGIC 
          );
end SevenSegment_decoder;

architecture Behavioral of SevenSegment_decoder is

signal seven_seg : STD_LOGIC_VECTOR (6 downto 0); 

begin
   Process (input,Blank)
   begin  
		if(Blank = '1') then
			seven_seg(6 downto 0)<="0000000"; -- this blanks the display
		else -- don't blank and display the required digit
															  --  Segments, 0=LED off, 1=LED on
			Case input is                         --  6543210                -- 7-Segment Display Segments
				when "0000" => seven_seg(6 downto 0)<="0111111"; -- 0                  0  
				when "0001" => seven_seg(6 downto 0)<="0000110"; -- 1                5   1
				when "0010" => seven_seg(6 downto 0)<="1011011"; -- 2                  6
				when "0011" => seven_seg(6 downto 0)<="1001111"; -- 3                4   2
				when "0100" => seven_seg(6 downto 0)<="1100110"; -- 4                  3    DP
				when "0101" => seven_seg(6 downto 0)<="1101101"; -- 5
				when "0110" => seven_seg(6 downto 0)<="1111101"; -- 6
				when "0111" => seven_seg(6 downto 0)<="0000111"; -- 7
				when "1000" => seven_seg(6 downto 0)<="1111111"; -- 8
				when "1001" => seven_seg(6 downto 0)<="1100111"; -- 9
				-- students add this block ------

				when "1010" => seven_seg(6 downto 0)<="1110111"; -- a
				when "1011" => seven_seg(6 downto 0)<="1111100"; -- b
				when "1100" => seven_seg(6 downto 0)<="0111001"; -- c
				when "1101" => seven_seg(6 downto 0)<="1011110"; -- d
				when "1110" => seven_seg(6 downto 0)<="1111001"; -- e
				when "1111" => seven_seg(6 downto 0)<="1110001"; -- f
				---------------------------------
				When others => seven_seg(6 downto 0)<="0000000"; -- blank display
			End Case;
		end if;
   End Process;

-- logic inversions in the 2 lines below is to turn the LEDs on when a 1 is given as a control signal,
-- to make it easier for the designer
H(6 downto 0) <= not seven_seg;
H(7) <= not DP; -- if DP=0 LED off, if DP=1 LED on

end Behavioral;
--   Another representation of the 7-segment display
--     0
--     _
--  5|   |1 
--     _
--     6
--  4|   |2
--     _    DP
--     3   
