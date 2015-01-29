----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    05:35:17 12/07/2014 
-- Design Name: 
-- Module Name:    boot - Behavioral 
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
use IEEE.std_logic_arith.all;
USE ieee.std_logic_signed.all;
library work;
use work.common.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity boot is
    Port (  
	     clk : in std_logic;
		  enable: in std_logic;
        start : in std_logic;
        flash_byte : out std_logic;
        flash_vpen : out std_logic;
        flash_rp : out std_logic;
        flash_ce : out std_logic;
        flash_oe : out std_logic;
        flash_we : out std_logic;
        flash_addr : out std_logic_vector(21 downto 0);
        flash_data : out std_logic_vector(15 downto 0);
        
		  booting: out std_logic
	);
end boot;

architecture Behavioral of boot is
  signal count : std_logic_vector(15 downto 0);
  signal cur_addr: std_logic_vector(15 downto 0);
begin

   process(clk, start, enable)
    begin
	   if enable='1' then
		
        if start = '0' then
		  --constant signals
            flash_byte <= '1';
            flash_vpen <= '1';
            flash_rp <= '1';
		  --constant signals end
            flash_ce <= '1';
            flash_oe <= '1';
            flash_we <= '1';
				cur_addr <= ZERO;
		  -- ramw controls			
            
            flash_data <= "ZZZZZZZZZZZZZZZZ";
           -- ram2_data <= "ZZZZZZZZZZZZZZZZ";
            flash_addr <= "0000000000000000000000";
          --  ram2_addr <= "0000000000000000";
            booting <= '1';
            count <= ZERO;
        elsif rising_edge(clk) then
            if count = "0000001000000000" then
			--	  mem2_en <= '0';
				  booting <= '0';
				else
				  booting<='1';
			--	  mem2_en <= '1';
				  flash_ce <= '0';
				  flash_oe <= '0';
				 -- cur_addr <= conv_std_logic_vector(count, 16);
				  flash_addr <= "000000"&count;
				  flash_data <= HIGH_Z;
				  count <= count + "0000000000000001";
				end if;
        end if;
		  else
		   booting<='0';
		 end if;
    end process;

end Behavioral;

