library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.common.all;

entity RAM1 is
    port(
        -- input
		  rst : in std_logic;
        clk : in std_logic;
        reg_addr, reg_data : inout std_logic_vector(15 downto 0);
        read_write : inout std_logic_vector(1 downto 0);
        tsre, tbre : in std_logic;
        data_ready : in std_logic;
  
        -- output  		  
        ram1_en : out std_logic;
        ram1_oe, ram1_we : out std_logic;
        port_oe, port_we : out std_logic; -- port_oe = rdn, port_we = wrn
        mem_addr : out std_logic_vector(15 downto 0);
        mem_data : inout std_logic_vector(15 downto 0)
    );
end RAM1;

architecture behavior of RAM1 is
    signal data_src : std_logic_vector(1 downto 0);
    signal temp_data : std_logic_vector(15 downto 0);
begin  
    process(reg_addr, reg_data, read_write, data_ready, tsre, tbre)
    begin
        if reg_addr = PORT_STATUS then
            temp_data <= ZERO;
            temp_data(0) <= (tbre and tsre); -- ?????А??a????"??????бе??|??????
            temp_data(1) <= data_ready; -- ?????А??aиибе??"??????бе??|??????
            data_src <= "11";
        elsif reg_addr = PORT_DATA then
            data_src <= "00";
        elsif ((reg_addr >= USERPROGRAM_BEGIN) and (reg_addr < USERPROGRAM_END)) then
            data_src <= "10";
        else 
            data_src <= "01";
        end if;
    end process;
	 
	 process(reg_addr, reg_data, read_write, mem_data, temp_data)
	 begin
		if read_write = MEMCONTROL_WRITE then
			mem_data <= reg_data;
			mem_addr <= reg_addr;
		elsif read_write = MEMCONTROL_READ then
			if data_src = "11" then
				mem_data <= temp_data;
				mem_addr <= reg_addr;
			else 
				mem_data <= HIGH_Z;
				mem_addr <= reg_addr;
			end if;
		else 
		  mem_data <= HIGH_Z;
		  mem_addr <= reg_addr;
		end if;
	 end process;
  
    process(clk, reg_addr, read_write, data_src)
    begin
		if clk = '0' then -- ????"ж╠?13????-??А?ии??ии????бу??????иибе????
            if data_src = "01" then -- ?"????RAM1
                ram1_en <= '0';
                port_oe <= '1';
                port_we <= '1';
                if read_write = MEMCONTROL_WRITE then -- ???RAM1
                    ram1_oe <= '1';
                    ram1_we <= '0';
                elsif read_write = MEMCONTROL_READ then -- иибе?RAM1
                    ram1_oe <= '0';
                    ram1_we <= '1';
                elsif read_write = MEMCONTROL_DISABLE then -- ???????"бз??бн?- 
                    ram1_oe <= '1';
                    ram1_we <= '1';
                end if;
            elsif data_src = "00" then -- ?"??????2??бъ
                ram1_en <= '1';
                ram1_oe <= '1';
                ram1_we <= '1';
                if read_write = MEMCONTROL_WRITE then -- ?????2??  
                    port_oe <= '1';
                    port_we <= '0';
                elsif read_write = MEMCONTROL_READ then -- иибе???2??    
                    port_oe <= '0';
                    port_we <= '1';
                elsif read_write = MEMCONTROL_DISABLE then -- ???????"бз??бн?- 
                    port_oe <= '1';
                    port_we <= '1';
                end if;
            else -- иибе???2??бъ???????А
                ram1_en <= '1';
                ram1_oe <= '1';
                ram1_we <= '1';
                port_oe <= '1';
                port_we <= '1';
            end if;
        elsif clk = '1' then -- иж???"ж╠?13????-??А?????быА??бы?????бд??бы??1'
            ram1_en <= '1';  --?? may be problems
            ram1_oe <= '1';
            ram1_we <= '1';
            port_oe <= '1';
            port_we <= '1';
        end if;
    end process;
  
end behavior;    
