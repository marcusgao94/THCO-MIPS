library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pc_tb is
  port(
     pc_plus_one:out STD_logic_vector(15 downto 0);
     pc_out :out std_logic_vector(15 downto 0)
  );
end pc_tb;

architecture one of pc_tb is
  component pc is
    port(clk :in std_logic;
         rst :in std_logic;
         pc_in : in STD_LOGIC_VECTOR(15 downto 0);
         stay : in STD_LOGIC;
      
         pc_plus_one: out STD_LOGIC_VECTOR(15 downto 0);
         pc_out : out STD_LOGIC_VECTOR(15 downto 0)
         );
 end component;
 signal clk :std_logic:='0';
 signal div :std_logic:='0';
 signal pc_in : std_logic_vector(15 downto 0):="0000000000000000";
 signal stay : std_logic;
 signal rst: std_logic;
 signal pccc: std_logic_vector(15 downto 0):="0000000000000000";
 constant clk_period:time:=20 ns;
begin
 u1:
 pc port map
 (clk=>clk,rst=>rst,pc_in=>pc_in,stay=>stay,pc_plus_one=>pccc,pc_out=>pc_out);
 pc_in <= pccc;
 process
   begin
 stay <= '0';
 wait for clk_period*20;
 stay <='1';
 wait;
 end process;
 process
   begin
    rst <= '1';
    wait for clk_period;
    rst <='0';
    wait for clk_period;
    rst <= '1';
    wait;
 end process;
 process
   begin 
     
      wait for clk_period/2;
        clk<='1';
     wait for clk_period/2;
        clk<='0';
 end process;
end;
