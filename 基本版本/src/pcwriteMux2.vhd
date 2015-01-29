library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 
library work;
use work.common.all;

--two-input multiplexer
entity pcwriteMux2 is
  port (
    pc, write: in STD_LOGIC_VECTOR(15 downto 0);
    s: in STD_LOGIC_VECTOR(1 downto 0);
	 userlwstall: in std_logic;
    y: out STD_LOGIC_VECTOR(15 downto 0)
  );
end;

architecture behave of pcwriteMux2 is
  begin
    y<=write when ((s = MEMCONTROL_WRITE)or(userlwstall='1'))
           	 else pc;
  end behave;




