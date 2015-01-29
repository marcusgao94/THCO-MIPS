library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.common.ALL;

entity CPU is
  port(
 -- CLK:IN STD_LOGIC;
    boot_enable:in STD_logic;
    clk_ori: in STD_LOGIC;
	 ps2_clk: in std_logic;
    ps2_data   : IN  STD_LOGIC;
    rst_ori: in STD_LOGIC;
	 bootstart:in std_logic;
	 out_ter : in STD_LOGIC;
    --debug
		debug_input : in STD_LOGIC_VECTOR(15 downto 0);
	   debug_pc: out STD_LOGIC_VECTOR(15 downto 0);
	 --debug
    RAM2_EN: out STD_LOGIC;
    RAM2_WE: out STD_LOGIC;
    RAM2_OE: out STD_LOGIC;
    RAM2_Data: inout STD_LOGIC_VECTOR(15 downto 0);
    RAM2_Addr: out STD_LOGIC_VECTOR(15 downto 0);
    tsre,tbre,data_ready:in std_logic;
    ram1_en,ram1_oe,ram1_we,port_oe,port_we:out std_logic;
	 MemAddrM:out std_logic_vector(15 downto 0);
    Ram1DataM:inout std_logic_vector(15 downto 0);
	 flash_byte : out std_logic;
    flash_vpen : out std_logic;
    flash_rp : out std_logic;
    flash_ce : out std_logic;
    flash_oe : out std_logic;
    flash_we : out std_logic;
    flash_addr : inout std_logic_vector(21 downto 0);
    flash_data : inout std_logic_vector(15 downto 0);
	 vga_h_sync,vga_v_sync:out std_logic;
	 vga_r, vga_g, vga_b:out std_logic_vector(2 downto 0)
  );
end CPU;

