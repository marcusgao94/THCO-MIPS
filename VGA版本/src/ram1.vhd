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
		  clk_ori:in std_logic;
		  ps2_clk: in std_logic;
		  ps2_data   : IN  STD_LOGIC;
        reg_addr, reg_data : inout std_logic_vector(15 downto 0);
        read_write : inout std_logic_vector(1 downto 0);
        tsre, tbre : in std_logic;
        data_ready : in std_logic;
  
        -- output  		  
        ram1_en : out std_logic;
        ram1_oe, ram1_we : out std_logic;
        port_oe, port_we : out std_logic; -- port_oe = rdn, port_we = wrn
        mem_addr : out std_logic_vector(15 downto 0);
        mem_data : inout std_logic_vector(15 downto 0);
		  vga_h_sync,vga_v_sync:out std_logic;
		  vga_r,vga_g,vga_b:out std_logic_vector(2 downto 0);
		  
		  --debug
		  keyboard_out: out std_logic_vector(7 downto 0)
    );
end RAM1;

architecture behavior of RAM1 is
    signal data_src : std_logic_vector(2 downto 0);
    signal temp_data : std_logic_vector(15 downto 0);
	 
	 
component ps2_keyboard_to_ascii IS
  GENERIC(
      clk_freq                  : INTEGER := 50_000_000; --system clock frequency in Hz
      ps2_debounce_counter_size : INTEGER := 8);         --set such that 2^size/clk_freq = 5us (size = 8 for 50MHz)
  PORT(
      clk        : IN  STD_LOGIC;                     --system clock input
      ps2_clk    : IN  STD_LOGIC;                     --clock signal from PS2 keyboard
      ps2_data   : IN  STD_LOGIC;                     --data signal from PS2 keyboard
      ascii_new  : OUT STD_LOGIC;                     --output flag indicating new ASCII value
      ascii_code : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)); --ASCII value, from high bit to low bit 
END component;


component vga_test is
  PORT(
    clk :  IN   STD_LOGIC;  --50M
	 clk_sys : IN   STD_LOGIC; -- System: 12.5M
    rst   :  IN   STD_LOGIC;  --rst
	 
	 write_ena : IN STD_LOGIC;
	 write_char : IN STD_LOGIC_VECTOR(15 downto 0);
	 
	 
    h_sync    :  OUT  STD_LOGIC;  --horiztonal sync pulse
    v_sync    :  OUT  STD_LOGIC;  --vertical sync pulse
    
	 r, g, b : out STD_LOGIC_VECTOR(2 downto 0)
	 
	 
	); 
end component;

 
  
   signal ps2_data_ready: std_logic;
	signal ascii:std_logic_vector(6 downto 0);
	signal vga_data:std_logic_vector(15 downto 0);
	signal vga_we:std_logic;

begin 
    keyboard_out <= ps2_data_ready & ascii;
    ups2keyboard:
      ps2_keyboard_to_ascii port map(
		  clk=>clk_ori,ps2_clk=>ps2_clk,ps2_data=>ps2_data,ascii_new=>ps2_data_ready,ascii_code=>ascii
		);
		
		uvga:
		  vga_test port map(
		    clk=>clk_ori,
	       clk_sys=>clk,
          rst=>rst, write_ena=>vga_we,
	       write_char=>mem_data,
			 h_sync=>vga_h_sync,
          v_sync=>vga_v_sync,
			 r=>vga_r,
			 g=>vga_g,
			 b=>vga_b	 
	    ); 
		
    process(reg_addr, reg_data, read_write, data_ready, tsre, tbre)
    begin
        if reg_addr = PORT_STATUS then
            temp_data <= ZERO;
            temp_data(0) <= (tbre and tsre); -- ?????А??a????"??????бе??|??????
            temp_data(1) <= data_ready; -- ?????А??aиибе??"??????бе??|??????
            data_src <= "011";
        elsif reg_addr = PORT_DATA then
            data_src <= "000";
		  elsif reg_addr = PS2_STATUS then
		      temp_data <= ZERO;
		      temp_data(1) <= ps2_data_ready;
				temp_data(0) <= '0';
				data_src <= "100";
        elsif reg_addr = PS2_DATA_ADDR then
		      data_src <= "101";
		    elsif reg_addr = VGA_STATUS then
		      temp_data <= ZERO;
		      temp_data(1) <= '0';
		      temp_data(0) <= '0';--default can write
		      data_src <= "110";
		    elsif reg_addr = VGA_DATA_ADDR then
		      data_src <= "111";		       
        elsif ((reg_addr >= USERPROGRAM_BEGIN) and (reg_addr < USERPROGRAM_END)) then
            data_src <= "010";
        else 
            data_src <= "001";
        end if;
    end process;
	 
	 process(reg_addr, reg_data, read_write, mem_data, temp_data)
	 begin
		if read_write = MEMCONTROL_WRITE then
			mem_data <= reg_data;
			mem_addr <= reg_addr;
		elsif read_write = MEMCONTROL_READ then
			if data_src = "011" then
				mem_data <= temp_data;
				mem_addr <= reg_addr;
			elsif data_src = "100" then
			   mem_data <= temp_data;
				mem_addr <= reg_addr;
			elsif data_src = "101" then
			   mem_data <= "000000000"&ascii;
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
            if data_src = "001" then -- ?"????RAM1
                ram1_en <= '0';
                port_oe <= '1';
                port_we <= '1';
                vga_we <= '1';
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
            elsif data_src = "000" then -- ?"??????2??бъ
                ram1_en <= '1';
                ram1_oe <= '1';
                ram1_we <= '1';
                vga_we <= '1';
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
            elsif data_src = "111" then
               vga_we <= '0'; 
            else -- иибе???2??бъ???????А
                ram1_en <= '1';
                ram1_oe <= '1';
                ram1_we <= '1';
                port_oe <= '1';
                port_we <= '1';
					 vga_we <= '1';
            end if;
        elsif clk = '1' then -- иж???"ж╠?13????-??А?????быА??бы?????бд??бы??1'
            ram1_en <= '1';  --?? may be problems
            ram1_oe <= '1';
            ram1_we <= '1';
            port_oe <= '1';
            port_we <= '1';
            vga_we  <= '1';
        end if;
    end process;
  
end behavior;    
