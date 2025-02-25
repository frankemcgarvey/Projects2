library ieee;
use ieee.std_logic_1164.all;
use work.shape_package.all;
use work.ttt_package.all;
use work.properties_package.all;
use work.counter_package.all;
use work.target_package.all;
use work.connect4_package.all;
use ieee.numeric_std.all;

entity connect4Game is
	port(
	clk50,
	clk25,
	chipClk,
	Lt, Rt,
	button,
	inReplay, inToMenu,
	reset,
	dena,
	hsync, 
	hActive, vActive        : in  std_logic := '0';
	replay, toMenu          : out std_logic := '0';
	r, g, b                 : out std_logic_vector(9 downto 0) := (others => '0'));
end connect4Game;

architecture FSM of connect4Game is
-----------------------------
--Declare data types here----
-----------------------------

-----------------------------
--States---------------------
-----------------------------

	type cursorState is (column0, column1, column2, column3, column4, column5, column6);
	signal prev_cursorState, next_cursorState : cursorState := column0;

	type gameState is (Start, Play, Menu0, Menu1, Menu2);
	signal prev_gameState, next_gameState : gameState := Play;
	
	type drawState is (Idle, Check, drawP1, drawP2);
	signal next_drawState, prev_drawState : drawState := Idle;
	
-----------------------------

-----------------------------
--Data Types-----------------
-----------------------------

	--Game Pixels---------------
	signal xPix      : natural range 0 to 800;
	signal yPix      : natural range 0 to 525;
	----------------------------

	--Field and symbol-------------------------------
	constant O1     : std_logic_vector(1 downto 0) := "01";
	constant O2     : std_logic_vector(1 downto 0) := "10";
	constant U      : std_logic_vector(1 downto 0) := "11";
	
	type field is array(0 to 6, 0 to 5) of std_logic_vector(1 downto 0);
	signal fieldMap : field := (others => (others => U));
	-------------------------------------------------
	--Win Conditions---------------------------------
	signal p1, p2 : std_logic_vector (3 downto 0)  := (others => '0');
	signal drawCounter  : natural range 0 to 42 := 0;
	--Player Data-----------------------
	signal player    : std_logic := '0';
	------------------------------------

	
					
	--Box Locations-------------
	type xcoordinate is array(0 to 6) of natural range 0 to 640;
	type ycoordinate is array(0 to 5) of natural range 0 to 480;
	constant xCoord    : xcoordinate := (155, 205, 255, 305, 355, 405, 455);
	constant yCord     : ycoordinate := (135, 185, 235, 285, 335, 385);

	-----------------------------

	--Chip Data------------------------
	type   chipsCounter is array(0 to 6, 0 to 5) of natural range 0 to 480;
	signal chipCounters : chipsCounter := (others => (others => 79)); 
	
	signal xChip        : xcoordinate := (155, 205, 255, 305, 355, 405, 455);
	-----------------------------------
	--Reticule Data-------------
	signal xPos      : natural range 0 to 800;
	signal yPos      : natural range 0 to 525 := 90;
	constant yCoord  : natural := 90;
	----------------------------
	--Shape Locations------------
--	constant x_oCoord  : coordinate := (205, 320, 425);
--	constant y_oCoord  : coordinate := (360, 250, 140);
	-----------------------------
	--Cursor Data----------------
	signal cursorTrigger,
		   cursorRefresh   : std_logic := '0';
	signal cursorTimer     : natural range 0 to 60;
	-----------------------------
	
	--Draw Data------------------
	type counters is array(0 to 6) of integer range 0 to 5;
	signal drawTrigger,
		   drawRefresh     : std_logic := '0';
	signal drawTimer       : natural range 0 to 60;
	signal index           : counters := (others => 0);
	signal number          : natural range 0 to 6 := 0;
	signal allow           : std_logic := '0';
	-----------------------------
	
	--Game Data-----------------
	signal startGame     : std_logic := '0';
	signal gameTime     : natural range 0 to 60;
	----------------------------