architecture behavioral of CPU is

  component pcmux 
  port (
    pc_to_ram2, pc_plus_oneF: in STD_LOGIC_VECTOR(15 downto 0);
    pc_stay: in STD_LOGIC;
    y: out STD_LOGIC_VECTOR(15 downto 0)
  );
  end component;

  component pc
  port(
    clk : in STD_LOGIC;
    rst : in STD_LOGIC;
    
    pc_in : in STD_LOGIC_VECTOR(15 downto 0);
    stay : in STD_LOGIC;
    jump: in STD_LOGIC;
    jump_addr: in STD_LOGIC_VECTOR(15 downto 0);
    
    pc_plus_one: out STD_LOGIC_VECTOR(15 downto 0);
    pc_out : out STD_LOGIC_VECTOR(15 downto 0)
  );
  end component;
  
  component registerfile
  port(
  
    --debug
	 --debug
		debug_r0,debug_r1,debug_r2,debug_r3,debug_r4,debug_r5,debug_r6,debug_r7,debug_rT,debug_rpc: out std_logic_vector(15 downto 0);
		--debug
	 --debug
    clk : in STD_LOGIC;
    rst : in STD_LOGIC;
     
    REGF_SrcA: in STD_LOGIC_VECTOR(3 downto 0);
    REGF_SrcB: in STD_LOGIC_VECTOR(3 downto 0);
    REGF_InAddr : in STD_LOGIC_VECTOR(3 downto 0);
    REGF_WE : in STD_LOGIC;
    REGF_InData : in STD_LOGIC_VECTOR(15 downto 0);
    REGF_InPC : in STD_LOGIC_VECTOR(15 downto 0);
    
    REGF_OutA: out STD_LOGIC_VECTOR(15 downto 0);
    REGF_OutB: out STD_LOGIC_VECTOR(15 downto 0)
      
  );
  end component;
  
  component fredivider
  port(
    clkin:in STD_LOGIC;
    clkout:out STD_LOGIC
  );
  end component;
  
  component ram2
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
  end component;
  
  component IF_ID_Register
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
  end component;
  
  component controller
  port(
    CTRL_Inst: in STD_LOGIC_VECTOR(15 downto 0); -- Instruction from IF
    
    ALU_Op: out STD_LOGIC_VECTOR(3 downto 0);
    REGF_A: out STD_LOGIC_VECTOR(3 downto 0);
    REGF_B: out STD_LOGIC_VECTOR(3 downto 0);
    Imm: out STD_LOGIC_VECTOR(15 downto 0);
    ALU_B_Src: out STD_LOGIC;
    MEMControl: out STD_LOGIC_VECTOR(1 downto 0);
    RegWrite : out STD_LOGIC;
    RegWrite_Addr: out STD_LOGIC_VECTOR(3 downto 0);
    MemtoReg: out STD_LOGIC;
    JumpType: out STD_LOGIC_VECTOR(2 downto 0);
    IS_SW: out STD_LOGIC
  );
  end component;
  
  component comparator is
    port(
      rst : in STD_LOGIC;
    JumpType :in STD_LOGIC_VECTOR(2 downto 0);
    RegA : in STD_LOGIC_VECTOR(15 downto 0);
    RegB : in STD_LOGIC_VECTOR(15 downto 0);
    --actually jump or not
    Jump: out STD_LOGIC
    );
  end component;
  
  component id_exe_register is
    port(
    clk, rst: in STD_LOGIC;
	 flush:in STD_LOGIC;--new add --
    --for exe
    In_ALU_A, In_ALU_B, In_Imm: in STD_LOGIC_VECTOR(15 downto 0);
    In_ALU_B_Src: in STD_LOGIC;
    In_ALU_Op: in STD_LOGIC_VECTOR(3 downto 0);
    In_JumpType: in STD_LOGIC_VECTOR(2 downto 0);
    In_Jump: in STD_LOGIC;
    In_IS_SW: in STD_LOGIC;
    In_Rs, In_Rt: in STD_LOGIC_VECTOR(3 downto 0);
    
    --for mem
    In_RAM1_Control: in STD_LOGIC_VECTOR(1 downto 0);
    
    --for wb
    In_MemtoReg : in STD_LOGIC;
    In_RegWrite: in STD_LOGIC;
    In_RegWriteAddr: in STD_LOGIC_VECTOR(3 downto 0);
    --out for exe
    Out_ALU_A, Out_ALU_B, Out_Imm: out STD_LOGIC_VECTOR(15 downto 0);
    Out_ALU_B_Src: out STD_LOGIC;
    Out_ALU_Op: out STD_LOGIC_VECTOR(3 downto 0);
    Out_JumpType: out STD_LOGIC_VECTOR(2 downto 0);
    Out_Jump: out STD_LOGIC;
    OUT_IS_SW: out STD_LOGIC;
    Out_Rs, Out_Rt: out STD_LOGIC_VECTOR(3 downto 0);
    --out for mem
    Out_RAM1_Control: out STD_LOGIC_VECTOR(1 downto 0);
    
    --out for wb
    Out_MemtoReg : out STD_LOGIC;
    Out_RegWrite: out STD_LOGIC;
    Out_RegWriteAddr: out STD_LOGIC_VECTOR(3 downto 0) 
    );
  end component; 
  
  component alu is
    port(
    srcA : in STD_LOGIC_VECTOR(15 downto 0);
    srcB : in STD_LOGIC_VECTOR(15 downto 0);
    op   : in STD_LOGIC_VECTOR(3 downto 0);
    
    result : out STD_LOGIC_VECTOR(15 downto 0)
    );
  end component;
  
  component JumpAddrMux is
  port(
    ALUresult: in STD_LOGIC_VECTOR(15 downto 0);
    JumpType: in STD_LOGIC_VECTOR(2 downto 0);
    ALU_B: in STD_LOGIC_VECTOR(15 downto 0);
    
    OutAddr: out STD_LOGIC_VECTOR(15 downto 0)    
  );
end component;

component EXE_MEM_Register is
  port(
    clk,rst: in STD_LOGIC;
    
    --for mem
    In_RAM1_Control: in STD_LOGIC_VECTOR(1 downto 0);
    In_RAM1_Addr: in STD_LOGIC_VECTOR(15 downto 0);
    In_RAM1_InData: in STD_LOGIC_VECTOR(15 downto 0);    
    
    --for wb
    In_MemtoReg : in STD_LOGIC;
    In_ALUResult: in STD_LOGIC_VECTOR(15 downto 0);
    In_RegWrite: in STD_LOGIC;
    In_RegWriteAddr: in STD_LOGIC_VECTOR(3 downto 0);
    --out for mem
    Out_RAM1_Control: out STD_LOGIC_VECTOR(1 downto 0);
    Out_RAM1_Addr: out STD_LOGIC_VECTOR(15 downto 0);
    Out_RAM1_InData: out STD_LOGIC_VECTOR(15 downto 0);  
    
    --out for wb
    Out_MemtoReg : out STD_LOGIC;
    Out_ALUResult: out STD_LOGIC_VECTOR(15 downto 0);
    Out_RegWrite: out STD_LOGIC;
    Out_RegWriteAddr: out STD_LOGIC_VECTOR(3 downto 0) 
  );
