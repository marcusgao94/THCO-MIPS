library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.common.ALL;
--ram2: fetch instruction
entity ram2 is
  port(
      clk : in STD_LOGIC;
      RAM2_Control: in STD_LOGIC_VECTOR(1 downto 0);
      RAM2_InData: in STD_LOGIC_VECTOR(15 downto 0);
      RAM2_InAddr: in STD_LOGIC_VECTOR(15 downto 0);
      
      RAM2_EN: out STD_LOGIC;
      RAM2_WE: out STD_LOGIC;
      RAM2_OE: out STD_LOGIC;
      RAM2_Data: inout STD_LOGIC_VECTOR(15 downto 0);
      RAM2_Addr: out STD_LOGIC_VECTOR(15 downto 0)
  );
end ram2;

architecture behavioral of ram2 is
  
begin  
  process(RAM2_Control, RAM2_InData, RAM2_InAddr)
  begin
    case RAM2_Control is
      when MEMCONTROL_READ => RAM2_Data<=HIGH_Z;
                              RAM2_Addr<=RAM2_InAddr;
      when MEMCONTROL_WRITE =>RAM2_Addr<=RAM2_InAddr;
                              RAM2_Data<=RAM2_InData;
      when others => RAM2_Data<=HIGH_Z;
    end case;
  end process;
  --???????clk=0???????
  process(clk, RAM2_Control)
  begin
    if clk = '0' then
      RAM2_OE <= RAM2_Control(1);
      RAM2_WE <= RAM2_Control(0);
      RAM2_EN <= '0';
    elsif clk = '1' then
      RAM2_EN <= '1';
      RAM2_OE <= '1';
      RAM2_WE <= '1';
    end if;
  end process;
      
end behavioral;