begin
	 
	--Pixel Counters-------
	
	process(clk25) --Counts columns
	begin
	pos_edgeCounter(clk25, Hactive, xPix);
	end process;
	
	process(hsync)
	begin
	pos_edgeCounter(hsync, Vactive, yPix); --Counts rows
	end process;
	-----------------------

---------------------------------------------------------------------------------------------
--Timer for cursorConroller------------------------------------------------------------------
---------------------------------------------------------------------------------------------

	process(clk50)
	
	variable cursorRefreshTime   : integer range 0 to 50_000_000 := 0;
	begin
 
	if(cursorTrigger = '1') then 
									cursorTimer        <= 0;
									cursorRefreshTime  := 0;
	elsif(rising_edge(clk50)) then 
			if(cursorRefreshTime = 15_000_000) then cursorRefreshTime := cursorRefreshTime;							   
													cursorTimer <= 1;
			else                                    cursorRefreshTime := cursorRefreshTime + 1;
			end if;
	end if;
	end process;


----------------------------------------------------------------------------------------------
--FSM for cursorController-------------------------------------------------------------------------
----------------------------------------------------------------------------------------------	
	process(clk50)
	begin
	if(rising_edge(clk50)) then 
		
		if(reset = '1') then prev_cursorState <= column0;
		else                 prev_cursorState <= next_cursorState;
		end if;
	end if;
	end process;
	
	process(prev_cursorState)
	begin
		
		case (prev_cursorState) is 

		when column0 =>
		
				number <= 0;
							 
				cursorRefresh <= '0';
				if(cursorTimer = 1) then
					if   (Lt = '1' and Rt = '0' and Button = '0') then next_cursorState <= column0; cursorRefresh <= '1';
					elsif(Lt = '0' and Rt = '1' and Button = '0') then next_cursorState <= column1; cursorRefresh <= '1';
					else                                               next_cursorState <= column0;
					end if;
				else                  								   next_cursorState <= column0;
				end if;                  
		when column1 =>
		
				number <= 1;
							 
				cursorRefresh <= '0';
				if(cursorTimer = 1) then
					if   (Lt = '1' and Rt = '0' and Button = '0') then next_cursorState <= column0; cursorRefresh <= '1';
					elsif(Lt = '0' and Rt = '1' and Button = '0') then next_cursorState <= column2; cursorRefresh <= '1';
					else                							   next_cursorState <= column1;
					end if;
				else                   								   next_cursorState <= column1;
				end if;
		when column2 =>
		
				number <= 2;
							 
				cursorRefresh <= '0';
				if(cursorTimer = 1) then
					if   (Lt = '1' and Rt = '0' and Button = '0') then next_cursorState <= column1; cursorRefresh <= '1';
					elsif(Lt = '0' and Rt = '1' and Button = '0') then next_cursorState <= column3; cursorRefresh <= '1';
					else                                               next_cursorState <= column2;
					end if;
				else					                               next_cursorState <= column2;
				end if;
		
		when column3 =>	
		
				number <= 3;
						 
				cursorRefresh <= '0';
				if(cursorTimer = 1) then
					if   (Lt = '1' and Rt = '0' and Button = '0') then next_cursorState <= column2; cursorRefresh <= '1';
					elsif(Lt = '0' and Rt = '1' and Button = '0') then next_cursorState <= column4; cursorRefresh <= '1';
					else                 							   next_cursorState <= column3; 
					end if;
				else                     							   next_cursorState <= column3;
				end if;
		when column4 =>	
		
				number <= 4;
							
				cursorRefresh <= '0';
				if(cursorTimer = 1) then
					if   (Lt = '1' and Rt = '0' and Button = '0') then next_cursorState <= column3; cursorRefresh <= '1';
					elsif(Lt = '0' and Rt = '1' and Button = '0') then next_cursorState <= column5; cursorRefresh <= '1';
					else                 							   next_cursorState <= column4; 
					end if;
				else                     							   next_cursorState <= column4;
				end if;
		when column5 =>	
		
		
				number <= 5;
						
				cursorRefresh <= '0';
				if(cursorTimer = 1) then
					if   (Lt = '1' and Rt = '0' and Button = '0') then next_cursorState <= column4; cursorRefresh <= '1';
					elsif(Lt = '0' and Rt = '1' and Button = '0') then next_cursorState <= column6; cursorRefresh <= '1';
					else                 							   next_cursorState <= column5;
					end if;
				else                     							   next_cursorState <= column5;
				end if;
		when column6 =>	
		
		
				number <= 6;
				
				
				cursorRefresh <= '0';
				if(cursorTimer = 1) then
					if   (Lt = '1' and Rt = '0' and Button = '0') then next_cursorState <= column5; cursorRefresh <= '1';
					elsif(Lt = '0' and Rt = '1' and Button = '0') then next_cursorState <= column6; cursorRefresh <= '1';
					else                 							   next_cursorState <= column6; 
					end if;
				else                     							   next_cursorState <= column6;
				end if;
		
		
				
		end case;
	end process;
	
	
	--Delay to prevent glitch when switching from state to state
	process(clk50)
	begin
	if(rising_edge(clk50)) then cursorTrigger <= cursorRefresh;
	end if;	
	end process;
	


