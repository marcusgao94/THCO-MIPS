library IEEE;
use IEEE.STD_LOGIC_1164.all;

package common is
  constant ZERO : std_logic_vector(15 downto 0) := "0000000000000000";
  constant EXCITED: integer := 0;
  
  constant ALUOP_ADD : std_logic_vector(3 downto 0) := "0000";
  constant ALUOP_SUB : std_logic_vector(3 downto 0) := "0001";
  constant ALUOP_AND : std_logic_vector(3 downto 0) := "0010";
  constant ALUOP_OR  : std_logic_vector(3 downto 0) := "0011";
  constant ALUOP_NOT : std_logic_vector(3 downto 0) := "0100";
  constant ALUOP_SLL : std_logic_vector(3 downto 0) := "0101";
  constant ALUOP_SRA  : std_logic_vector(3 downto 0) := "0110";
  constant ALUOP_SUBU : std_logic_vector(3 downto 0) := "0111";
  constant ALUOP_CMP  : std_logic_vector(3 downto 0) := "1000";
  constant ALUOP_NULL : std_logic_vector(3 downto 0) := "1111";
  --control signals
  constant ALU_B_SRC_IMM: std_logic := '1';
  constant ALU_B_SRC_REGF: std_logic := '0';
  constant REGWRITE_YES : std_logic:='1';
  constant REGWRITE_NO : std_logic:='0';
  constant MEMTOREG_ALU : std_logic:='0';
  constant MEMTOREG_MEM : std_logic:='1';
   -- jump control signals
  constant JUMPTYPE_NOJUMP: std_logic_vector(2 downto 0):="000";
  constant JUMPTYPE_TEQZ: std_logic_vector(2 downto 0):="001";
  constant JUMPTYPE_TNEZ: std_logic_vector(2 downto 0):="010";
  constant JUMPTYPE_EQZ   : std_logic_vector(2 downto 0):="011";
  constant JUMPTYPE_NEZ  : std_logic_vector(2 downto 0):="100";
  constant JUMPTYPE_JUMP: std_logic_vector(2 downto 0):="101";
  constant JUMPTYPE_JALR: std_logic_vector(2 downto 0):="110";
  --about register files --
  constant REGF_REGNUM : integer := 15;  --start from 0
    --0 to 7 common registers
    --8 IH
  constant REGF_IH : std_logic_vector(3 downto 0) := "1000";
    --9 T
  constant REGF_T : std_logic_vector(3 downto 0) := "1001";
    --10 SP
  constant REGF_SP : std_logic_vector(3 downto 0) := "1010";
    --11 RA
  constant REGF_RA : std_logic_vector(3 downto 0) := "1011";
    --12 PC
  constant REGF_PC : std_logic_vector(3 downto 0) := "1100";
  constant REGF_NULL : std_logic_vector(3 downto 0) := "1101";

  --instructions--  
  constant INST_NOP         : std_logic_vector(4 downto 0) := "00001";
  constant INST_B           : std_logic_vector(4 downto 0) := "00010";
  constant INST_BEQZ        : std_logic_vector(4 downto 0) := "00100";
  constant INST_BNEZ        : std_logic_vector(4 downto 0) := "00101";
  constant INST_SHIFT_M     : std_logic_vector(4 downto 0) := "00110"; --SRA, SLL
  constant INST_FUNC_SRA    : std_logic_vector(1 downto 0) := "11";
  constant INST_FUNC_SLL    : std_logic_vector(1 downto 0) := "00";
  constant INST_ADDIU3      : std_logic_vector(4 downto 0) := "01000";
  constant INST_ADDIU       : std_logic_vector(4 downto 0) := "01001";  
  constant INST_BRANCH_M    : std_logic_vector(4 downto 0) := "01100"; --BTEQZ, BTNEZ, MTSP, ADDSP
  constant INST_FUNC_ADDSP  : std_logic_vector(2 downto 0) := "011";
  constant INST_FUNC_BTEQZ  : std_logic_vector(2 downto 0) := "000";
  constant INST_FUNC_BTNEZ  : std_logic_vector(2 downto 0) := "001";
  constant INST_FUNC_MTSP   : std_logic_vector(2 downto 0) := "100";
  constant INST_LI          : std_logic_vector(4 downto 0) := "01101";
  constant INST_LW_SP       : std_logic_vector(4 downto 0) := "10010";
  constant INST_LW          : std_logic_vector(4 downto 0) := "10011";
  constant INST_SW_SP       : std_logic_vector(4 downto 0) := "11010";
  constant INST_SW          : std_logic_vector(4 downto 0) := "11011";
  constant INST_OPU_M       : std_logic_vector(4 downto 0) := "11100"; --SUBU, ADDU
  constant INST_FUNC_ADDU   : std_logic_vector(1 downto 0) := "01";
  constant INST_FUNC_SUBU   : std_logic_vector(1 downto 0) := "11";
  constant INST_LOGICJUMP_M : std_logic_vector(4 downto 0) := "11101"; --AND, CMP, JALR, JR, JRRA, MFPC, NOT, OR, SLTU
  constant INST_FUNC_AND    : std_logic_vector(4 downto 0) :="01100";
  constant INST_FUNC_CMP    : std_logic_vector(4 downto 0) :="01010";
  constant INST_FUNC_NOT    : std_logic_vector(4 downto 0) :="01111";
  constant INST_FUNC_OR     : std_logic_vector(4 downto 0) :="01101";
  constant INST_FUNC_SLTU   : std_logic_vector(4 downto 0) :="00011";
  constant INST_FUNC_JUMPS  : std_logic_vector(4 downto 0) :="00000";
  constant INST_FUNC_JALR   : std_logic_vector(2 downto 0) :="110";
  constant INST_FUNC_JR     : std_logic_vector(2 downto 0) :="000";
  constant INST_FUNC_JRRA   : std_logic_vector(2 downto 0) :="001";
  constant INST_FUNC_MFPC   : std_logic_vector(2 downto 0) :="010";
  constant INST_IH_M        : std_logic_vector(4 downto 0) := "11110"; --MTIH, MFIH
  constant INST_FUNC_MTIH   : std_logic:='1';
  constant INST_FUNC_MFIH   : std_logic:='0';
  constant INST_INT         : std_logic_vector(4 downto 0) := "11111";
  
  --about interrupt --
  constant MFPC_R6          : std_logic_vector(15 downto 0) := "1110111001000000";
  constant ADDSP_FF         : std_logic_vector(15 downto 0) := "0110001111111111";
  constant SW_SP_R6_0       : std_logic_vector(15 downto 0) := "1101011000000000";
  constant LI_R6_5          : std_logic_vector(15 downto 0) := "0110111000000101";
  constant JR_R6            : std_logic_vector(15 downto 0) := "1110111000000000";
  constant LI_PART          : std_logic_vector(11 downto 0) := "011011100000";
  constant NOP              : std_logic_vector(15 downto 0) := "0000100000000000";
  
  --hazard --
  constant FORWARDD_ALU   : std_logic := '1';
  constant FORWARDD_REGF  : std_logic := '0';
  constant FORWARDE_REGF : std_logic_vector(1 downto 0):="00";
  constant FORWARDE_ALU : std_logic_vector(1 downto 0):= "10";
  constant FORWARDE_WB : std_logic_vector(1 downto 0):="01";
  constant USERPROGRAM_BEGIN:std_logic_vector(15 downto 0):="0100000000000000";
  constant USERPROGRAM_END: std_logic_vector(15 downto 0):= "1000000000000000";
  
  
  --about mem--
  constant HIGH_Z : std_logic_vector(15 downto 0) := "ZZZZZZZZZZZZZZZZ";
  constant MEMCONTROL_READ : std_logic_vector(1 downto 0):= "01";
  constant MEMCONTROL_WRITE: std_logic_vector(1 downto 0):= "10";
  constant MEMCONTROL_DISABLE: std_logic_vector(1 downto 0):= "11";
  constant RAM1_ADDR_BEGIN : std_logic_vector(15 downto 0) := "1000000000000000";
  
  -- about serial port --
  constant PORT_STATUS : std_logic_vector(15 downto 0) := "1011111100000001"; -- BF01
  constant PORT_DATA : std_logic_vector(15 downto 0) := "1011111100000000"; -- BF01
  
  type control_signals is
  record
    ALU_Op: STD_LOGIC_VECTOR(3 downto 0);
    --two read address to register files
    REGF_A: STD_LOGIC_VECTOR(3 downto 0);
    REGF_B: STD_LOGIC_VECTOR(3 downto 0);
    --immediate number after extend
    Imm: STD_LOGIC_VECTOR(15 downto 0);
    --ALU_B from immediate number or register files
    ALU_B_Src: STD_LOGIC;
    --MEM control signals
    MEMControl: STD_LOGIC_VECTOR(1 downto 0);
    --need to write back to register files or not
    RegWrite : STD_LOGIC;
    --which register to write data
    RegWrite_Addr: STD_LOGIC_VECTOR(3 downto 0);
    --write data from ALU result or MEM
    MemtoReg: STD_LOGIC;
    --jump or branch control signals
    JumpType: STD_LOGIC_VECTOR(2 downto 0);
  end record;
  function generate_control(
    ALU_OP: in STD_LOGIC_VECTOR(3 downto 0);
    REGF_A: in STD_LOGIC_VECTOR(3 downto 0);
    REGF_B: in STD_LOGIC_VECTOR(3 downto 0);
    Imm: in STD_LOGIC_VECTOR(15 downto 0);
    ALU_B_Src: in STD_LOGIC;
    MEMControl: in STD_LOGIC_VECTOR(1 downto 0);
    RegWrite: in STD_LOGIC;
    RegWrite_Addr: in STD_LOGIC_VECTOR(3 downto 0);
    MemtoReg: in STD_LOGIC;
    JumpType: in STD_LOGIC_VECTOR(2 downto 0)
  ) return control_signals;
