----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    06:27:05 12/07/2014 
-- Design Name: 
-- Module Name:    ram2controlMux2 - Behavioral 
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
library work;
use work.common.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ram2controlMux2 is
    Port ( ori : in  STD_LOGIC_VECTOR(1 downto 0);
           booting : in  STD_LOGIC;
           y : out  STD_LOGIC_VECTOR(1 downto 0)
			 );
end ram2controlMux2;

architecture Behavioral of ram2controlMux2 is
   
begin

y <= MEMCONTROL_WRITE when booting='1'
	     else ori;
end Behavioral;