--------------------------------------------------------------------------------------------
--Timer for Draw FSM------------------------------------------------------------------------
--------------------------------------------------------------------------------------------	
	process(clk50)	
	variable drawRefreshTime   : integer range 0 to 50_000_000 := 0;
	begin
	if(drawTrigger = '1') then 
									drawTimer        <= 0;
									drawRefreshTime  := 0;
	elsif(rising_edge(clk50)) then 
				
				if(drawRefreshTime = 20_000_000) then drawRefreshTime := drawRefreshTime;
													  drawTimer <= 1;
				else 								  drawRefreshTime := drawRefreshTime + 1;
				end if;
	end if;
	end process;
------------------------------------------------------------------------------------------------
----Draw FSM----------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
	 
	process(clk50)
	begin
	if(rising_edge(clk50)) then 
		if(reset = '1') then prev_drawState <= Idle;
		else                 prev_drawState <= next_drawState;
		end if;
	end if;
	end process;
	
	process(prev_drawState)
	begin
	
		drawRefresh <= '0';
		
		case (prev_drawState) is 
			when Idle => 
			
						if(drawTimer = 1 and allow = '1') then
							if(Lt = '0' and Rt = '0' and Button = '1') then next_drawState <= Check; drawRefresh <= '1';
							else                 						    next_drawState <= Idle;
							end if;
						else                      						    next_drawState <= Idle;
						end if;
			
			when Check => 
					
						if   ((index(number) < 6) and (player = '0')) then next_drawState <= drawP1; drawRefresh <= '1';
						elsif((index(number) < 6) and (player = '1')) then next_drawState <= drawP2; drawRefresh <= '1';
						else                                               next_drawState <= Idle;   drawRefresh <= '1';
						end if;
						
			when drawP1 =>
					
						
						next_drawState  <= Idle;
						
			when drawP2 => 
						
						
						next_drawState  <= Idle;
						
		end case;	
	end process;
	
	--Glitch prevention for state tranfer--	
	process(clk50)
	begin
	if(rising_edge(clk50)) then drawTrigger <= drawRefresh;
	end if;	
	end process;
	---------------------------------------

	process(clk50)
	variable drawFlag         : std_logic := '0';
	begin
	
	if(reset = '1') then 
							drawCounter <= 0;
							fieldMap <= (others => (others => U));
							index <= (others => 0);
							
	elsif(rising_edge(clk50)) then
		
		case (prev_drawState) is
					when Idle 	   => drawFlag := '0';
					when Check 	   => null;
					when drawP1 => 
										if(drawFlag = '0') then
										drawCounter <= drawCounter + 1;
										fieldMap(number, index(number)) <= O1; 
										player <= not player; 
										index(number) <= index(number) + 1;
										drawFlag := '1'; 
										end if;
					when drawP2     => 
										if(drawFlag = '0') then
										drawCounter <= drawCounter + 1;
										fieldMap(number, index(number)) <= O2; 
										player <= not player; 
										index(number) <= index(number) + 1;
										drawFlag := '1'; 
										end if;
		end case;
	end if;	
	end process;
