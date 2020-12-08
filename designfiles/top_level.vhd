library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
 
entity top_level is
    Port ( clk                           : in  STD_LOGIC;
           reset_n                       : in  STD_LOGIC;
			  s_button							  : in  STD_LOGIC;
			  SW                            : in  STD_LOGIC_VECTOR (9 downto 0);
			  buzzer								  : out STD_LOGIC;
           LEDR                          : out STD_LOGIC_VECTOR (9 downto 0);
           HEX0,HEX1,HEX2,HEX3,HEX4,HEX5 : out STD_LOGIC_VECTOR (7 downto 0)
          );
           
end top_level;

architecture Behavioral of top_level is

	-- Signals --

Signal Num_Hex0, Num_Hex1, Num_Hex2, Num_Hex3, Num_Hex4, Num_Hex5 : STD_LOGIC_VECTOR (3 downto 0):= (others=>'0');   
Signal DP1_in, DP2_in, Blank:  STD_LOGIC_VECTOR (5 downto 0);

Signal bcd:           STD_LOGIC_VECTOR(15 DOWNTO 0);			--Binary_bcd_output

Signal in1:           STD_LOGIC_VECTOR(15 DOWNTO 0);
Signal in2:				 STD_LOGIC_VECTOR(15 DOWNTO 0);
Signal s:             STD_LOGIC_VECTOR(1 DOWNto 0);			--Mux Selector Inputs
Signal mux_out:		 STD_LOGIC_VECTOR(15 DOWNTO 0);

Signal debounce_output:		std_logic;								--From debounce to register load
Signal sync_input:			std_logic_vector(9 downto 0);
Signal SW_SYNCED:				std_logic_vector(9 downto 0);	   --Synchronized switch inputs
Signal register_output:		std_logic_vector(15 downto 0);
Signal mode_select:			std_logic_vector(1 downto 0);		

Signal voltage:		std_logic_vector(12 downto 0);
Signal distance:		std_logic_vector(12 downto 0);
Signal ADC_raw:	   std_logic_vector(11 downto 0);
Signal ADC_out:		std_logic_vector(11 downto 0);

Signal voltage_binary:	std_logic_vector(15 downto 0);
Signal distance_binary: std_logic_vector(15 downto 0);

Signal inp1:     std_logic_vector(5 downto 0);
Signal inp2:     std_logic_vector(5 downto 0);
Signal muxd_out: std_logic_vector(5 downto 0);
Signal led_out: std_logic_vector(9 downto 0);

Signal pwm_distance: std_logic_vector(12 downto 0);

	-- Component Declaration --

Component SevenSegment is
    Port( Num_Hex0,Num_Hex1,Num_Hex2,Num_Hex3,Num_Hex4,Num_Hex5 : in  STD_LOGIC_VECTOR (3 downto 0);
          Hex0,Hex1,Hex2,Hex3,Hex4,Hex5                         : out STD_LOGIC_VECTOR (7 downto 0);
          DP_in,Blank                                           : in  STD_LOGIC_VECTOR (5 downto 0)
			);
End Component;

Component binary_bcd IS
   PORT(
      clk     : IN  STD_LOGIC;                      --system clock
      reset_n : IN  STD_LOGIC;                      --active low asynchronus reset_n
      binary  : IN  STD_LOGIC_VECTOR(12 DOWNTO 0);  --binary number to convert
      bcd     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)   --resulting BCD number
		);           
END Component;

Component mux IS   
   PORT(
 		   in1	  :	in std_logic_vector(15 downto 0);
			in2     :	in std_logic_vector(15 downto 0);
			in3     :	in std_logic_vector(15 downto 0);
			in4	  : 	in std_logic_vector(15 downto 0);
			s		  :	in std_logic_vector(1 downto 0);
			mux_out :	out std_logic_vector(15 downto 0)
  		 );
END Component;

Component Reg is
	PORT(
			LD		   	: in std_logic;
			CLK			: in std_logic;
			RST   		: in std_logic;
			D				: in std_logic_vector(15 downto 0);
			Q				: out std_logic_vector(15 downto 0)
		);
END Component;