end component;

component MEM_WB_Register is
  port(
    clk,rst: in STD_LOGIC;
    
    In_MemtoReg : in STD_LOGIC;
    In_ALUResult: in STD_LOGIC_VECTOR(15 downto 0);
    In_RegWrite: in STD_LOGIC;
    In_MemData: in STD_LOGIC_VECTOR(15 downto 0);
    In_RegWriteAddr: in STD_LOGIC_VECTOR(3 downto 0);

    Out_MemtoReg : out STD_LOGIC;
    Out_ALUResult: out STD_LOGIC_VECTOR(15 downto 0);
    Out_RegWrite: out STD_LOGIC;
    Out_MemData: out STD_LOGIC_VECTOR(15 downto 0);
    Out_RegWriteAddr: out STD_LOGIC_VECTOR(3 downto 0) 
  );
end component;

component Hazard is
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
end component;
  
component memtoregMux2 is
  port (
    alu, mem: in STD_LOGIC_VECTOR(15 downto 0);
    memtoreg: in STD_LOGIC;
    y: out STD_LOGIC_VECTOR(15 downto 0)
  );
end component;  

component alubsrcMux2 is
  port (
    reg, imm: in STD_LOGIC_VECTOR(15 downto 0);
    alu_b_src: in STD_LOGIC;
    y: out STD_LOGIC_VECTOR(15 downto 0)
  );
end component;

component forwardEMux4 is
  port (
    ori, alu, mem: in STD_LOGIC_VECTOR(15 downto 0);
    s: in STD_LOGIC_VECTOR(1 downto 0);
    y: out STD_LOGIC_VECTOR(15 downto 0)
  );
end component;


component forwardDMux2 is
  port (
    reg, alu: in STD_LOGIC_VECTOR(15 downto 0);
    s: in STD_LOGIC;
    y: out STD_LOGIC_VECTOR(15 downto 0)
  );
end component;

component pcwriteMux2 is
  port (
   pc, write: in STD_LOGIC_VECTOR(15 downto 0);
	flash_addr:in STD_LOGIC_VECTOR(21 downto 0);
	 booting: in std_logic;
    s: in STD_LOGIC_VECTOR(1 downto 0);
	 userlwstall: in std_logic;
    y: out STD_LOGIC_VECTOR(15 downto 0)
  );
end component;

component RAM1 is
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
		  keyboard_out: out std_logic_vector(7 downto 0)
    );
end component;

component ram12dataMux2 is
    Port ( ram1Data : in  STD_LOGIC_VECTOR(15 downto 0);
           ram2Data : in  STD_LOGIC_VECTOR(15 downto 0);
           ram12choose : in  STD_LOGIC;
           ramoutData : out  STD_LOGIC_VECTOR(15 downto 0)
			  );
end component;
  
