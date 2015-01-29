library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.common.ALL;
entity comparator is
  port(
    rst : in STD_LOGIC;
    JumpType :in STD_LOGIC_VECTOR(2 downto 0);
    RegA : in STD_LOGIC_VECTOR(15 downto 0);
    RegB : in STD_LOGIC_VECTOR(15 downto 0);
    --actually jump or not
    Jump: out STD_LOGIC
  );
end comparator;
architecture behavioral of comparator is
begin
  process(rst, JumpType, RegA, RegB)
  begin
    if rst ='0' then
      Jump <= '0';
    elsif rst='1' then
      case JumpType is
        when JUMPTYPE_NOJUMP =>
          Jump <= '0';
        when JUMPTYPE_TEQZ =>
          if RegB = ZERO then
            Jump <='1';
          else
            Jump <='0';
          end if;
        when JUMPTYPE_TNEZ =>
          if RegB /= ZERO then
            Jump <='1';
          else
            Jump <='0';
          end if;
        when JUMPTYPE_EQZ =>
          if RegB = ZERO then
            Jump <= '1';
          else
            Jump <= '0';
          end if;
        when JUMPTYPE_NEZ =>
          if RegB /= ZERO then
            Jump <= '1';
          else
            Jump <= '0';
          end if;
        when JUMPTYPE_JUMP =>        
          Jump <= '1';
        when JUMPTYPE_JALR=>
          Jump <= '1';
        when others =>
          null;
      end case;
    end if;
  
  end process;
end behavioral;

