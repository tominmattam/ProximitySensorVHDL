library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity mux is
port ( in1     : in  std_logic_vector(15 downto 0); 
       in2     : in  std_logic_vector(15 downto 0);
		 in3     : in  std_logic_vector(15 downto 0);
		 in4	   : in  std_logic_vector(15 downto 0);
       s       : in  std_logic_vector(1 downto 0);
       mux_out : out std_logic_vector(15 downto 0) 
      );
end mux; 

architecture BEHAVIOR of mux is

 begin
	process(in1,in2,in3,s)
		begin
		Case s is
			when "00" => mux_out <= in1;		--Mode 1: Hexadecimal Output
			when "01" => mux_out <= in2;		--Mode 2: Decimal Output
			when "10" => mux_out <= in3;		--Mode 3: Set Saved Output
			when "11" => mux_out <= in4;		--Mode 4: Hardcoded '5A5A'
			
			when others => mux_out <= "0000000000000000";		--Blank Display
		End Case;
	end process;
end BEHAVIOR; 