-------------------------------------	
--Drawing chips----------------------
-------------------------------------								  
	process(chipClk)
	begin
	if(reset = '1') then chipCounters <= (others => (others => 79));
	else
	for i in 0 to 6 loop
		chipCounter(chipClk, reset, fieldMap(i,0), fieldMap(i,1), fieldMap(i,2), fieldMap(i,3), fieldMap(i,4), fieldMap(i,5), chipCounters(i,0), chipCounters(i,1), chipCounters(i,2), chipCounters(i,3), chipCounters(i,4), chipCounters(i,5));
	end loop;
	end if;
	end process;
		
---------------------------------------------------------------------------------------
--Timer for game-----------------------------------------------------------------------
---------------------------------------------------------------------------------------

	process(clk50)	
	variable gameCounter	 : integer range 0 to 50_000_000 := 0;
	begin
 
	if(startGame = '1') then 
		if(rising_edge(clk50)) then gameCounter := gameCounter + 1;
			if(gameCounter = 50_000_000) then gameCounter   := 0;
										      gameTime <= gameTime + 1;
			end if;
		end if;
	else
		gameTime     <= 0;
		gameCounter  := 0;
	end if;
	end process;

-----------------------------------------------------
--Connect 4 Game-------------------------------------
-----------------------------------------------------		
	process(clk50)
	begin
	
	if(reset = '1') then prev_gameState <= Start;
	elsif(rising_edge(clk50)) then prev_gameState <= next_gameState;
	end if;
	end process;

	process (prev_gameState)
	variable x     : natural range 0 to 800;
	variable y     : natural range 0 to 525;
	variable yChip : natural range 0 to 480 := 78;
	begin
	
	
	x := xPix;
	y := yPix;
	yChip := 78;
	
		case(prev_gameState) is
		when Start =>  
			
					allow <= '0';
					if (dena = '1') then
						r <= (others => '1');
						g <= (others => '1');
						b <= (others => '0');
					else
						r <= (others => '0');
						g <= (others => '0');
						b <= (others => '0');
					end if;
					if(reset = '1') then startGame <= '0';
					else                 startGame <= '1';
					end if;
					if (gameTime = 3) then next_gameState    <= Play;
					else                   next_gameState    <= Start;
					end if;
				
		when Play  =>
		
					
					startGame <= '0';
					allow <= '1';	
					--Counter:------------------------------
					if (dena = '1') then
						
					
					
				
