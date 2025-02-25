library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_divider is
	port(
	clk							 : in     std_logic;
	clk25,
	target_clock0, 
	target_clock1, 
	target_clock2        	     : buffer std_logic := '0');
end clock_divider;
  
architecture behavior of clock_divider is
  
  
begin

	process(clk)
	variable counter1 : integer := 0;
	variable counter2 : integer := 0;
	variable counter3 : integer := 0;
	begin
	if(rising_edge(clk)) then
		counter1 := counter1 + 1;
		if (counter1 = 50_000) then
 		target_clock0 <= not target_clock0;
		counter1 := 0;
		end if;
	end if;
	if(rising_edge(clk)) then
		counter2 := counter2 + 1;
		if (counter2 = 200_000) then
 		target_clock1 <= not target_clock1;
		counter2 := 0;
		end if;
	end if;
	
	if(rising_edge(clk)) then
		counter3 := counter3 + 1;
		if (counter3 = 700_000) then
 		target_clock2 <= not target_clock2;
		counter3 := 0;
		end if;
	end if;
	
	if(rising_edge(clk)) then clk25 <= not clk25;
	end if;		
	end process;

end behavior;