Component SelectorReg is
	PORT(
			LD				: in std_logic;
			CLK			: in std_logic;
			RST			: in std_logic;
			D				: in std_logic_vector(1 downto 0);
			Q				: out std_logic_vector(1 downto 0)
		 );
END Component;

Component debounce is
	generic ( clk_freq    : integer;
				 stable_time : integer
		      );
	PORT(
			button			: in std_logic;
			clk			: in std_logic;
			reset_n		: in std_logic;
			result		: out std_logic
		);
END Component;

Component sync is
	PORT(
			CLK			: in std_logic;
			RST   		: in std_logic;
			SW				: in std_logic_vector(9 downto 0);
			SW_SYNCED	: out std_logic_vector(9 downto 0)
		);
END Component;

Component ADC_Data is
	PORT(
			 clk      : in std_logic;
	       reset_n  : in std_logic; 								-- active-low
			 voltage  : out std_logic_vector(12 downto 0); -- Voltage in milli-volts
			 distance : out std_logic_vector(12 downto 0); -- distance in 10^-4 cm (e.g. if distance = 33 cm, then 3300 is the value)
			 ADC_raw  : out std_logic_vector(11 downto 0); -- the latest 12-bit ADC value
          ADC_out  : out std_logic_vector(11 downto 0)  -- moving average of ADC value, over 256 samples, 
		 );
END Component;


Component muxd is
	PORT(
			inp1			: in std_logic_vector(5 downto 0);
			inp2			: in std_logic_vector(5 downto 0);
			s           : in std_logic_vector(1 downto 0);
			muxd_out    : out std_logic_vector(5 downto 0)
		 );
END Component;

Component dist_checker is
	port( clk      : in std_logic;
			reset_n  : in std_logic;
			raw_dist : in std_logic_vector(12 downto 0);
			pwm_dist : out std_logic_vector(12 downto 0)
		 );
End Component;

Component LEDR_module is
	generic ( dist_width       : integer;
				 dist_upper_limit : integer;
				 step             : integer
	        );
   port    ( clk            :  IN     STD_LOGIC;                                
             reset_n        :  IN     STD_LOGIC;                                
             input_distance :  IN     STD_LOGIC_VECTOR(dist_width-1 DOWNTO 0); 	 
             LEDR_out       :  OUT    STD_LOGIC_VECTOR(9 downto 0)
			  ); 
end Component;

Component flashing is
	 generic ( dist_width       : integer;
				  dist_upper_limit : integer;
				  period           : integer
				);
	 Port( clk            : in std_logic;
          reset_n        : in std_logic;
          input          : in std_logic_vector(12 downto 0);
          pwm_output     : out std_logic_vector(5 downto 0)
        );
END Component;

Component buzzermodule is
	generic ( dist_width       : integer;
				 dist_upper_limit : integer;
				 period	         : integer
			  );
	Port( clk            : in std_logic;
         reset_n        : in std_logic;
         input          : in std_logic_vector(12 downto 0);
         pwm_output     : out std_logic
       );
End Component;

begin
 
	-- Signal Connections --
 
	Num_Hex0 <= register_output(3 downto 0);
	Num_Hex1 <= register_output(7 downto 4);
	Num_Hex2 <= register_output(11 downto 8);
   Num_Hex3 <= register_output(15 downto 12);
   Num_Hex4 <= "0000";
   Num_Hex5 <= "0000";   
	DP1_in   <= "001000";			--Decimal place for voltage
	DP2_in   <= "000100";			--Deciaml place for distance

             
	in1 <= "000000" & SW_SYNCED(9 downto 0);	--in1 is sw_synced output (decimal)
	in2 <= "0000"  & ADC_out(11 downto 0);		--in2 is ADC_out extended to 16 bits
	
	sync_input <= SW(9 downto 0);		--raw switch input for synchronizer input
	
	s <= SW_SYNCED(9 downto 8);		--synced switch inputs 9 and 8 into selector for mux
 
	LEDR(9 downto 0) <= led_out(9 downto 0);
 
	-- Component Instantiation --