--					r <= (others => '1');
--					g <= (others => '1');
--					b <= (others => '0');
					--
					
					drawBox(x, y, 0, 640, 0, 480, color(6), r, g, b);
					
				
						
					
					
					drawP1orP2(x, y, fieldMap(0, 5), fieldMap(0, 4), fieldMap(0, 3), fieldMap(0, 2), fieldMap(0, 1), fieldMap(0, 0), xCoord(0), chipCounters(0,0), chipCounters(0,1), chipCounters(0,2), chipCounters(0,3), chipCounters(0,4), chipCounters(0,5), r, g, b);
					drawP1orP2(x, y, fieldMap(1, 5), fieldMap(1, 4), fieldMap(1, 3), fieldMap(1, 2), fieldMap(1, 1), fieldMap(1, 0), xCoord(1), chipCounters(1,0), chipCounters(1,1), chipCounters(1,2), chipCounters(1,3), chipCounters(1,4), chipCounters(1,5), r, g, b);
					drawP1orP2(x, y, fieldMap(2, 5), fieldMap(2, 4), fieldMap(2, 3), fieldMap(2, 2), fieldMap(2, 1), fieldMap(2, 0), xCoord(2), chipCounters(2,0), chipCounters(2,1), chipCounters(2,2), chipCounters(2,3), chipCounters(2,4), chipCounters(2,5), r, g, b);
					drawP1orP2(x, y, fieldMap(3, 5), fieldMap(3, 4), fieldMap(3, 3), fieldMap(3, 2), fieldMap(3, 1), fieldMap(3, 0), xCoord(3), chipCounters(3,0), chipCounters(3,1), chipCounters(3,2), chipCounters(3,3), chipCounters(3,4), chipCounters(3,5), r, g, b);
					drawP1orP2(x, y, fieldMap(4, 5), fieldMap(4, 4), fieldMap(4, 3), fieldMap(4, 2), fieldMap(4, 1), fieldMap(4, 0), xCoord(4), chipCounters(4,0), chipCounters(4,1), chipCounters(4,2), chipCounters(4,3), chipCounters(4,4), chipCounters(4,5), r, g, b);
					drawP1orP2(x, y, fieldMap(5, 5), fieldMap(5, 4), fieldMap(5, 3), fieldMap(5, 2), fieldMap(5, 1), fieldMap(5, 0), xCoord(5), chipCounters(5,0), chipCounters(5,1), chipCounters(5,2), chipCounters(5,3), chipCounters(5,4), chipCounters(5,5), r, g, b);
					drawP1orP2(x, y, fieldMap(6, 5), fieldMap(6, 4), fieldMap(6, 3), fieldMap(6, 2), fieldMap(6, 1), fieldMap(6, 0), xCoord(6), chipCounters(6,0), chipCounters(6,1), chipCounters(6,2), chipCounters(6,3), chipCounters(6,4), chipCounters(6,5), r, g, b);				
					
				
					drawBoard(x, y, color(0), r, g, b);
					
					if(player = '0') then drawDisc(x, y, xChip(number), yChip, 200, color(4), r, g, b);
					else                  drawDisc(x, y, xChip(number), yChip, 200, color(1), r, g, b);
					end if;	
					
					else
					
						r <= (others => '0');
						g <= (others => '0');
						b <= (others => '0');
						--drawBox(x, y, 0, 640, 0, 480, color(0), r, g, b);
					end if;
					
					
					
					next_gameState <= Play;
					
					
					if   (p1(0) = '1' or p1(1) = '1' or p1(2) = '1' or p1(3) = '1') then next_gameState <= Menu0;
					elsif(p2(0) = '1' or p2(1) = '1' or p2(2) = '1' or p2(3) = '1') then next_gameState <= Menu1;
					elsif(drawCounter = 42) 									    then next_gameState <= Menu2;
					else                 		 									     next_gameState <= Play;
					end if;
			
						
		when Menu0 => 
				
			
					startGame <= '0';
					allow <= '0';
					if (dena = '1') then
						r <= (others => '1');
						g <= (others => '0');
						b <= (others => '1');
					drawP1orP2(x, y, fieldMap(0, 5), fieldMap(0, 4), fieldMap(0, 3), fieldMap(0, 2), fieldMap(0, 1), fieldMap(0, 0), xCoord(0), chipCounters(0,0), chipCounters(0,1), chipCounters(0,2), chipCounters(0,3), chipCounters(0,4), chipCounters(0,5), r, g, b);
					drawP1orP2(x, y, fieldMap(1, 5), fieldMap(1, 4), fieldMap(1, 3), fieldMap(1, 2), fieldMap(1, 1), fieldMap(1, 0), xCoord(1), chipCounters(1,0), chipCounters(1,1), chipCounters(1,2), chipCounters(1,3), chipCounters(1,4), chipCounters(1,5), r, g, b);
					drawP1orP2(x, y, fieldMap(2, 5), fieldMap(2, 4), fieldMap(2, 3), fieldMap(2, 2), fieldMap(2, 1), fieldMap(2, 0), xCoord(2), chipCounters(2,0), chipCounters(2,1), chipCounters(2,2), chipCounters(2,3), chipCounters(2,4), chipCounters(2,5), r, g, b);
					drawP1orP2(x, y, fieldMap(3, 5), fieldMap(3, 4), fieldMap(3, 3), fieldMap(3, 2), fieldMap(3, 1), fieldMap(3, 0), xCoord(3), chipCounters(3,0), chipCounters(3,1), chipCounters(3,2), chipCounters(3,3), chipCounters(3,4), chipCounters(3,5), r, g, b);
					drawP1orP2(x, y, fieldMap(4, 5), fieldMap(4, 4), fieldMap(4, 3), fieldMap(4, 2), fieldMap(4, 1), fieldMap(4, 0), xCoord(4), chipCounters(4,0), chipCounters(4,1), chipCounters(4,2), chipCounters(4,3), chipCounters(4,4), chipCounters(4,5), r, g, b);
					drawP1orP2(x, y, fieldMap(5, 5), fieldMap(5, 4), fieldMap(5, 3), fieldMap(5, 2), fieldMap(5, 1), fieldMap(5, 0), xCoord(5), chipCounters(5,0), chipCounters(5,1), chipCounters(5,2), chipCounters(5,3), chipCounters(5,4), chipCounters(5,5), r, g, b);
					drawP1orP2(x, y, fieldMap(6, 5), fieldMap(6, 4), fieldMap(6, 3), fieldMap(6, 2), fieldMap(6, 1), fieldMap(6, 0), xCoord(6), chipCounters(6,0), chipCounters(6,1), chipCounters(6,2), chipCounters(6,3), chipCounters(6,4), chipCounters(6,5), r, g, b);				
					
					drawBoard(x, y, color(0), r, g, b);
						
					else
						r <= (others => '0');
						g <= (others => '0');
						b <= (others => '0');
					end if;
					
					next_gameState <= Menu0;
					
		when Menu1 => 
				 
					allow <= '0';
					startGame <= '0';
		
					if (dena = '1') then
						r <= (others => '0');
						g <= (others => '1');
						b <= (others => '0');
						
					drawP1orP2(x, y, fieldMap(0, 5), fieldMap(0, 4), fieldMap(0, 3), fieldMap(0, 2), fieldMap(0, 1), fieldMap(0, 0), xCoord(0), chipCounters(0,0), chipCounters(0,1), chipCounters(0,2), chipCounters(0,3), chipCounters(0,4), chipCounters(0,5), r, g, b);
					drawP1orP2(x, y, fieldMap(1, 5), fieldMap(1, 4), fieldMap(1, 3), fieldMap(1, 2), fieldMap(1, 1), fieldMap(1, 0), xCoord(1), chipCounters(1,0), chipCounters(1,1), chipCounters(1,2), chipCounters(1,3), chipCounters(1,4), chipCounters(1,5), r, g, b);
					drawP1orP2(x, y, fieldMap(2, 5), fieldMap(2, 4), fieldMap(2, 3), fieldMap(2, 2), fieldMap(2, 1), fieldMap(2, 0), xCoord(2), chipCounters(2,0), chipCounters(2,1), chipCounters(2,2), chipCounters(2,3), chipCounters(2,4), chipCounters(2,5), r, g, b);
					drawP1orP2(x, y, fieldMap(3, 5), fieldMap(3, 4), fieldMap(3, 3), fieldMap(3, 2), fieldMap(3, 1), fieldMap(3, 0), xCoord(3), chipCounters(3,0), chipCounters(3,1), chipCounters(3,2), chipCounters(3,3), chipCounters(3,4), chipCounters(3,5), r, g, b);
					drawP1orP2(x, y, fieldMap(4, 5), fieldMap(4, 4), fieldMap(4, 3), fieldMap(4, 2), fieldMap(4, 1), fieldMap(4, 0), xCoord(4), chipCounters(4,0), chipCounters(4,1), chipCounters(4,2), chipCounters(4,3), chipCounters(4,4), chipCounters(4,5), r, g, b);
					drawP1orP2(x, y, fieldMap(5, 5), fieldMap(5, 4), fieldMap(5, 3), fieldMap(5, 2), fieldMap(5, 1), fieldMap(5, 0), xCoord(5), chipCounters(5,0), chipCounters(5,1), chipCounters(5,2), chipCounters(5,3), chipCounters(5,4), chipCounters(5,5), r, g, b);
					drawP1orP2(x, y, fieldMap(6, 5), fieldMap(6, 4), fieldMap(6, 3), fieldMap(6, 2), fieldMap(6, 1), fieldMap(6, 0), xCoord(6), chipCounters(6,0), chipCounters(6,1), chipCounters(6,2), chipCounters(6,3), chipCounters(6,4), chipCounters(6,5), r, g, b);				
					
					drawBoard(x, y, color(0), r, g, b);
					else
						r <= (others => '0');
						g <= (others => '0');
						b <= (others => '0');
					end if;
					
					next_gameState <= Menu1;
			
		when Menu2 => 
		 
					allow <= '0';
					startGame <= '0';
		
					if (dena = '1') then
						r <= (others => '1');
						g <= (others => '1');
						b <= (others => '1');
