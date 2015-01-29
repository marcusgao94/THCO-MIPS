library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 
library work;
use work.common.all;


entity forwardEMux4 is
  port (
    ori, alu, mem: in STD_LOGIC_VECTOR(15 downto 0);
    s: in STD_LOGIC_VECTOR(1 downto 0);
    y: out STD_LOGIC_VECTOR(15 downto 0)
  );
end;

architecture behave of forwardEMux4 is
  begin
      y <= ori when s=FORWARDE_REGF
      else alu when s=FORWARDE_ALU
      else mem when s=FORWARDE_WB;
  end;

