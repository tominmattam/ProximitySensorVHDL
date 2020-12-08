--------------------------------------------------------------------------------
--
--  Filename: sync.vhd
--
--  Author: Tomin Mattam
--------------------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.all;


entity sync is 

	port( SW: in std_logic_vector ( 9 downto 0);
			RST : IN  STD_LOGIC;
			SW_SYNCED: out std_logic_vector ( 9 downto 0);
			CLK: in std_logic
		 );
			
end sync;


architecture behav  of sync is 

signal E: std_logic_vector( 9 downto 0);

begin 


process(CLK)

begin	
		if RST ='0' then
		E <= (others => '0');
		SW_SYNCED <= (others => '0');
		elsif rising_edge(CLK) then 
		E <= SW;
		SW_SYNCED <= E;
		
		end if;
		
		end process;

end behav;