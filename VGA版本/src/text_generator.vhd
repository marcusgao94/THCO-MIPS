LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.common.all;

ENTITY text_generator IS
  PORT(
    clkr      :  IN   STD_LOGIC;
	 clkw      :  IN   STD_LOGIC;
	 rst      :  IN   STD_LOGIC;
    disp_ena :  IN   STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
    row      :  IN   INTEGER;    --row pixel coordinate
    column   :  IN   INTEGER;    --column pixel coordinate
	 write_ena:  IN   STD_LOGIC;
	 write_char: IN STD_LOGIC_VECTOR(15 downto 0);
    red      :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
    green    :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
    blue     :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0')); --blue magnitude output to DAC
END text_generator;

ARCHITECTURE behavior OF text_generator IS
  
  component font_rom 
   port(
      clock: in std_logic;
      addr: in std_logic_vector(10 downto 0);
      data: out std_logic_vector(0 to 7)
   );
  end component;
  
  COMPONENT video_ram IS
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    clkb : IN STD_LOGIC;
    rstb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
  );
  END component;
  
  
  -- For Text Generator 
  SIGNAL font_bit : STD_LOGIC;
  SIGNAL char_ascii : STD_LOGIC_VECTOR(6 downto 0);
  signal rom_addr: std_logic_vector(10 downto 0);
  signal read_addr: std_logic_vector(11 downto 0);
  signal dout : std_logic_vector(6 downto 0);
  signal row_addr: std_logic_vector(3 downto 0);
  signal bit_addr: std_logic_vector(2 downto 0);
  signal font_word: std_logic_vector(0 to 7);
  signal pixel_x, pixel_y: std_logic_vector(9 downto 0);
  signal addr_x, addr_y : std_logic_vector(9 downto 0);
  signal tmp : std_logic_vector(3 downto 0);
  
  -- For Cursor And Write
  
  SIGNAL nowR,nxtR : STD_LOGIC_VECTOR(4 downto 0);
  SIGNAL nowC,nxtC : STD_LOGIC_VECTOR(6 downto 0);
  SIGNAL nowAddr, nxtAddr : STD_LOGIC_VECTOR(11 downto 0);
  SIGNAL countCursor, nxtCountCursor : INTEGER range 0 to 25000000;
  SIGNAL flagCursor, nxtFlagCursor : STD_LOGIC;
  SIGNAL flagCursorWrite, nxtFlagCursorWrite : STD_LOGIC;
  SIGNAL flagCharWrite, nxtFlagCharWrite : STD_LOGIC;
  
  SIGNAL writeR : STD_LOGIC_VECTOR(4 downto 0);
  SIGNAL writeC : STD_LOGIC_VECTOR(6 downto 0);
  SIGNAL writeChar : STD_LOGIC_VECTOR(6 downto 0);
  SIGNAL writeAddr : STD_LOGIC_VECTOR(11 downto 0);
  SIGNAL flagWrite : STD_LOGIC_VECTOR(0 downto 0);

  SIGNAL offsetState, nxtOffsetState : STD_LOGIC;
  SIGNAL offset, nxtOffset : STD_LOGIC_VECTOR(4 downto 0);
  
  SIGNAL tReadR, readR : STD_LOGIC_VECTOR(4 downto 0);
  SIGNAL readC : STD_LOGIC_VECTOR(6 downto 0);
  
  SIGNAL cmp1a, cmp1b, cmp2a, cmp2b : STD_LOGIC_VECTOR(5 downto 0);
  SIGNAL tmp1 :STD_LOGIC_VECTOR(5 downto 0);

  --SIGNAL cleanState, nxtCleanState : STD_LOGIC;

  