end common;
package body common is
  function generate_control(
    ALU_OP: in STD_LOGIC_VECTOR(3 downto 0);
    REGF_A: in STD_LOGIC_VECTOR(3 downto 0);
    REGF_B: in STD_LOGIC_VECTOR(3 downto 0);
    Imm: in STD_LOGIC_VECTOR(15 downto 0);
    ALU_B_Src: in STD_LOGIC;
    MEMControl: in STD_LOGIC_VECTOR(1 downto 0);
    RegWrite: in STD_LOGIC;
    RegWrite_Addr: in STD_LOGIC_VECTOR(3 downto 0);
    MemtoReg: in STD_LOGIC;
    JumpType: in STD_LOGIC_VECTOR(2 downto 0)
  ) return control_signals is
    variable tmp: control_signals;
  begin
    tmp.ALU_OP := ALU_OP;
    tmp.REGF_A := REGF_A;
    tmp.REGF_B := REGF_B;
    tmp.Imm := Imm;
    tmp.ALU_B_Src := ALU_B_Src;
    tmp.MEMControl := MEMControl;
    tmp.RegWrite := RegWrite;
    tmp.RegWrite_Addr:= RegWrite_Addr;
    tmp.MemtoReg := MemtoReg;
    tmp.JumpType := JumpType;
    return tmp;
  end generate_control;
   
end common;
