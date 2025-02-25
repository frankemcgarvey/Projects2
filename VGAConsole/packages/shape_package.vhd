library ieee;
use ieee.std_logic_1164.all;

package shape_package is 
	function radius (x : natural; y : natural; xPos : integer; yPos : integer;  constnt : natural)
	return boolean;
	
	
	procedure colours(
						constant color         : in  std_logic_vector(2 downto 0);
						signal   r, g, b       : out std_logic_vector(9 downto 0));
	procedure drawDisc(
						variable x, y              : in  natural;
						signal xPos                : in  integer;
						variable yPos              : in  integer;
						constant constnt           : in  natural;
						constant color             : in  std_logic_vector(2 downto 0);
						signal   r, g, b           : out std_logic_vector(9 downto 0));
	procedure drawDiscs(
						variable x, y              : in  natural;
						constant xPos              : in  integer;
						constant yPos              : in  integer;
						constant constnt           : in  natural;
						constant color             : in  std_logic_vector(2 downto 0);
						signal   r, g, b           : out std_logic_vector(9 downto 0));
						
						
	procedure drawRing(
						variable x, y              : in integer;
						constant xStart, yStart,
								 ring, iRing       : in natural;
						constant color             : std_logic_vector(2 downto 0);
						signal r, g, b             : out std_logic_vector(9 downto 0));
	
				
	procedure drawBox(
						variable x, y              : in natural;
						constant xStart, xEnd,
								 yStart, yEnd      : in natural;
						constant color             : std_logic_vector(2 downto 0);
						signal r, g, b             : out std_logic_vector(9 downto 0));	
						
	procedure drawBoxTB(
						variable x, y              : in natural;
						signal   xPos, yPos        : in natural;
						constant size, thicc       : in natural;
						constant color             : std_logic_vector(2 downto 0);
						signal r, g, b             : out std_logic_vector(9 downto 0));		
	procedure drawBoxRL(
						variable x, y              : in natural;
						signal   xPos, yPos        : in natural;
						constant size, thicc       : in natural;
						constant color             : std_logic_vector(2 downto 0);
						signal r, g, b             : out std_logic_vector(9 downto 0));			
						
	procedure drawRect(
						variable x, y              : in natural;
						constant xStart, xEnd,
								 yStart, yEnd      : in natural;
						constant color             : std_logic_vector(2 downto 0);
						signal r, g, b             : out std_logic_vector(9 downto 0));
					
	procedure drawX(
						 variable x, y           : in  natural;
						  constant size           : in  natural;
						  constant xPosL, xPosR, 
						           yPos           : in  integer;
						  constant color          : in  std_logic_vector(2 downto 0);
						  signal   r, g, b        : out std_logic_vector(9 downto 0)); 	
						
	procedure drawDiaganolRL(
						  variable x, y           : in  natural;
						  constant size           : in  natural;
						  constant xPos, yPos     : in  integer;
						  constant color          : in  std_logic_vector(2 downto 0);
						  signal   r, g, b        : out std_logic_vector(9 downto 0)); 
						
	procedure drawDiaganolLR(
						  variable x, y           : in  natural;
						  constant size           : in  natural;
						  constant xPos, yPos     : in  integer;
						  constant color          : in  std_logic_vector(2 downto 0);
						  signal   r, g, b        : out std_logic_vector(9 downto 0));
	
end package;
---------------------------------
---------------------------------
package body shape_package is
	
--------------------------------------------------------------------------------------------
	function radius (x : natural; y : natural; xPos : integer; yPos : integer; constnt : natural)
	return boolean is
begin
	
	return (((x-xPos)**2 + (y-yPos)**2) < constnt);
	
end function radius;
---------------------------------------------------------------------------------------------
	procedure colours(
						constant color         : in  std_logic_vector(2 downto 0);
						signal   r, g, b       : out std_logic_vector(9 downto 0)) is
begin
	case(color) is
		when "000" => r <= (others => '0'); g <= (others => '0'); b <= (others => '0');
	    when "001" => r <= (others => '0'); g <= (others => '0'); b <= (others => '1');
	    when "010" => r <= (others => '0'); g <= (others => '1'); b <= (others => '0');
	    when "011" => r <= (others => '0'); g <= (others => '1'); b <= (others => '1');
	    when "100" => r <= (others => '1'); g <= (others => '0'); b <= (others => '0');
	    when "101" => r <= (others => '1'); g <= (others => '0'); b <= (others => '1');
	    when "110" => r <= (others => '1'); g <= (others => '1'); b <= (others => '0');
	    when "111" => r <= (others => '1'); g <= (others => '1'); b <= (others => '1');
		when others => r <= (others => '1'); g <= (others => '1'); b <= (others => '1');
	end case;

end procedure colours;
---------------------------------------------------------------------------------------------
	procedure drawDiscs(
						variable x, y              : in  natural;
						signal xPos                : in  integer;
						signal yPos              : in  integer;
						constant constnt           : in  natural;
						constant color             : in  std_logic_vector(2 downto 0);
						signal   r, g, b           : out std_logic_vector(9 downto 0)) is
begin
	
	if(radius(x, y, xPos, yPos, constnt)) then colours(color,r,g,b);
	end if;
	
