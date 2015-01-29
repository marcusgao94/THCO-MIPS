library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.common.ALL;

entity ID_EXE_Register is
  port(
    clk, rst: in STD_LOGIC;
	 flush: in STD_LOGIC;
    --for exe
    In_ALU_A, In_ALU_B, In_Imm: in STD_LOGIC_VECTOR(15 downto 0);
    In_ALU_B_Src: in STD_LOGIC;
    In_ALU_Op: in STD_LOGIC_VECTOR(3 downto 0);
    In_JumpType: in STD_LOGIC_VECTOR(2 downto 0);
    In_Jump: in STD_LOGIC;
    In_IS_SW: in STD_LOGIC;
    In_Rs, In_Rt: in STD_LOGIC_VECTOR(3 downto 0);
    
    --for mem
    In_RAM1_Control: in STD_LOGIC_VECTOR(1 downto 0);
    
    --for wb
    In_MemtoReg : in STD_LOGIC;
    In_RegWrite: in STD_LOGIC;
    In_RegWriteAddr: in STD_LOGIC_VECTOR(3 downto 0);
    --out for exe
    Out_ALU_A, Out_ALU_B, Out_Imm: out STD_LOGIC_VECTOR(15 downto 0);
    Out_ALU_B_Src: out STD_LOGIC;
    Out_ALU_Op: out STD_LOGIC_VECTOR(3 downto 0);
    Out_JumpType: out STD_LOGIC_VECTOR(2 downto 0);
    Out_Jump: out STD_LOGIC;
    OUT_IS_SW: out STD_LOGIC;
    Out_Rs, Out_Rt: out STD_LOGIC_VECTOR(3 downto 0);
    --out for mem
    Out_RAM1_Control: out STD_LOGIC_VECTOR(1 downto 0);
    
    --out for wb
    Out_MemtoReg : out STD_LOGIC;
    Out_RegWrite: out STD_LOGIC;
    Out_RegWriteAddr: out STD_LOGIC_VECTOR(3 downto 0) 
  );
end ID_EXE_Register;

architecture behavioral of ID_EXE_Register is
begin
  process(clk, rst)
  begin
    if rst='0' then
	   Out_JumpType<=JUMPTYPE_NOJUMP;
		Out_MemtoReg <= MEMTOREG_ALU;
      Out_RegWrite<=REGWRITE_NO;
		Out_RegWriteAddr<=REGF_NULL;
    elsif rst='1' then
      if rising_edge(clk) then
		--new add--
		  if flush='0' then
        --exe phase
        Out_ALU_A <= In_ALU_A;
        Out_ALU_B <= In_ALU_B;
        Out_Imm <= In_Imm;
        Out_ALU_B_Src <= In_ALU_B_Src;
        Out_ALU_Op <= In_ALU_Op;
        Out_JumpType <= In_JumpType;
        Out_Jump <= In_Jump;
        Out_IS_SW <= In_IS_SW;
        Out_Rs<=In_Rs;
        Out_Rt<=In_Rt;
        --mem phase
        Out_RAM1_Control <= In_RAM1_Control;
        --wb phase
        Out_MemtoReg <= In_MemtoReg;
        Out_RegWrite<=In_RegWrite;
        Out_RegWriteAddr<=In_RegWriteAddr;
		  else
		  Out_JumpType <= JUMPTYPE_NOJUMP;
        Out_Jump <= '0';
--        Out_IS_SW <= '0';
        Out_IS_SW <= '0';
        Out_Rs <= REGF_NULL;
        Out_Rt <= REGF_NULL; 
        Out_RAM1_Control <= MEMCONTROL_DISABLE;
--        --wb phase
--       Out_MemtoReg <= In_MemtoReg;
        Out_RegWriteAddr<=REGF_NULL; 
        Out_RegWrite<=REGWRITE_NO;
        end if;
      end if;
    end if;
  end process;
end behavioral;