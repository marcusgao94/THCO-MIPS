library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.common.ALL;

entity JumpAddrMux is
  port(
    ALUresult: in STD_LOGIC_VECTOR(15 downto 0);
    JumpType: in STD_LOGIC_VECTOR(2 downto 0);
    ALU_B: in STD_LOGIC_VECTOR(15 downto 0);
    
    OutAddr: out STD_LOGIC_VECTOR(15 downto 0)    
  );
end JumpAddrMux;
architecture behavioral of JumpAddrMux is
begin
  with JumpType select
    OutAddr <= ALU_B when JUMPTYPE_JALR,
               ALUresult when others;
end behavioral;
