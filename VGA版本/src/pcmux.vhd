library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 
library work;
use work.common.all;

--two-input multiplexer
entity pcmux is
	port(
		pc_to_ram2, pc_plus_oneF: in STD_LOGIC_VECTOR(15 downto 0);
    pc_stay: in STD_LOGIC;
    y: out STD_LOGIC_VECTOR(15 downto 0)
   );
end;

architecture behave of pcmux is
	begin
		y <= pc_to_ram2 when pc_stay = '1' else pc_plus_oneF;
end behave;




