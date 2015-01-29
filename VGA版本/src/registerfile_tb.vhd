library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.common.all;

entity registerfile_tb is
  port(
     outA:out STD_logic_vector(15 downto 0);
     outB :out std_logic_vector(15 downto 0)
  );
end registerfile_tb;

architecture one of registerfile_tb is
  component registerfile is
    port(
      clk : in STD_LOGIC;
      rst : in STD_LOGIC;
      
      REGF_SrcA: in STD_LOGIC_VECTOR(3 downto 0);
      REGF_SrcB: in STD_LOGIC_VECTOR(3 downto 0);
      REGF_InAddr : in STD_LOGIC_VECTOR(3 downto 0);
      REGF_WE : in STD_LOGIC;
      REGF_InData : in STD_LOGIC_VECTOR(15 downto 0);
      
      REGF_OutA: out STD_LOGIC_VECTOR(15 downto 0);
      REGF_OutB: out STD_LOGIC_VECTOR(15 downto 0)
      
  );
 end component;
 signal clk :std_logic:='0';
 signal rst: std_logic;
 constant clk_period:time:=20 ns;
 signal inA, inB, inW: std_logic_vector(3 downto 0);
 signal indata:std_logic_vector(15 downto 0);
 signal we:std_logic;
 
begin
 u1:
 registerfile port map
 (clk=>clk,rst=>rst,REGF_SrcA=>inA, REGF_SrcB=>inB, REGF_InAddr=>inW, REGF_WE=>we, REGF_InData=>indata
 , REGF_OutA=>outA , REGF_OutB=>outB);
process
begin
  inA <= "0110";
  inB <= "0001";
  inW <= "0010";
  indata <= "0001001000110100";
  wait for clk_period*4;
  inA <= "0110";
  inB <= "0010";
  inW <= "0110";
  indata <= "0100001100100001";
  wait;
end process;
process
begin
  we <= '1';
  wait for clk_period*6;
  we <= '0';
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

