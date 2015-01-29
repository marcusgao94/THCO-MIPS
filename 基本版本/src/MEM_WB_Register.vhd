library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.common.ALL;

entity MEM_WB_Register is
  port(
    clk,rst: in STD_LOGIC;
    
    In_MemtoReg : in STD_LOGIC;
    In_ALUResult: in STD_LOGIC_VECTOR(15 downto 0);
    In_RegWrite: in STD_LOGIC;
    In_MemData: in STD_LOGIC_VECTOR(15 downto 0);
    In_RegWriteAddr: in STD_LOGIC_VECTOR(3 downto 0);

    Out_MemtoReg : out STD_LOGIC;
    Out_ALUResult: out STD_LOGIC_VECTOR(15 downto 0);
    Out_RegWrite: out STD_LOGIC;
    Out_MemData: out STD_LOGIC_VECTOR(15 downto 0);
    Out_RegWriteAddr: out STD_LOGIC_VECTOR(3 downto 0) 
  );

end MEM_WB_Register;


architecture behavioral of MEM_WB_Register is
begin
  process(clk, rst)
  begin
    if rst='0' then
      Out_MemData<=ZERO;
      Out_ALUResult<=ZERO;
      Out_RegWrite<=REGWRITE_NO;
      Out_MemData<=ZERO;
      Out_RegWriteAddr<=REGF_NULL;
    elsif rst='1' then
      if rising_edge(clk) then
        Out_MemData <= In_MemData;
        Out_ALUResult<= In_ALUResult;
        Out_RegWrite<=In_RegWrite;
        Out_MemtoReg<= In_MemtoReg;
        Out_RegWriteAddr<=In_RegWriteAddr;
      end if;
    end if;
  end process;
end behavioral;
