library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 
library work;
use work.common.all;

--two-input multiplexer
entity forwardDMux2 is
  port (
    reg, alu: in STD_LOGIC_VECTOR(15 downto 0);
    s: in STD_LOGIC;
    y: out STD_LOGIC_VECTOR(15 downto 0)
  );
end;

architecture behave of forwardDMux2 is
  begin
    y<=reg when s = FORWARDD_REGF else alu;
  end behave;



