library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.common.all;

entity alu_tb is
  port(
     result:out STD_logic_vector(15 downto 0)
  );
end alu_tb;

architecture one of alu_tb is
  component alu is
    port(
    srcA : in STD_LOGIC_VECTOR(15 downto 0);
    srcB : in STD_LOGIC_VECTOR(15 downto 0);
    op   : in STD_LOGIC_VECTOR(3 downto 0);
    
    result : out STD_LOGIC_VECTOR(15 downto 0)
         );
 end component;
 signal srcA :std_logic_vector(15 downto 0):=ZERO;
 signal srcB :std_logic_vector(15 downto 0):=ZERO;
 signal op : std_logic_vector(3 downto 0):="0000";
 constant clk_period:time:=20 ns;
begin
 u1:
 alu port map
 (srcA=>srcA,srcB=>srcB,op=>op,result=>result);
srcA <="0000000000000001";
srcB <="0000000000000000";

 process
   begin
    op <= ALUOP_ADD;
    wait for clk_period;
    op <= ALUOP_SUB;
    wait for clk_period;
    op<= ALUOP_OR;
    wait for clk_period;
    op<= ALUOP_AND;
    wait for clk_period;
    op<= ALUOP_NOT;
    wait for clk_period;
    op<= ALUOP_SLL;
    wait for clk_period;
    op<= ALUOP_SRA;
    wait for clk_period;
    op<= ALUOP_SUBU;
    wait for clk_period;
    op<= ALUOP_CMP;
    wait;
 end process;

end;