BEGIN

	 font_unit: font_rom
	 port map(
		 clock => clkr, 
		 addr => rom_addr,
		 data => font_word
	 );
	 
	 uvideo_ram : video_ram
	 port map(
		clka => clkw,
		wea => flagWrite,
		addra => writeAddr, 
		dina => writeChar, 
		clkb => clkr, 
		rstb => not rst, 
		addrb => read_addr, 
		doutb => dout
	 );
	 
	 

	  -- from rom and video_ram to get font bit for multiplexing 
	  
	  process(row, column)
	  begin
	  pixel_x(9 downto 0) <= conv_std_logic_vector(row, 10);
	  pixel_y(9 downto 0) <= conv_std_logic_vector(column, 10);
	  --pixel_x(9 downto 0) <= std_logic_vector(row);
	  --pixel_y(9 downto 0) <= std_logic_vector(column);
	  addr_x <= pixel_x;
	  addr_y <= pixel_y + "0000000010";
	  
	  --cmp1 <= 0 & add_x(8 downto 4);
	  
	  if ("0" & addr_x(8 downto 4)) < ("0" & "01010") then
			tReadR <= addr_x(8 downto 4);
	  else
			tReadR <= ("0" & addr_x(8 downto 4)) + ("0" & offset);
	  end if;
	  if ("0" & tReadR) > ("0" & "11101") then 
	      readR <= (("0" & tReadR) - ("0" & "10100"));
	  else 
			readR <= tReadR;
	  end if;
	  readC <= addr_y(9 downto 3);
	  read_addr <= readR & readC;
	  end process;
	  
	  char_ascii <= dout;
			
	  --char_ascii <= "0110010";
	  row_addr <= pixel_x(3 downto 0);
	  rom_addr <= char_ascii & row_addr;
	  bit_addr <= pixel_y(2 downto 0);
	  font_bit <= font_word(conv_integer(pixel_y(2 downto 0)));
	 
	 
    -- rgb multiplexing
	 process(disp_ena, font_bit)
	 begin
	    if disp_ena = '0' then 
			red <= (OTHERS => '0');
         green <= (OTHERS => '0');
         blue <= (OTHERS => '0');
		 elsif font_bit = '1' then
			red <= (OTHERS => '1');
         green <= (OTHERS => '1');
         blue <= (OTHERS => '1');
		 else
			red <= (OTHERS => '0');
         green <= (OTHERS => '0');
         blue <= (OTHERS => '0');
		 end if;
	 end process;
	 
	 
	 
	 --Cursor & Write
	 process (clkw, rst) 
	 begin 
		if (rst = '0') then 
			nowR <= "01010";
			nowC <= "0000011";
			nowAddr <= nowR & nowC;
			countCursor <= 0;
			flagCursor <= '0';
			flagCursorWrite <= '0';
			flagCharWrite <= '0';
			offset <= "00000";
			offsetState <= '0';
		else
			if (rising_edge(clkw)) then 
				nowR <= nxtR;
				nowC <= nxtC;
				nxtAddr <= nxtAddr;
				countCursor <= nxtCountCursor;
				flagCursor <= nxtFlagCursor;
				flagCursorWrite <= nxtFlagCursorWrite;
				flagCharWrite <= nxtFlagCharWrite;
				offset <= nxtOffset;
				offsetState <= nxtOffsetState;
			end if;
		end if;
	 end process;
	  
	process(countCursor, write_ena) 
	--process(countCursor)
	begin 
		nxtR <= nowR ;
		nxtC <= nowC ;
		nxtAddr <= nxtR & nxtC;
		nxtOffsetState <= offsetState;
		nxtOffset <= offset;
		if (write_ena = '0') then 
			if countCursor = 0 then 
				nxtCountCursor <= 1;
			else
				nxtCountCursor <= 0;
			end if;
			nxtFlagCursor <= '0';
			nxtFlagCursorWrite <= '0';
			nxtFlagCharWrite <= '1';
			
			if offsetState = '0' then 
				writeR <= nowR;
			else
				writeR <= ("0" & offset) + ("0" & "01001");
			end if;
			writeC <= nowC;
			writeAddr <= writeR & writeC;
			writeChar <= write_char(6 downto 0);
			
         if (write_char(6 downto 0) = "0001000") then  -- backspace
				if (nowC = "0000000") then  -- start of line
					nxtC <= "0000000";
				else 
					nxtC <= nowC - "0000001";
				end if;
				writeChar <= "0000000";
			elsif (write_char(6 downto 0) = "0001101") then -- \r
				writeChar <= "0000000";
			elsif (write_char(6 downto 0) = "0001010") then -- \n
				if (nowR = "11101") then  -- end of screen   ATTENTION !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					nxtC <= "0000000";
					if offsetState = '0' then 
						nxtOffsetState <= '1';
						nxtOffset <= "00001";
					else
						if offset = "10100" then
							nxtOffset <= "00000";
						else
							nxtOffset <= ("0" & offset) + ("0" & "00001");
						end if;
					end if;

				else
					nxtC <= "0000000";
					nxtR <= ("0" & nowR) + ("0" & "00001");
				end if;
				writeChar <= "0000000";
			elsif (nowC = "1000000") then 
				nxtC <= "1000000";
			else 
				nxtC <= nowC + "0000001";
			end if;			
			nxtAddr <= nxtR & nxtC;
		elsif (countCursor = CURSORDELAY) then 
			nxtCountCursor <= 0;
			nxtFlagCursor <= not flagCursor;
			nxtFlagCursorWrite <= '1';
			nxtFlagCharWrite <= '0';

			if offsetState = '0' then 
				writeR <= nowR;
			else
				writeR <= ("0" & offset) + ("0" & "01001");
			end if;
			writeC <= nowC;
			writeAddr <= writeR & writeC;
			if (nxtFlagCursor = '0') then 
			    writeChar <= "0000000";
			else
				 writeChar <= "0000001";
			end if;
		else 
			nxtCountCursor <= countCursor + 1;
			nxtFlagCursor <= flagCursor;
			nxtFlagCursorWrite <= '0';
			nxtFlagCharWrite <= '0';
			--flagWrite <= "0";
		end if;
	end process;
	
	flagWrite <= (others => (nxtFlagCursorWrite OR nxtFlagCharWrite));
	--flagWrite <= "1";
	
	 
	 
	 
END behavior;