component boot is
  port(
    clk : in std_logic;
	 enable:in std_logic;
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
end component;
  
component ram2memflashMux2 is
    Port ( mem : in  STD_LOGIC_VECTOR(15 downto 0);
           flash : in  STD_LOGIC_VECTOR(15 downto 0);
           booting : in  STD_LOGIC;
           y : out  STD_LOGIC_VECTOR(15 downto 0)
			  );
end component;

component ram2controlMux2 is
    Port ( ori : in  STD_LOGIC_VECTOR(1 downto 0);
           booting : in  STD_LOGIC;
           y : out  STD_LOGIC_VECTOR(1 downto 0)
			 );
end component;
  
 
  signal clk :std_logic;
  signal next_pc, pc_plus_oneF, pc_to_ram2: std_logic_vector(15 downto 0):=ZERO;
  signal instD: std_logic_vector(15 downto 0):=NOP;
  signal ALU_OpD: std_logic_vector(3 downto 0):=ALUOP_NULL;
  signal REGF_AD, REGF_BD: std_logic_vector(3 downto 0):=REGF_NULL;
  signal ImmD:std_logic_vector(15 downto 0):=ZERO;
  signal ALU_B_SrcD, ALU_B_SRCE, RegWriteD, MemtoRegD:std_logic;
  signal RegWriteAddrD, regWriteAddrE, RegWriteAddrW, RegWriteAddrM:std_logic_vector(3 downto 0);
  signal MEMControlD: std_logic_vector(1 downto 0);
  signal JumpTypeD: std_logic_vector(2 downto 0);
  signal REGF_OutAD, REGF_OutBD: std_logic_vector(15 downto 0):=ZERO;
  signal JumpD, JumpE: std_logic;
  signal RAM2Control: std_logic_vector(1 downto 0):=MEMCONTROL_READ;
  signal IS_SWD,IS_SWE:std_logic;
  signal RegWriteW, regwriteE, regwriteM:std_logic;
  signal rega_mux, regb_mux, ALU_AE, ALU_BE, alua_mux, alub_mux:std_logic_vector(15 downto 0);
  signal ImmE:std_logic_vector(15 downto 0);
  signal RsE, RtE: std_logic_vector(3 downto 0);
  signal RAM1_ControlE, RAM1_ControlM:std_logic_vector(1 downto 0);
  signal memtoregE, memtoregM, MemtoRegW:std_logic;
  signal ALU_ResultE, ALU_ResultM, ALU_ResultW:std_logic_vector(15 downto 0);
  signal ALU_OpE:std_logic_vector(3 downto 0);
  signal JumpTypeE:std_logic_vector(2 downto 0);
  signal forwardae,forwardbe:std_logic_vector(1 downto 0);
  signal forwardad,forwardbd:std_logic;
  signal alu_b_te, alu_a_te, Memdataw:std_logic_vector(15 downto 0);
  signal ram1_indataM, regf_inDataW:std_logic_vector(15 downto 0);
  signal hazard_if_id_pause, hazard_pc_pause, if_id_register_int:std_logic;
  signal hazard_RAM2_Control:std_logic_vector(1 downto 0);
  signal Jump_AddrE, hazard_ram2_Indata_mux, pcd:std_logic_vector(15 downto 0);
  signal ram1_addrM, pc_or_write_or_flash_mux:std_logic_vector(15 downto 0);
  --debug
  signal DEBUG_R0,DEBUG_R7,DEBUG_RT,debug_r1,debug_r2,debug_r3,debug_r4,debug_r5,debug_r6, debug_rpc: std_logic_vector(15 downto 0);
  --debug
  --Ram1DataM is the output of ram1, need to through a mux(ram12datamux) with  ram2 out put
  signal pc_in_after_mux, MemDataM: std_logic_vector(15 downto 0);
  signal stallF, stallD, flushD, flushE, hazard_userlwstall: std_logic;
  signal out_ter_clk, out_ter_last: std_logic:='0';
  signal booting:std_logic:='0';
  signal MemFlashData: std_logic_vector(15 downto 0);
  signal ram2FlashControl: std_logic_vector(1 downto 0);
  signal rst:std_logic;
  signal key:std_logic_vector(7 downto 0);
  
begin
  --debug
  with debug_input(13 downto 1)&boot_enable select debug_pc <= 
		alua_mux when "10000000000000",
		alub_mux when "10000000000001",
		alu_b_te when  "10000000000010",
		forwardaD&forwardbD&"1111111111" & forwardae & forwardbe when "00000000000010",
		pc_to_ram2 when "00000000000100",
		pc_plus_oneF when "00000000000110",
		pcD when "00000000000111",
		instD when "00000000000011",
		
		Jump_AddrE when "01000000000000",
		stallF & stallD & flushD & flushE & "111111111111" when "00000000001111",
		jumpD & jumpE & stallD & IS_SWD&IS_SWE&"11111111"&JumpTypeD when "00000000000101",
		RegWriteADdrE &"11111111"&regf_bd when "11110000000000",
		RegWriteAddrD &  regf_ad & rse & rte when "11110000000001",
		ram1datam when "00100000000000",
		regf_indataw when "00100000000001",
		regwritew & memtoregw &"11111111111111" when "00100000000010",
		memdataw when "00100000000011",
		alu_resultw when "00100000000100",
		ALU_RESULTe WHEN "00100000000101",
		debug_r0 when "11000000000000",
		debug_r7 when "11000000000111",
		debug_rT when "11000000001001",
		debug_r1 when "11000000000001",
		debug_r2 when "11000000000010",
		debug_r3 when "11000000000011",
		debug_r4 when "11000000000100",
		debug_r5 when "11000000000101",
		debug_r6 when "11000000000110",
		debug_rpc when "11000000001111",
		
		
		hazard_RAM2_Control &"11111111111111" when "00010000000000",
		RAM1_AddrM when "00010000000001",
		RAM1_InDataM when "00010000000010",
		pc_or_write_or_flash_mux when "00010000000011",
		ram1_controlm &"1111111111111"&hazard_userlwstall when "00010000000100",
		alu_resulte when "00010000000101",
		rAM1DATAm WHEN "00010000000110",
		RAM2_DATA WHEN "00010000000111",
		
		flash_addr(15 downto 0) when "01110000000000",
		flash_data when "01110000000001",
		booting &"1111111111111"&ram2flashcontrol when "01110000000010",
		memflashdata when "01110000000011",
      "00000000"&key when "11111111110000",
		out_ter & out_ter_clk & out_ter_last &"1111111111111" when "01100000000000", 
      "1111111111111111" when others;
  --debug
  
  rst <= rst_ori and (not booting);
  ufredivider:
    fredivider port map(
      clkin=>clk_ori, clkout=>clk
    );
  uboot:
    boot port map(
	   clk=>clk, enable=>boot_enable,start=>bootstart,
		flash_byte=>flash_byte,
      flash_vpen=>flash_vpen,
        flash_rp=>flash_rp,
        flash_ce =>flash_ce,
        flash_oe=>flash_oe,
        flash_we=>flash_we,
        flash_addr=>flash_addr,
        flash_data=>flash_data,
		  booting=>booting
	 );
  upcmux:
    pcmux port map(
		pc_to_ram2 =>pc_to_ram2, pc_plus_oneF =>pc_plus_oneF, 
		pc_stay => stallF, 
		y => pc_in_after_mux
	 );
	 
  
  upc: 
    pc port map(
      --clk=>clk, rst=>rst, pc_in=>pc_plus_oneF, stay=>pcstay, jump=>JumpE, jump_addr=>Jump_AddrE,
		clk=>clk, rst=>rst, pc_in=>pc_in_after_mux, stay=>'0', jump=>JumpE, jump_addr=>Jump_AddrE,
      pc_plus_one=>pc_plus_oneF, pc_out => pc_to_ram2
    );
  uram2memflashMux2:
     ram2memflashMux2 port map(
	    mem=>RAM1_InDataM,flash=>flash_data,booting=>booting,
		 y=>MemFlashData
	  );  
	uram2controlMux2:  
	  ram2controlMux2 port map
   ( ori=>hazard_RAM2_Control,
           booting=>booting,
           y=>ram2Flashcontrol
			 );

  uram2:
    ram2 port map(
      clk=>clk, RAM2_Control=>ram2FlashControl,RAM2_InData=>MemFlashData,
      RAM2_InAddr=>pc_or_write_or_flash_mux, RAM2_EN=>RAM2_EN, RAM2_WE=>RAM2_WE,
      RAM2_OE=>RAM2_OE, RAM2_Data=>RAM2_Data, RAM2_Addr=>RAM2_Addr
    );
    
  upcwriteMux2:
    pcwriteMux2 port map(
      pc=>pc_to_ram2,write=>RAM1_AddrM,flash_addr=>flash_addr,booting=>booting,
      s=>hazard_RAM2_Control,userlwstall=>hazard_userlwstall,
		y=>pc_or_write_or_flash_mux
    );				  
  process(out_ter, clk)
  begin
   if clk'event and clk='0' then
    if out_ter='0' and out_ter_last='1' then
      out_ter_clk<='1';
		out_ter_last<='0';
    else
      out_ter_clk<='0';
      out_ter_last<=out_ter;
   end if;		
  end if;
  end process;
  uif_id_register:
    if_id_register port map(
      clk=>clk, rst=>rst, out_ter => out_ter_clk, stall=>stallD, InInst=>RAM2_Data, InPC=>pc_plus_oneF,
      flush=>flushD, PC_INT=>if_id_register_int, OutPC=>pcD, OutInst=>instD
    );
  
  ucontroller:
    controller port map(
      CTRL_Inst=>instD, ALU_Op=>ALU_opD, REGF_A=>REGF_AD,
      REGF_B=>REGF_BD, Imm=>ImmD, ALU_B_Src=>ALU_B_SrcD,
      MEMControl=>MEMControlD, RegWrite=>RegWriteD,
      RegWrite_Addr=>RegWriteAddrD, MemtoReg=>MemtoRegD,
      JumpType=>JumpTypeD, IS_SW=>IS_SWD
    );
    
  uregisterfile:
    registerfile port map(
	   --debug
		debug_r0=>debug_r0,
		debug_r1=>debug_r1,
		debug_r2=>debug_r2,
		debug_r3=>debug_r3,
		debug_r4=>debug_r4,
		debug_r5=>debug_r5,
		debug_r6=>debug_r6,
		debug_r7=>debug_r7,
		debug_rT=>debug_rT,
		debug_rpc=>debug_rpc,
		--debug
      clk=>clk, rst=>rst, REGF_SrcA=>REGF_AD, REGF_SrcB=>REGF_BD,
      REGF_InAddr=>RegWriteAddrW, REGF_WE=>RegWriteW,
      REGF_InData=>REGF_InDataW, REGF_InPC=>pcD,
      REGF_OutA=>REGF_OutAD, REGF_OutB=>REGF_OutBD
    );
    
  ucomparator:
    comparator port map(
      rst=>rst, JumpType=>JumpTypeD, RegA=>rega_mux, RegB=>regb_mux, Jump=>JumpD
    );
    
  uid_exe_register:
    id_exe_register port map(
      clk=>clk, rst=>rst, flush=>flushE,
      In_ALU_A=>rega_mux, In_ALU_B=>regb_mux, In_Imm=>ImmD,
      In_ALU_B_Src=>ALU_B_SrcD, In_ALU_Op=>ALU_OpD, In_JumpType=>JumpTypeD,
      In_Jump=>JumpD,
      In_IS_SW=>IS_SWD, In_Rs=>REGF_AD,In_Rt=>REGF_BD,In_RAM1_Control=>MEMControlD,
      In_MemtoReg=>MemtoRegD, In_RegWrite=>RegWriteD, 
      In_RegWriteAddr=>RegWriteAddrD, Out_ALU_A=>ALU_AE,
      Out_ALU_B=>ALU_BE, Out_Imm=>ImmE, Out_ALU_B_Src=>ALU_B_SrcE,
      Out_ALU_Op=>ALU_OpE, Out_JumpType=>JumpTypeE, Out_Jump=>JumpE,
      Out_IS_SW=>IS_SWE, Out_Rs=>RsE, Out_Rt=>RtE, Out_RAM1_Control=>RAM1_ControlE,
      Out_MemtoReg=>MemtoRegE, Out_RegWrite=>RegWriteE,
      Out_RegWriteAddr=>RegWriteAddrE
    );
    
  ualu:
    alu port map(
      srcA=>alua_mux,srcB=>alub_mux,op=>ALU_OpE,
      result=>ALU_ResultE      
    );
  
  uJumpAddrMux:
    JumpAddrMux port map(
      ALUResult=>ALU_ResultE, JumpType=>JumpTypeE,
      ALU_B=>ALU_B_TE, OutAddr=>Jump_AddrE
    );
  
  uexe_mem_register:
    EXE_MEM_REGISTER port map(
      clk=>clk, rst=>rst,
      In_RAM1_Control=>RAM1_ControlE, In_RAM1_Addr=>ALU_ResultE,
      In_RAM1_InData=>ALU_B_TE, In_MemtoReg=>MemtoRegE, In_ALUResult=>ALU_ResultE,
      In_RegWrite=>RegWriteE, In_RegWriteAddr=> RegWriteAddrE,
      Out_RAM1_Control=>RAM1_ControlM, Out_RAM1_Addr=>RAM1_AddrM,
      Out_RAM1_InData=>RAM1_InDataM, Out_MemtoReg=>MemtoRegM, Out_ALUResult=>ALU_ResultM,
      Out_RegWrite=>RegWriteM, Out_RegWriteAddr=>RegWriteAddrM
    );
  
  uram1:
    ram1 port map(
      rst=>rst, clk=>clk,clk_ori=>clk_ori,ps2_clk=>ps2_clk,ps2_data=>ps2_data,
      reg_addr=>RAM1_AddrM,reg_data=>RAM1_InDataM,
      read_write=>RAM1_ControlM,tsre=>tsre,tbre=>tbre,
      data_ready=>data_ready,ram1_en=>ram1_en,
      ram1_oe=>ram1_oe, ram1_we=>ram1_we, port_oe=>port_oe, port_we=>port_we,
      mem_addr=>MemAddrM,mem_data=>Ram1DataM,
		vga_h_sync=>vga_h_sync,vga_v_sync=>vga_v_sync,
		vga_r=>vga_r,vga_g=>vga_g,vga_b=>vga_b,
		keyboard_out=>key
    );
    
  umem_wb_register:
    MEM_WB_Register port map(
      clk=>clk, rst=>rst,
      In_MemtoReg=>MemtoRegM, In_ALUResult=>ALU_ResultM,
      In_RegWrite=>RegWriteM, In_MemData=>MemDataM, In_RegWriteAddr=>RegWriteAddrM,
      Out_MemtoReg=>MemtoRegW, Out_ALUResult=>ALU_ResultW,
      Out_RegWrite=>RegWriteW, Out_MemData=>MemDataW, Out_RegWriteAddr=>RegWriteAddrW
      );
  
  uhazard:
    Hazard port map(
	   pc_int=>if_id_register_int,
      rsD=>REGF_AD,rtD=>REGF_BD,rsE=>RsE,rtE=>RtE,
      writeregE=>RegWriteAddrE, writeregM=>RegWriteAddrM, writeregW=>RegWriteAddrW,
      RegWriteE=>regWriteE,RegWriteM=>regWriteM,RegWriteW=>regWriteW,
      memtoregE=>memtoregE,memtoregM=>memtoregM,jumpd=>jumpD, jumpe=>jumpE,jumptype=>JumpTypeD,
      memcontrolM=>RAM1_ControlM, WriteAddr=>RAM1_AddrM,
      forwardaD=>forwardaD,forwardbD=>forwardbD,
      forwardaE=>forwardaE,forwardbE=>forwardbE,
      stallF=>stallF,flushD=>flushD,stallD=>stallD,flushE=>flushE,
      RAM2_Control=>hazard_RAM2_Control,
		userlwstall=>hazard_userlwstall
    ); 

  uram12dataMux2:
    ram12dataMux2 port map(
	   ram1Data=>Ram1DataM,ram2Data=>Ram2_Data,
      ram12choose=>hazard_userlwstall,
		ramoutData=>MemDataM
	 );  
    
  umemtoregmux2:
    memtoregMux2 port map(
      alu=>ALU_ResultW,mem=>MemDataW,memtoreg=>MemtoRegW,
      y=> REGF_InDataW
    );
    
--  ualubsrcMux2:
--    alubsrcMux2 port map(
--      reg=>ALU_BE, imm=>ImmE, alu_b_src=>ALU_B_SRCE,
--      y=>ALU_B_TE
--    );
  ualubsrcMux2:
    alubsrcMux2 port map(
	   reg=>ALU_B_TE,imm=>ImmE,alu_b_src=>ALU_B_SRCE,
		y=>alub_mux
	 );
  
  uforwardAE:
    forwardEMux4 port map(
      ori=>ALU_AE,alu=>ALU_ResultM,mem=>REGF_InDataW,
      s=>forwardaE,y=>alua_mux
    );
--  uforwardBe:
--    forwardEMux4 port map(
--      ori=>ALU_B_TE,alu=>ALU_ResultM,mem=>REGF_InDataW,
--      s=>forwardbE,y=>alub_mux
--    );
  ufowrwardBE:
     forwardEMux4 port map(
	    ori=>ALU_BE,alu=>ALU_ResultM,mem=>REGF_InDataW,
		 s=>forwardbE,y=>ALU_B_TE
	  );
    
  uforwardAD:
    forwardDMux2 port map(
     reg=>REGF_OutAD,alu=>ALU_ResultM,s=> forwardaD,
     y=>rega_mux
     );
      
  uforwardBD:
    forwardDMux2 port map(
      reg=>REGF_OutBD,alu=>ALU_ResultM,s=> forwardbD,
     y=>regb_mux
    );
     
  
  
    
    
  
end behavioral;
