library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.common.ALL;

entity alu is
  port (
    srcA : in STD_LOGIC_VECTOR(15 downto 0);
    srcB : in STD_LOGIC_VECTOR(15 downto 0);
    op   : in STD_LOGIC_VECTOR(3 downto 0);
    
    result : out STD_LOGIC_VECTOR(15 downto 0)
  );
end alu;

architecture behavioral of alu is
  
begin
  process(srcA, srcB, op)
    variable tmp_res: std_logic_vector(16 downto 0):="0"&ZERO;
  begin
    case op is
      when ALUOP_ADD =>
        tmp_res(15 downto 0) := srcA + srcB;
      when ALUOP_SUB =>
        tmp_res(15 downto 0) := srcA - srcB;
      when ALUOP_AND =>
        tmp_res(15 downto 0) := srcA and srcB;
      when ALUOP_OR  =>
        tmp_res(15 downto 0) := srcA or srcB;
      when ALUOP_NOT =>
        tmp_res(15 downto 0):= not srcA;
      when ALUOP_SLL =>
        if srcB = ZERO then
          tmp_res(15 downto 0) := to_stdlogicvector(to_bitvector(srcA) sll 8);
        else
          tmp_res(15 downto 0) := to_stdlogicvector(to_bitvector(srcA) sll conv_integer(srcB));
        end if;
      when ALUOP_SRA =>
        if srcB = ZERO then
          tmp_res(15 downto 0) := to_stdlogicvector(to_bitvector(srcA) sra 8);
        else
          tmp_res(15 downto 0) := to_stdlogicvector(to_bitvector(srcA) sra conv_integer(srcB));
        end if;
      when ALUOP_SUBU =>        
        tmp_res := ("0"&srcA) - ("0"&srcB);
        tmp_res := (0=>tmp_res(16), others=>'0');
      when ALUOP_CMP =>
        if srcA = srcB then
          tmp_res:=ZERO&'0';
        else 
          tmp_res:=ZERO&'1';
        end if;
      when others    =>
        tmp_res := "0"&ZERO;
    end case;
    result <= tmp_res(15 downto 0);
  end process;
  
    
end behavioral; 
