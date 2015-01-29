library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 
library work;
use work.common.all;

--two-input multiplexer
entity alubsrcMux2 is
  port (
    reg, imm: in STD_LOGIC_VECTOR(15 downto 0);
    alu_b_src: in STD_LOGIC;
    y: out STD_LOGIC_VECTOR(15 downto 0)
  );
end;

architecture behave of alubsrcMux2 is
  begin
    y<=imm when alu_b_src = ALU_B_SRC_IMM else reg;
  end behave;


