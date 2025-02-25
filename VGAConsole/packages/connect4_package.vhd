library ieee;
use ieee.std_logic_1164.all;
use work.properties_package.all;
use work.shape_package.all;



package connect4_package is
		procedure drawBoard(
					variable x, y              : in natural;
					constant color             : std_logic_vector(2 downto 0);
					signal r, g, b             : out std_logic_vector(9 downto 0));
			
		procedure chipCounter
							(
							signal   chipClk, reset     : in  std_logic;
							signal   sel0, sel1,
									 sel2, sel3,
									 sel4, sel5         : in  std_logic_vector(1 downto 0);
							signal   chip0, chip1,
									 chip2, chip3,
									 chip4, chip5       : out natural range 0 to 480);
		procedure drawP1orP2(
							variable x, y 		 	   : in  natural;
							signal   sel0, sel1,
									 sel2, sel3,
									 sel4, sel5         : in  std_logic_vector(1 downto 0);
							constant xPos, 
							         yPos0,
									 yPos1,
									 yPos2,
									 yPos3,
									 yPos4,
									 yPos5    		   : in  integer;
							signal   r, g, b   	       : out std_logic_vector(9 downto 0));

end package;



package body connect4_package is

	procedure drawBoard(
					variable x, y              : in natural;
					constant color             : std_logic_vector(2 downto 0);
					signal r, g, b             : out std_logic_vector(9 downto 0)) is
					
begin

		drawBox(x, y, 120, 140, 100, 400, color, r, g, b); --column0
		drawBox(x, y, 170, 190, 100, 400, color, r, g, b); --column1
		drawBox(x, y, 220, 240, 100, 400, color, r, g, b); --column2
		drawBox(x, y, 270, 290, 100, 400, color, r, g, b); --column3
		drawBox(x, y, 320, 340, 100, 400, color, r, g, b); --column4
		drawBox(x, y, 370, 390, 100, 400, color, r, g, b); --column5
		drawBox(x, y, 420, 440, 100, 400, color, r, g, b); --column6
		drawBox(x, y, 470, 490, 100, 400, color, r, g, b); --columb7
	------------------------------------------------------------------------	
		drawBox(x, y, 120, 490, 100, 120, color, r, g, b); --row0
		drawBox(x, y, 120, 490, 150, 170, color, r, g, b); --row1
		drawBox(x, y, 120, 490, 200, 220, color, r, g, b); --row2
		drawBox(x, y, 120, 490, 250, 270, color, r, g, b); --row3
		drawBox(x, y, 120, 490, 300, 320, color, r, g, b); --row4
		drawBox(x, y, 120, 490, 350, 370, color, r, g, b); --row5
		drawBox(x, y, 120, 490, 399, 419, color, r, g, b); --row6
		
end procedure;


	procedure chipCounter(
							signal   chipClk, reset     : std_logic;
							signal   sel0, sel1,
									 sel2, sel3,
									 sel4, sel5         : in  std_logic_vector(1 downto 0);
							signal   chip0, chip1,
									 chip2, chip3,
									 chip4, chip5       : inout natural range 0 to 480) is
									
begin

	
	if(rising_edge(chipClk)) then
		if(sel0 /= "11") then
			if(chip5 < 385) then chip5 <= chip5 + 1;
			else                 chip5 <= chip5;
			end if;
		end if;

		if(sel1 /= "11") then
			if(chip4 < 335) then chip4 <= chip4 + 1;
			else                 chip4 <= chip4;
			end if;
		end if;
		
		if(sel2 /= "11") then
			if(chip3 < 285) then chip3 <= chip3 + 1;
			else                 chip3 <= chip3;
			end if;
		end if;
		
		if(sel3 /= "11") then
			if(chip2 < 235) then chip2 <= chip2 + 1;
			else                 chip2 <= chip2;
			end if;
		end if;
		
		if(sel4 /= "11") then
			if(chip1 < 185) then chip1 <= chip1 + 1;
			else                 chip1 <= chip1;
			end if;
		end if;
		
		if(sel5 /= "11") then
			if(chip0 < 135) then chip0 <= chip0 + 1;
			else                 chip0 <= chip0;
			end if;
		end if;
	end if;
end procedure;
	procedure drawP1orP2(
							variable x, y 		 	   : in  natural;
							signal   sel0, sel1,
									 sel2, sel3,
									 sel4, sel5         : in  std_logic_vector(1 downto 0);
							signal   xPos, 
							         yPos0,
									 yPos1,
									 yPos2,
									 yPos3,
									 yPos4,
									 yPos5    		   : in  integer;
							signal   r, g, b   	       : out std_logic_vector(9 downto 0)) is
begin
						
						--drawDisc(x, y, xPos0, yPos0, 
						if   (sel0 = "01") then drawDiscs(x, y, xPos, yPos0, 200, color(4), r, g, b);
						elsif(sel0 = "10") then drawDiscs(x, y, xPos, yPos0, 200, color(1), r, g, b);
						elsif(sel0 = "11") then null;
						else                   null;
						end if;
						
						if   (sel1 = "01") then drawDiscs(x, y, xPos, yPos1, 200, color(4), r, g, b);
						elsif(sel1 = "10") then drawDiscs(x, y, xPos, yPos1, 200, color(1), r, g, b);
						elsif(sel1 = "11") then null;
						else                   null;
						end if;
						
						if   (sel2 = "01") then drawDiscs(x, y, xPos, yPos2, 200, color(4), r, g, b);
						elsif(sel2 = "10") then drawDiscs(x, y, xPos, yPos2, 200, color(1), r, g, b);
						elsif(sel2 = "11") then null;
						else                   null;
						end if;
						
						if   (sel3 = "01") then drawDiscs(x, y, xPos, yPos3, 200, color(4), r, g, b);
						elsif(sel3 = "10") then drawDiscs(x, y, xPos, yPos3, 200, color(1), r, g, b);
						elsif(sel3 = "11") then null;
						else                   null;
						end if;
						
						if   (sel4 = "01") then drawDiscs(x, y, xPos, yPos4, 200, color(4), r, g, b);
						elsif(sel4 = "10") then drawDiscs(x, y, xPos, yPos4, 200, color(1), r, g, b);
						elsif(sel4 = "11") then null;
						else                   null;
						end if;
						
						if   (sel5 = "01") then drawDiscs(x, y, xPos, yPos5, 200, color(4), r, g, b);
						elsif(sel5 = "10") then drawDiscs(x, y, xPos, yPos5, 200, color(1), r, g, b);
						elsif(sel5 = "11") then null;
						else                   null;
						end if;
						
end procedure;


end package body;