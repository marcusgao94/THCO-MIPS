library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity freDivider_vga is
  port(
    clkin:in STD_LOGIC;
    clkout:out STD_LOGIC
  );
end freDivider_vga;

architecture behavioral of freDivider_vga is
  signal q:STD_LOGIC:='0';
begin 
  process(clkin)
  begin
    if rising_edge(clkin) then
        q<=not q;
    end if;
    clkout<=q;
  end process;  
end behavioral;
