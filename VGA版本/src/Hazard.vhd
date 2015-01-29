library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.common.ALL;
entity Hazard is
  port(
   
	 pc_int: in STD_LOGIC;
    rsD, rtD, rsE, rtE: in STD_LOGIC_VECTOR(3 downto 0);
    writeregE, writeregM, writeregW: in STD_LOGIC_VECTOR(3 downto 0);
    RegWriteE, RegWriteM, regWriteW: in STD_LOGIC;
    memtoregE, memtoregM, jumpD, jumpE: in STD_LOGIC;
    jumptype: in STD_LOGIC_VECTOR(2 downto 0);
	 memcontrolM: in STD_LOGIC_VECTOR(1 downto 0);
    WriteAddr: in STD_LOGIC_VECTOR(15 downto 0);
    forwardaD, forwardbD: out STD_LOGIC;
    forwardaE, forwardbE: out STD_LOGIC_VECTOR(1 downto 0);
    
    stallF, flushD, stallD, flushE : out STD_LOGIC;
    RAM2_Control:out STD_LOGIC_VECTOR(1 downto 0);
	 userlwstall: out STD_LOGIC
  );
end Hazard;
architecture behavioral of Hazard is
  signal lwstall, swstall, branchstall,readstall:std_logic;
begin
  forwardaD <= FORWARDD_ALU when ((rsD /= REGF_NULL) and (rsD = writeregM) and
                                    (regwriteM = REGWRITE_YES))
                             else FORWARDD_REGF;
  forwardbD <= FORWARDD_ALU when ((rtD /= REGF_NULL) and (rtD = writeregM) and
                                   (regwriteM = REGWRITE_YES))
                             else FORWARDD_REGF;
  process(rsE, rtE, writeregM, regwriteM, writeregW, regwriteW, memcontrolM, WriteAddr)
  begin
    forwardaE <= FORWARDE_REGF;
    forwardbE <= FORWARDE_REGF;
    if (rsE /= REGF_NULL) then
      if  ((rsE = writeregM) and (regwriteM='1')) then
        forwardaE <= FORWARDE_ALU;
      elsif ((rsE = writeregW) and (regwriteW='1')) then
        forwardaE <= FORWARDE_WB;
      end if;
    end if;
    if (rtE /= REGF_NULL) then
      if ((rtE = writeregM) and (regwriteM='1')) then
        forwardbE <= FORWARDE_ALU;
      elsif ((rtE =  writeregW) and (regwriteW ='1')) then
        forwardbE <= FORWARDE_WB;
      end if;
    end if;      
  end process;
  lwstall <= '1' when (((memtoregE = MEMTOREG_MEM) and ((writeRegE = rsD) or (writeRegE = rtD)))
                       or ((memtoregM = MEMTOREG_MEM) and ((writeRegM = rsD)or(writeRegM = rtD))))
               else '0';
  branchstall <= '1' when ((jumptype/=JUMPTYPE_NOJUMP) and
                          (
                          ((regwriteE ='1') and ((writeregE=rsD)or(writeregE=rtD)))
                          or ((memtoregM = MEMTOREG_MEM) and ((writeregM = rsD) or (writeregM = rtD)))))
                   else  '0';
  swstall <= '1' when ((memcontrolM = MEMCONTROL_WRITE) and ((WriteAddr>=USERPROGRAM_BEGIN)and(WriteAddr<USERPROGRAM_END)))
               else '0';
  readstall <= '1' when ((memcontrolM = MEMCONTROL_READ) and ((WriteAddr>=USERPROGRAM_BEGIN)and(WriteAddr<USERPROGRAM_END)))
                  else '0';  
  stallF <= lwstall or  branchstall or swstall or readstall or jumpD or pc_int;
  flushD <= lwstall or branchstall or swstall or readstall or jumpD or jumpE;
  --IF_ID_pause <= lwstall or swstall;
  userlwstall<= readstall;
  stallD <= branchstall or lwstall;
  flushE <= branchstall or lwstall;
  with swstall select
    Ram2_Control<= MEMCONTROL_READ when '0',
                   MEMCONTROL_WRITE when others;
end behavioral;
