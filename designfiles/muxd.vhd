library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity muxd is
port ( inp1     : in  std_logic_vector(5 downto 0); 
       inp2     : in  std_logic_vector(5 downto 0);
       s        : in  std_logic_vector(1 downto 0);
       muxd_out : out std_logic_vector(5 downto 0) 
      );
end muxd; 

architecture BEHAVIOUR of muxd is

 begin
	process(inp1,inp2,s)
		begin
		Case s is
			when "10" => muxd_out <= inp1;		--Mode 1: Voltage
			when "11" => muxd_out <= inp2;		--Mode 2: Distance
			
			when others => muxd_out <= "000000";		--Blank Display
		End Case;
	end process;
end BEHAVIOUR; 