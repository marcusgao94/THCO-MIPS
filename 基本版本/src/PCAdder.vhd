library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.common.ALL;
entity PCAdder is
  port(
    rst : in STD_LOGIC;
    PC_PLUS_ONE :in STD_LOGIC_VECTOR(15 downto 0);
    JumpType :in STD_LOGIC_VECTOR(2 downto 0);
    Imm : in STD_LOGIC_VECTOR(15 downto 0);
    RegA : in STD_LOGIC_VECTOR(15 downto 0);
    RegB : in STD_LOGIC_VECTOR(15 downto 0);
    --actually jump or not
    Jump: out STD_LOGIC;
    Out_PC : out STD_LOGIC_VECTOR(15 downto 0)
  );
end PCAdder;
architecture behavioral of  PCAdder is
begin
  process(PC_PLUS_ONE, JumpType, Imm, RegA, RegB)
  begin
    case JumpType is
      when JUMPTYPE_NOJUMP =>
        Out_PC <= PC_PLUS_ONE;
        Jump <= '0';
      when JUMPTYPE_TEQZ =>
        if RegB = ZERO then
          Out_PC <= RegA + Imm;
          Jump <='1';
        else
          Out_PC <= PC_PLUS_ONE;
          Jump <='0';
        end if;
      when  JUMPTYPE_TNEZ =>
        if RegB /= ZERO then
          Out_PC <= RegA + Imm;
          Jump <='1';
        else
          Out_PC <= PC_PLUS_ONE;
          Jump <='0';
        end if;
      when JUMPTYPE_EQZ =>
        if RegA = RegB then
          Out_PC <= PC_PLUS_ONE +Imm;
          Jump <= '1';
        else
          Out_PC <= PC_PLUS_ONE;
          Jump <= '0';
        end if;
      when JUMPTYPE_NEZ =>
        if RegA /= RegB then
          Out_PC <= PC_PLUS_ONE + Imm;
          Jump <= '1';
        else
          Out_PC <= PC_PLUS_ONE;
          Jump <= '0';
        end if;
      when JUMPTYPE_JUMP =>
        Out_PC <= RegA + Imm;
        Jump <= '1';
      when JUMPTYPE_JALR=>
        Out_PC <= RegB;
        Jump <= '1';
      when others =>
        null;
    end case;
  end process;
end behavioral;