--						
					drawP1orP2(x, y, fieldMap(0, 5), fieldMap(0, 4), fieldMap(0, 3), fieldMap(0, 2), fieldMap(0, 1), fieldMap(0, 0), xCoord(0), chipCounters(0,0), chipCounters(0,1), chipCounters(0,2), chipCounters(0,3), chipCounters(0,4), chipCounters(0,5), r, g, b);
					drawP1orP2(x, y, fieldMap(1, 5), fieldMap(1, 4), fieldMap(1, 3), fieldMap(1, 2), fieldMap(1, 1), fieldMap(1, 0), xCoord(1), chipCounters(1,0), chipCounters(1,1), chipCounters(1,2), chipCounters(1,3), chipCounters(1,4), chipCounters(1,5), r, g, b);
					drawP1orP2(x, y, fieldMap(2, 5), fieldMap(2, 4), fieldMap(2, 3), fieldMap(2, 2), fieldMap(2, 1), fieldMap(2, 0), xCoord(2), chipCounters(2,0), chipCounters(2,1), chipCounters(2,2), chipCounters(2,3), chipCounters(2,4), chipCounters(2,5), r, g, b);
					drawP1orP2(x, y, fieldMap(3, 5), fieldMap(3, 4), fieldMap(3, 3), fieldMap(3, 2), fieldMap(3, 1), fieldMap(3, 0), xCoord(3), chipCounters(3,0), chipCounters(3,1), chipCounters(3,2), chipCounters(3,3), chipCounters(3,4), chipCounters(3,5), r, g, b);
					drawP1orP2(x, y, fieldMap(4, 5), fieldMap(4, 4), fieldMap(4, 3), fieldMap(4, 2), fieldMap(4, 1), fieldMap(4, 0), xCoord(4), chipCounters(4,0), chipCounters(4,1), chipCounters(4,2), chipCounters(4,3), chipCounters(4,4), chipCounters(4,5), r, g, b);
					drawP1orP2(x, y, fieldMap(5, 5), fieldMap(5, 4), fieldMap(5, 3), fieldMap(5, 2), fieldMap(5, 1), fieldMap(5, 0), xCoord(5), chipCounters(5,0), chipCounters(5,1), chipCounters(5,2), chipCounters(5,3), chipCounters(5,4), chipCounters(5,5), r, g, b);
					drawP1orP2(x, y, fieldMap(6, 5), fieldMap(6, 4), fieldMap(6, 3), fieldMap(6, 2), fieldMap(6, 1), fieldMap(6, 0), xCoord(6), chipCounters(6,0), chipCounters(6,1), chipCounters(6,2), chipCounters(6,3), chipCounters(6,4), chipCounters(6,5), r, g, b);				
					
					drawBoard(x, y, color(0), r, g, b);
						
					else
						r <= (others => '0');
						g <= (others => '0');
						b <= (others => '0');
					end if;
					
					next_gameState <= Menu2;
					
			
						
		end case;
	 
	end process;

	process(clk50)
	variable win : std_logic_vector (7 downto 0)  := (others => '0');
	variable winFlag : std_logic := '0';
	begin
	
		if(rising_edge(clk50)) then
						if(prev_gameState = Start) then p1  <= (others => '0');
													    p2  <= (others => '0');
													    win := (others => '0');
													    replay <= '0';
													    toMenu <= '0';
						elsif(prev_gameState = Play) then

							
							if(player = '1') then
							
