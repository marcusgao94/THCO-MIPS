library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.common.all;

entity if_id_register_tb is
  port(
     pc_int :out std_logic;
     outpc: out std_logic_vector(15 downto 0);
     outinst: out std_logic_vector(15 downto 0)
  );
end if_id_register_tb;

architecture one of if_id_register_tb is
  component if_id_register is
    port(
    clk : in STD_LOGIC;
    rst : in STD_LOGIC;
    InInst : in STD_LOGIC_VECTOR(15 downto 0);
    InPC : in STD_LOGIC_VECTOR(15 downto 0);
    --check if need to insert nop
    stay : in STD_LOGIC;
    --here handle interrupt
    PC_INT : out STD_LOGIC;
    OutPC : out STD_LOGIC_VECTOR(15 downto 0);
    OutInst : out STD_LOGIC_VECTOR(15 downto 0)
         );
 end component;
 signal clk :std_logic:='0';
 signal rst:std_logic:='1';
 signal ininst:std_logic_vector(15 downto 0):=ZERO;
 signal inpc:std_logic_vector(15 downto 0):=Zero;
 signal stay:std_logic:='0';
 constant clk_period:time:=20 ns;
begin
 u1:
 if_id_register port map
 (clk=>clk,rst=>rst, InInst=>ininst, InPC=>inpc, stay=>stay, PC_INT=>pc_int, outPC=>outpc, outInst=>outinst);
 process
   begin      
      wait for clk_period/2;
        clk<='1';
     wait for clk_period/2;
        clk<='0';
 end process;
 process 
   begin
     InInst <= ZERO;
     wait for clk_period*40;
     InInst <= "1111100000000001";
     wait;
   end process;
process
  begin
    wait for clk_period*5;
    stay<='1';
    wait for clk_period*50;
    stay<='0';
    wait;
  end process;
  process
    begin
      wait for clk_period;
      rst<='0';
      wait for CLk_period;
      rst<='1';
      wait;
      end process;
end;




