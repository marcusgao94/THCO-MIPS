----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    04:03:39 12/06/2014 
-- Design Name: 
-- Module Name:    ram12dataMux2 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ram12dataMux2 is
    Port ( ram1Data : in  STD_LOGIC_VECTOR(15 downto 0);
           ram2Data : in  STD_LOGIC_VECTOR(15 downto 0);
           ram12choose : in  STD_LOGIC;
           ramoutData : out  STD_LOGIC_VECTOR(15 downto 0)
			  );
end ram12dataMux2;

architecture Behavioral of ram12dataMux2 is

begin
  ramoutData<= ram1Data when ram12choose='0'
               else ram2Data;

end Behavioral;