mux_ins: mux
		PORT MAP(	in1 	  => in1,					--SW_SYNCED transformed into 16 bit signal for mux
						in2	  => in2,				   --output from averager into mux
						in3     => voltage_binary,	   --output from binary converted voltage
						in4	  => distance_binary,   --output from binary converter distance
						s   	  => s,						--selector from switches 9 and 8
						mux_out => mux_out				--mux output to register
				  );
				  
Reg_ins: Reg
		PORT MAP(	LD 		=> debounce_output,  --from debounce logic to register load
						D 			=> mux_out,				--mux output into register input
						CLK 		=> clk,
						RST      => reset_n,
						Q 			=> register_output	--saved mux output
					);
					
SelectorReg_ins: SelectorReg
		PORT MAP(	LD 		=> debounce_output,  
						D 			=> s,				      
						CLK 		=> clk,
						RST      => reset_n,
						Q 			=> mode_select	
					);
									
debounce_ins: debounce
		generic map ( clk_freq     => 50_000_000,
						  stable_time  => 10
					   )
		PORT MAP(	button 	=> s_button,			--Change into proper signal from button
						clk 		=> clk,
						reset_n 	=> reset_n,
						result	=> debounce_output
					);
		
sync_ins: sync
		PORT MAP(	SW 		 => sync_input,	   --Double Check signal from switches, Raw switch input
						CLK 		 => clk,
						RST      => reset_n,
						SW_SYNCED => SW_SYNCED		   --synced switch input, signal is only 10 bits wide
					);

SevenSegment_ins: SevenSegment  
      PORT MAP(	Num_Hex0 => Num_Hex0,
						Num_Hex1 => Num_Hex1,
						Num_Hex2 => Num_Hex2,
						Num_Hex3 => Num_Hex3,
						Num_Hex4 => Num_Hex4,
						Num_Hex5 => Num_Hex5,
						Hex0     => Hex0,
						Hex1     => Hex1,
						Hex2     => Hex2,
						Hex3     => Hex3,
						Hex4     => Hex4,
						Hex5     => Hex5,
						DP_in    => muxd_out,
						Blank    => Blank
              );
                                     
ADC_Data_ins: ADC_Data
		PORT MAP(   clk 		  => clk,
						reset_n    => reset_n,
						voltage    => voltage,
						distance   => distance,
						ADC_raw    => ADC_raw,
						ADC_out    => ADC_out
					);							 
								 									 
binary_bcd_volt_ins: binary_bcd                          
		PORT MAP(	clk      => clk,                          
						reset_n  => reset_n,                                 
						binary   => voltage,    
						bcd      => voltage_binary         
					);
					
binary_bcd_dist_ins: binary_bcd                            
		PORT MAP(	clk      => clk,                          
						reset_n  => reset_n,                                 
						binary   => pwm_distance,    
						bcd      => distance_binary         
					);
					
				  
muxd_ins: muxd
		PORT MAP( inp1     => DP1_in,
					 inp2     => DP2_in,
					 s        => mode_select,
					 muxd_out => muxd_out
				   );
					
dist_checker_ins: dist_checker
	   PORT MAP( clk      => clk,
					 reset_n  => reset_n,
					 raw_dist => distance,
					 pwm_dist => pwm_distance
					);
					
LEDR_module_ins: LEDR_module
		generic map( dist_width       => 13,
						 dist_upper_limit => 4230,
						 step             => 12
					  )
		PORT MAP   ( clk            => clk,                          
					    reset_n        => reset_n, 
				       input_distance => pwm_distance,
				       LEDR_out       => led_out
					  );
					
flashing_ins: flashing
		generic map( dist_width       => 13,
					    dist_upper_limit => 2000,
					  --period				=> 100   Uncomment when simulating, easier to see waveforms
						 period		      => 6000
					  )
		PORT MAP   ( clk        => clk,
                   reset_n    => reset_n,
                   input      => pwm_distance,
                   pwm_output => Blank
                 );
					  
buzzermodule_ins: buzzermodule 
		generic map(dist_width       => 13,
						dist_upper_limit => 4230,
						period	        => 100
					  )
      Port Map   ( clk        => clk,        
					    reset_n    => reset_n, 
					    input      => pwm_distance,       
                   pwm_output => buzzer
                 );
end Behavioral;