----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    06:22:52 12/07/2014 
-- Design Name: 
-- Module Name:    ram2memflashMux2 - Behavioral 
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

entity ram2memflashMux2 is
    Port ( mem : in  STD_LOGIC_VECTOR(15 downto 0);
           flash : in  STD_LOGIC_VECTOR(15 downto 0);
           booting : in  STD_LOGIC;
           y : out  STD_LOGIC_VECTOR(15 downto 0)
			  );
end ram2memflashMux2;

architecture Behavioral of ram2memflashMux2 is

begin
  y<= flash when booting='1'
       else mem;

end Behavioral;

