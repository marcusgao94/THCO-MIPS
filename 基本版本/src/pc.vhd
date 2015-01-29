
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.common.ALL;

entity pc is
  port(
      clk : in STD_LOGIC;
      rst : in STD_LOGIC;
      
      pc_in : in STD_LOGIC_VECTOR(15 downto 0);
      stay : in STD_LOGIC;
      jump: in STD_LOGIC;
      jump_addr: in STD_LOGIC_VECTOR(15 downto 0);
      
      pc_plus_one: out STD_LOGIC_VECTOR(15 downto 0);
      pc_out : out STD_LOGIC_VECTOR(15 downto 0)
  );
end pc;

architecture behavioral of pc is
  signal pc_register : STD_LOGIC_VECTOR(15 downto 0);
begin
  pc_plus_one <= pc_register + 1;
  pc_out <= pc_register;
  process(clk, rst)
  begin
    if rst='0' then
      pc_register <= ZERO;
    elsif clk'event and clk='1' then
      if jump='1' then
        pc_register<=jump_addr;
      else
        pc_register <= pc_in;
      end if;
    end if;    
  end process;
      
end behavioral;
