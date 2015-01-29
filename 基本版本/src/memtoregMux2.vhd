library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 
library work;
use work.common.all;

--two-input multiplexer
entity memtoregMux2 is
  port (
    alu, mem: in STD_LOGIC_VECTOR(15 downto 0);
    memtoreg: in STD_LOGIC;
    y: out STD_LOGIC_VECTOR(15 downto 0)
  );
end;

architecture behave of memtoregMux2 is
  begin
    y<=alu when memtoreg = MEMTOREG_ALU else mem;
  end behave;

