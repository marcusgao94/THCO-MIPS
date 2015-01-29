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
	 flash_addr:in STD_LOGIC_VECTOR(21 downto 0);
	 booting: in std_logic;
    s: in STD_LOGIC_VECTOR(1 downto 0);
	 userlwstall: in std_logic;
    y: out STD_LOGIC_VECTOR(15 downto 0)
  );
end;

architecture behave of pcwriteMux2 is
  begin
  process(booting,s,userlwstall)
  begin
    if (booting='1') then
	   y<=flash_addr(15 downto 0);
	  elsif (((s = MEMCONTROL_WRITE)or(userlwstall='1')) and (booting='0')) then
	   y<=write;
	  else
	   y<=pc;
	 end if;
  end process;
  end behave;




