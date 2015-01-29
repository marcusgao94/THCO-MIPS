library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.common.ALL;

entity EXE_MEM_Register is
  port(
    clk,rst: in STD_LOGIC;
    
    --for mem
    In_RAM1_Control: in STD_LOGIC_VECTOR(1 downto 0);
    In_RAM1_Addr: in STD_LOGIC_VECTOR(15 downto 0);
    In_RAM1_InData: in STD_LOGIC_VECTOR(15 downto 0);    
    
    --for wb
    In_MemtoReg : in STD_LOGIC;
    In_ALUResult: in STD_LOGIC_VECTOR(15 downto 0);
    In_RegWrite: in STD_LOGIC;
    In_RegWriteAddr: in STD_LOGIC_VECTOR(3 downto 0);
    --out for mem
    Out_RAM1_Control: out STD_LOGIC_VECTOR(1 downto 0);
    Out_RAM1_Addr: out STD_LOGIC_VECTOR(15 downto 0);
    Out_RAM1_InData: out STD_LOGIC_VECTOR(15 downto 0);  
    
    --out for wb
    Out_MemtoReg : out STD_LOGIC;
    Out_ALUResult: out STD_LOGIC_VECTOR(15 downto 0);
    Out_RegWrite: out STD_LOGIC;
    Out_RegWriteAddr: out STD_LOGIC_VECTOR(3 downto 0) 
  );
end EXE_MEM_Register;

architecture behavioral of EXE_MEM_Register is
begin
  process(clk, rst)
  begin
    if rst='0' then
	   Out_RAM1_Control <= MEMCONTROL_DISABLE;
		Out_RegWrite<=REGWRITE_NO;
		Out_RegWriteAddr<=REGF_NULL;
		Out_MemtoReg <= MEMTOREG_ALU;
    elsif rst='1' then
      if rising_edge(clk) then
        --mem phase
        Out_RAM1_Control <= In_RAM1_Control;
        Out_RAM1_Addr <= In_RAM1_Addr;
        Out_RAM1_InData <= In_RAM1_InData;
        --wb phase
		  Out_MemtoReg <= In_MemtoReg;
        Out_ALUResult<= In_ALUResult;
        Out_RegWrite<=In_RegWrite;
        Out_RegWriteAddr<=In_RegWriteAddr;
      end if;
    end if;
  
  end process;
end behavioral;