end procedure;
---------------------------------------------------------------------------------------------
	procedure drawDisc(
						variable x, y              : in  natural;
						signal xPos              : in  integer;
						variable yPos              : in  integer;
						constant constnt           : in  natural;
						constant color             : in  std_logic_vector(2 downto 0);
						signal   r, g, b           : out std_logic_vector(9 downto 0)) is
						
begin
	
	if(radius(x, y, xPos, yPos, constnt)) then colours(color,r,g,b);
	end if;
	
end procedure;
--------------------------------------------------------------------------------------------
	procedure drawRing(
						variable x, y              : in integer;
						constant xStart, yStart,
								 ring, iRing       : in natural;
						constant color             : std_logic_vector(2 downto 0);
						signal r, g, b             : out std_logic_vector(9 downto 0)) is
begin

	if (((x-xStart)**2+(y-yStart)**2<=ring) and ((x-xStart)**2+(y-yStart)**2>=iRing))
	then colours(color, r, g, b);
	end if;
end procedure;
--------------------------------------------------------------------------------------------
procedure drawDiaganolRL(
						  variable x, y           : in  natural;
						  constant size           : in  natural;
						  constant xPos, yPos     : in  integer;
						  constant color          : in  std_logic_vector(2 downto 0);
						  signal   r, g, b        : out std_logic_vector(9 downto 0))  is
						
begin


	if((y < (x-xPos)) and ((0 <= (y - yPos)) and ((y - yPos) < size)) and (y > (x-xPos)-20)) then colours(color, r, g, b);
	end if;
end procedure;
-----------------
					
	procedure drawDiaganolLR(
						  variable x, y           : in  natural;
						  constant size           : in  natural;
						  constant xPos, yPos     : in  integer;
						  constant color          : in  std_logic_vector(2 downto 0);
						  signal   r, g, b        : out std_logic_vector(9 downto 0)) is
begin


	if((-y < (x-xPos)) and ((0 <= (y - yPos)) and ((y - yPos) < size)) and (-y>(x-xPos)-20)) then colours(color, r, g, b);
	end if;

end procedure;
---------------------------------------------------------------------------------------------------------------------
procedure drawX(
						  variable x, y           : in  natural;
						  constant size           : in  natural;
						  constant xPosL, xPosR, 
						           yPos           : in  integer;
						  constant color          : in  std_logic_vector(2 downto 0);
						  signal   r, g, b        : out std_logic_vector(9 downto 0)) is
						
begin

	drawDiaganolLR(x, y, size, xPosL, yPos, color, r, g, b);
	drawDiaganolRL(x, y, size, xPosR, yPos, color, r, g, b);
	
end procedure;	
--------------------------------------------------------------------------------------------
	procedure drawBox(
						variable x, y              : in natural;
						constant xStart, xEnd,
								 yStart, yEnd      : in natural;
						constant color             : std_logic_vector(2 downto 0);
						signal   r, g, b           : out std_logic_vector(9 downto 0)) is
begin

	if((xStart < x) and (x < xEnd) and (yStart < y) and (y < yEnd)) then colours(color, r, g, b);
	end if;

end procedure;

procedure drawBoxTB(
						variable x, y              : in natural;
						signal   xPos, yPos        : in natural;
						constant size, thicc       : in natural;
						constant color             : std_logic_vector(2 downto 0);
						signal   r, g, b           : out std_logic_vector(9 downto 0)) is
begin

	if((xPos-thicc < x) and (x < xPos + thicc) and (yPos - size < y) and (y < yPos+size)) then colours(color, r, g, b);
	end if;

end procedure;

procedure drawBoxRL(
						variable x, y              : in natural;
						signal   xPos, yPos        : in natural;
						constant size, thicc       : in natural;
						constant color             : std_logic_vector(2 downto 0);
						signal   r, g, b           : out std_logic_vector(9 downto 0)) is
begin

	if((xPos+size < x) and (x+size < xPos) and (yPos-thicc < y) and (y < yPos+thicc)) then colours(color, r, g, b);
	end if;

end procedure;
---------------------------------------------------------------------------------------------------------
procedure drawRect(
						variable x, y              : in natural;
						constant xStart, xEnd,
								 yStart, yEnd      : in natural;
						constant color             : std_logic_vector(2 downto 0);
						signal r, g, b             : out std_logic_vector(9 downto 0)) is
						 
begin

	drawBox(x, y, xStart, xEnd, yStart, yEnd, color, r, g, b);
	drawBox(x, y, xStart, xEnd, yStart, yEnd, color, r, g, b);
	drawBox(x, y, xStart, xEnd, yStart, yEnd, color, r, g, b);
	drawBox(x, y, xStart, xEnd, yStart, yEnd, color, r, g, b);

end procedure;
	
end package body;
----------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
--Properties of the circles------------------------------------------------------------------------
package properties_package is
	type colorProperty  is array(0 to 7) of std_logic_vector(2 downto 0);
	type radiusProperty is array(0 to 4) of natural range 0 to 10_000;
	
	constant color    : colorProperty  := ("000", "001", "010", "011", "100", "101", "110", "111");
	
	constant radii1   : radiusProperty := (10, 90, 270, 550, 1000);
	constant radii2   : radiusProperty := (50, 400, 1000, 2000, 3200);
	constant radii3   : radiusProperty := (70, 500, 1200, 2300, 3500);
end package;
		