--							fieldMap(0 to 6, 0 to 5)
							
								for i in 0 to 6 loop
									for j in 0 to 2 loop
										if   ((fieldMap(i, j) = fieldMap(i, j+1)) and (fieldMap(i, j+1) = fieldMap(i, j+2)) and (fieldMap(i, j+2) = fieldMap(i, j+3)) and (fieldMap(i, j) = O1)) then win(0) := '1'; 
										end if;
									end loop;
								end loop;
								
								for j in 0 to 5 loop
									for i in 0 to 3 loop
										if   ((fieldMap(i, j) = fieldMap(i+1, j)) and (fieldMap(i+1, j) = fieldMap(i+2, j)) and (fieldMap(i+2, j) = fieldMap(i+3, j)) and (fieldMap(i, j) = O1)) then win(1) := '1'; 
										end if;
									end loop;
								end loop;
								
								for i in 0 to 3 loop
									for j in 0 to 2 loop
										if   ((fieldMap(i, j) = fieldMap(i+1, j+1)) and (fieldMap(i+1, j+1) = fieldMap(i+2, j+2)) and (fieldMap(i+2, j+2) = fieldMap(i+3, j+3)) and (fieldMap(i, j) = O1)) then win(2) := '1'; 
										end if;
									end loop;
								end loop;
								
								for i in 6 downto 3 loop
									for j in 0 to 2 loop
										if   ((fieldMap(i, j) = fieldMap(i-1, j+1)) and (fieldMap(i-1, j+1) = fieldMap(i-2, j+2)) and (fieldMap(i-2, j+2) = fieldMap(i-3, j+3)) and (fieldMap(i, j) = O1)) then win(3) := '1'; 
										end if;
									end loop;
								end loop;
								p1 <= win(3 downto 0);
							
							elsif(player = '0') then
								
								for i in 0 to 6 loop
									for j in 0 to 2 loop
										if   ((fieldMap(i, j) = fieldMap(i, j+1)) and (fieldMap(i, j+1) = fieldMap(i, j+2)) and (fieldMap(i, j+2) = fieldMap(i, j+3)) and (fieldMap(i, j) = O2)) then win(4) := '1'; 
										end if;
									end loop;
								end loop;
								
								for j in 0 to 5 loop
									for i in 0 to 3 loop
										if   ((fieldMap(i, j) = fieldMap(i+1, j)) and (fieldMap(i+1, j) = fieldMap(i+2, j)) and (fieldMap(i+2, j) = fieldMap(i+3, j)) and (fieldMap(i, j) = O2) ) then win(5) := '1'; 
										end if;
									end loop;
								end loop;
								
								for i in 0 to 3 loop
									for j in 0 to 2 loop
										if   ((fieldMap(i, j) = fieldMap(i+1, j+1)) and (fieldMap(i+1, j+1) = fieldMap(i+2, j+2)) and (fieldMap(i+2, j+2) = fieldMap(i+3, j+3)) and (fieldMap(i, j) = O2)) then win(6) := '1'; 
										end if;
									end loop;
								end loop;
								
								for i in 6 downto 3 loop
									for j in 0 to 2 loop
										if   ((fieldMap(i, j) = fieldMap(i-1, j+1)) and (fieldMap(i-1, j+1) = fieldMap(i-2, j+2)) and (fieldMap(i-2, j+2) = fieldMap(i-3, j+3)) and (fieldMap(i, j) = O2)) then win(7) := '1'; 
										end if;
									end loop;
								end loop;
								
								p2 <= win(7 downto 4);
								
							end if;
						elsif(prev_gameState = Menu0 or prev_gameState = Menu1 or prev_gameState = Menu2) then
								if   (inReplay = '1' and inToMenu = '0') then replay <= '1';
								elsif(inReplay = '0' and inToMenu = '1') then toMenu <= '1';
								elsif(inReplay = '0' and inToMenu = '0') then replay <= '0'; toMenu <= '0';
								end if;
						end if;
	end if;
					
	end process;
		
end FSM;	