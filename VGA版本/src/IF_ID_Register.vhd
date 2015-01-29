library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.common.ALL;

entity IF_ID_Register is
  port(
    clk : in STD_LOGIC;
    rst : in STD_LOGIC;
	 out_ter : in STD_LOGIC;
	 stall: in STD_LOGIC;
    InInst : in STD_LOGIC_VECTOR(15 downto 0);
    InPC : in STD_LOGIC_VECTOR(15 downto 0);
    --check if need to insert nop
    flush : in STD_LOGIC;
    --here handle interrupt
    PC_INT : out STD_LOGIC;
    OutPC : out STD_LOGIC_VECTOR(15 downto 0);
    OutInst : out STD_LOGIC_VECTOR(15 downto 0)
  );
end IF_ID_Register;

architecture behavioral of IF_ID_Register is
  signal tmp_inst: std_logic_vector(15 downto 0);
  signal tem_pc : std_logic_vector(15 downto 0);
  signal int_code : std_logic_vector(7 downto 0);
  signal state: std_logic_vector(3 downto 0);
  signal start : std_logic_vector(3 downto 0);
begin
 
  process(clk, rst)
  begin
    if rst = '0' then
      state <= "0000";
      OutPC <= ZERO;
		OutInst <= NOP;
    elsif clk'event and clk='1' then
      if flush = '1' then
			OutPc <= tem_pc;
			if stall = '1' then
				OutInst<= tmp_inst;
			else 
				OutInst <= NOP;
			end if;
      elsif flush = '0' then 
        case state is
          when "0000" =>
					if InInst(15 downto 11) = INST_INT then
						state<= "0001";
						int_code <= "00000000";
						OutInst <= NOP;
						OutPC <= InPC;
						tem_pc <= InPC;
					elsif out_ter='1' and InPC>=USERPROGRAM_BEGIN and InPC<USERPROGRAM_END then
						state <= "0001";
						int_code <= "00010000";
						OutInst <= NOP;
						OutPC <= InPC - 1;
						tem_pc <= InPC - 1;
					else
						state <= "0000";
						int_code <= "00000000";
						OutInst <= InInst;
						tmp_inst <= InInst;
						OutPC <= InPC;
						tem_pc <= InPC;
					end if;      
					
          when "0001" => state<="0010";
			                OutInst <= MFPC_R6;
								 OutPC <= tem_pc;
          when "0010" => state<="0011";
			                OutInst <= ADDSP_FF;
								 OutPC <= tem_pc;
			 when "0011" => state<="0100";
			                OutInst <= SW_SP_R6_0;
								 OutPC <= tem_pc;
          when "0100" => state<="0101";
			                OutInst <= LI_PART & int_code;
								 OutPC <= tem_pc;
			 when "0101" => state<="0110";
								 OutInst <= ADDSP_FF;
								 OutPC <= tem_pc;
          when "0110" => state<="0111";
			                OutInst <= SW_SP_R6_0;
								 OutPC <= tem_pc;
          when "0111" => state<="1000";
			                OutInst <= LI_R6_5;
								 OutPC <= tem_pc;
			when "1000" => state <= "1001";
								OutInst <= NOP;
								OutPC <= tem_pc;
			 when "1001" => state<="1010";
			                OutInst <= JR_R6;
								 OutPC <= tem_pc;
			when "1010" => state <= "1011";
								OutInst <= NOP;
								OutPC <= tem_pc;
			when "1011" => state <= "0000";
								OutInst <= NOP;
								OutPC <= tem_PC;
          when others => null;
        end case;
		end if;
    end if;
  end process;
  
  with state select
    PC_INT <= '0' when "0000",
--              '0' when "1111",--??not sure this line needs or not
              '1' when others;
  
  
--  with state select
--    tmp_inst <= MFPC_R6     when  "0001",
--                ADDSP_FF    when  "0010",  
--                SW_SP_R6_0  when  "0011",
--                LI_PART&InInst(3 downto 0) when  "0100",
--                SW_SP_R6_0  when "0101",
--                LI_R6_7     when "0110",
--                JR_R6       when "0111",
--                NOP         when "1111",
--                InInst      when others;
end behavioral;