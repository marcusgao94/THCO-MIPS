library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.common.all;

entity freDivider is
  port(
    clkin:in STD_LOGIC;
    clkout:out STD_LOGIC
  );
end freDivider;

architecture behavioral of freDivider is
  signal data:integer range 0 to EXCITED;
  signal q:STD_LOGIC:='0';
  signal b:integer;
begin 
  process(clkin)
  begin
    if rising_edge(clkin) then
      if (data = EXCITED) then
        data<=0;
        q<=not q;
      else
        data<=data+1;
      end if;
    end if;
    clkout<=q;
  end process;  
	
--	clkout<=clkin;
	
end behavioral;
