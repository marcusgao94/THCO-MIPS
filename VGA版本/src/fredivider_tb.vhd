library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fredivider_tb is
  port(
     clk_out :out std_logic
  );
end fredivider_tb;

architecture one of fredivider_tb is
  component fredivider is
    port(clkin :in std_logic;
         clkout :out std_logic
         );
 end component;
 signal clk :std_logic:='0';
 constant clk_period:time:=20 ns;
begin
 u1:
 fredivider port map
 (clkin=>clk,clkout=>clk_out);
 process
   begin      
      wait for clk_period/2;
        clk<='1';
     wait for clk_period/2;
        clk<='0';
 end process;
end;


