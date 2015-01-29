library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.common.ALL;

entity controller is
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
end controller;

architecture behavioral of controller is
  signal IMM_5: std_logic_vector(4 downto 0);
  signal IMM_12: std_logic_vector(11 downto 0);
  signal IMM_8: std_logic_vector(7 downto 0);
  signal IMM_11: std_logic_vector(10 downto 0);
  signal IMM_13: std_logic_vector(12 downto 0);
begin
  process(CTRL_Inst)
    variable cs: control_signals;
  begin
    case (CTRL_Inst(15 downto 11)) is
      when INST_NOP          =>
        cs:=generate_control(ALUOP_NULL, REGF_NULL, REGF_NULL, ZERO, ALU_B_SRC_REGF, 
                             MEMCONTROL_DISABLE, REGWRITE_NO, REGF_NULL, MEMTOREG_ALU, 
                             JUMPTYPE_NOJUMP);
      when INST_B            =>
        IMM_5 <= (others=>CTRL_Inst(10));
        cs:=generate_control(ALUOP_ADD, REGF_PC, REGF_NULL, IMM_5&CTRL_Inst(10 downto 0),
                             ALU_B_SRC_IMM, MEMCONTROL_DISABLE, REGWRITE_NO, REGF_NULL, MEMTOREG_ALU,
                             JUMPTYPE_JUMP);
      when INST_BEQZ         =>
        IMM_8 <= (others=>CTRL_Inst(7));
        cs:=generate_control(ALUOP_ADD, REGF_PC, "0"&CTRL_Inst(10 downto 8), IMM_8&CTRL_Inst(7 downto 0),
                             ALU_B_SRC_IMM, MEMCONTROL_DISABLE, REGWRITE_NO, REGF_NULL, MEMTOREG_ALU,
                             JUMPTYPE_EQZ);
      when INST_BNEZ         =>
        IMM_8 <= (others=>CTRL_Inst(7));
        cs:=generate_control(ALUOP_ADD, REGF_PC, "0"&CTRL_Inst(10 downto 8), IMM_8&CTRL_Inst(7 downto 0),
                             ALU_B_SRC_IMM, MEMCONTROL_DISABLE, REGWRITE_NO, REGF_NULL, MEMTOREG_ALU,
                             JUMPTYPE_NEZ);
      when INST_ADDIU3       =>
        IMM_12 <= (others => CTRL_Inst(3));
        cs:=generate_control(ALUOP_ADD, "0"&CTRL_Inst(10 downto 8), REGF_NULL, IMM_12&CTRL_Inst(3 downto 0), 
                             ALU_B_SRC_IMM, MEMCONTROL_DISABLE, REGWRITE_YES, "0"&CTRL_Inst(7 downto 5),MEMTOREG_ALU, 
                             JUMPTYPE_NOJUMP);
      when INST_ADDIU        =>
        IMM_8 <= (others => CTRL_Inst(7));
        cs:=generate_control(ALUOP_ADD, "0"&CTRL_Inst(10 downto 8), REGF_NULL, IMM_8&CTRL_Inst(7 downto 0),
                             ALU_B_SRC_IMM, MEMCONTROL_DISABLE, REGWRITE_YES, "0"&CTRL_Inst(10 downto 8),MEMTOREG_ALU, 
                             JUMPTYPE_NOJUMP);
      when INST_LI           =>
        IMM_8 <= (others => '0');
        cs:=generate_control(ALUOP_ADD, REGF_NULL, REGF_NULL, IMM_8&CTRL_Inst(7 downto 0),
                             ALU_B_SRC_IMM, MEMCONTROL_DISABLE, REGWRITE_YES, "0"&CTRL_Inst(10 downto 8),MEMTOREG_ALU, 
                             JUMPTYPE_NOJUMP);
      when INST_LW_SP        =>
        IMM_8 <= (others => CTRL_Inst(7));
        cs:=generate_control(ALUOP_ADD, REGF_SP, REGF_NULL, IMM_8&CTRL_Inst(7 downto 0),
                             ALU_B_SRC_IMM, MEMCONTROL_READ, REGWRITE_YES, "0"&CTRL_Inst(10 downto 8), MEMTOREG_MEM,
                             JUMPTYPE_NOJUMP);
      when INST_LW           =>
        IMM_11 <= (others => CTRL_Inst(4));
        cs:=generate_control(ALUOP_ADD, "0"&CTRL_Inst(10 downto 8), REGF_NULL, IMM_11&CTRL_Inst(4 downto 0),
                             ALU_B_SRC_IMM, MEMCONTROL_READ, REGWRITE_YES, "0"&CTRL_Inst(7 downto 5), MEMTOREG_MEM,
                             JUMPTYPE_NOJUMP);
      when INST_SW_SP        =>
        IMM_8 <= (others=>CTRL_Inst(7));
        cs:=generate_control(ALUOP_ADD, REGF_SP, "0"&CTRL_Inst(10 downto 8), IMM_8&CTRL_Inst(7 downto 0),
                             ALU_B_SRC_IMM, MEMCONTROL_WRITE, REGWRITE_NO, REGF_NULL, MEMTOREG_ALU,
                             JUMPTYPE_NOJUMP);
        
      when INST_SW           =>
        IMM_11 <= (others=>CTRL_Inst(4));
        cs:=generate_control(ALUOP_ADD, "0"&CTRL_Inst(10 downto 8), "0"&CTRL_Inst(7 downto 5), IMM_11&CTRL_Inst(4 downto 0),
                             ALU_B_SRC_IMM, MEMCONTROL_WRITE, REGWRITE_NO, REGF_NULL, MEMTOREG_ALU,
                             JUMPTYPE_NOJUMP);
      -- multiple instructions--
      when INST_SHIFT_M      =>
        case CTRL_Inst(1 downto 0) is
          when INST_FUNC_SLL =>
            IMM_13 <= (others=>'0');
            cs:=generate_control(ALUOP_SLL, "0"&CTRL_Inst(7 downto 5), REGF_NULL, IMM_13&CTRL_Inst(4 downto 2),
                                 ALU_B_SRC_IMM, MEMCONTROL_DISABLE, REGWRITE_YES, "0"&CTRL_Inst(10 downto 8), MEMTOREG_ALU,
                                 JUMPTYPE_NOJUMP);
          when INST_FUNC_SRA =>
            IMM_13 <= (others=>'0');
            cs:=generate_control(ALUOP_SRA, "0"&CTRL_Inst(7 downto 5), REGF_NULL, IMM_13&CTRL_Inst(4 downto 2),
                                 ALU_B_SRC_IMM, MEMCONTROL_DISABLE, REGWRITE_YES, "0"&CTRL_Inst(10 downto 8), MEMTOREG_ALU,
                                 JUMPTYPE_NOJUMP);
          when others        =>
            null;
        end case;
      when INST_BRANCH_M     =>
        case CTRL_Inst(10 downto 8) is
          when INST_FUNC_ADDSP =>
            IMM_8 <= (others=>CTRL_Inst(7));
            cs:=generate_control(ALUOP_ADD, REGF_SP, REGF_NULL, IMM_8&CTRL_Inst(7 downto 0),
                                 ALU_B_SRC_IMM, MEMCONTROL_DISABLE, REGWRITE_YES, REGF_SP, MEMTOREG_ALU,
                                 JUMPTYPE_NOJUMP);
          when INST_FUNC_BTEQZ =>
            IMM_8 <= (others=>CTRL_Inst(7));
            cs:=generate_control(ALUOP_ADD, REGF_PC, REGF_T, IMM_8&CTRL_Inst(7 downto 0),
                                 ALU_B_SRC_IMM, MEMCONTROL_DISABLE, REGWRITE_NO, REGF_NULL, MEMTOREG_ALU,
                                 JUMPTYPE_TEQZ);
          when INST_FUNC_BTNEZ =>
            IMM_8 <= (others=>CTRL_Inst(7));
            cs:=generate_control(ALUOP_ADD, REGF_PC, REGF_T, IMM_8&CTRL_Inst(7 downto 0),
                                 ALU_B_SRC_IMM, MEMCONTROL_DISABLE, REGWRITE_NO, REGF_NULL, MEMTOREG_ALU,
                                 JUMPTYPE_TNEZ);
          when INST_FUNC_MTSP  =>
            cs:=generate_control(ALUOP_ADD, "0"&CTRL_Inst(7 downto 5), REGF_NULL, ZERO,
                                 ALU_B_SRC_IMM, MEMCONTROL_DISABLE, REGWRITE_YES, REGF_SP, MEMTOREG_ALU,
                                 JUMPTYPE_NOJUMP);
          when others          =>
            null;
        end case;
      when INST_OPU_M        =>
        case CTRL_Inst(1 downto 0) is
          when INST_FUNC_ADDU =>
            cs:=generate_control(ALUOP_ADD, "0"&CTRL_Inst(10 downto 8), "0"&CTRL_Inst(7 downto 5), ZERO,
                                 ALU_B_SRC_REGF, MEMCONTROL_DISABLE, REGWRITE_YES, "0"&CTRL_Inst(4 downto 2), MEMTOREG_ALU,
                                 JUMPTYPE_NOJUMP);
          when INST_FUNC_SUBU =>
            cs:=generate_control(ALUOP_SUB, "0"&CTRL_Inst(10 downto 8), "0"&CTRL_Inst(7 downto 5), ZERO,
                                 ALU_B_SRC_REGF, MEMCONTROL_DISABLE, REGWRITE_YES, "0"&CTRL_Inst(4 downto 2), MEMTOREG_ALU,
                                 JUMPTYPE_NOJUMP);
          when others =>
            null;
        end case;
      when INST_LOGICJUMP_M  =>
        case CTRL_Inst(4 downto 0) is
          when INST_FUNC_AND =>
            cs:=generate_control(ALUOP_AND, "0"&CTRL_Inst(10 downto 8), "0"&CTRL_Inst(7 downto 5), ZERO,
                                 ALU_B_SRC_REGF, MEMCONTROL_DISABLE, REGWRITE_YES, "0"&CTRL_Inst(10 downto 8), MEMTOREG_ALU,
                                 JUMPTYPE_NOJUMP);
          when INST_FUNC_CMP =>
            cs:=generate_control(ALUOP_CMP, "0"&CTRL_Inst(10 downto 8), "0"&CTRL_Inst(7 downto 5), ZERO,
                                 ALU_B_SRC_REGF, MEMCONTROL_DISABLE, REGWRITE_YES, REGF_T, MEMTOREG_ALU,
                                 JUMPTYPE_NOJUMP);
          when INST_FUNC_NOT =>
            cs:=generate_control(ALUOP_NOT, "0"&CTRL_Inst(7 downto 5),  REGF_NULL, ZERO,
                                 ALU_B_SRC_REGF, MEMCONTROL_DISABLE, REGWRITE_YES, "0"&CTRL_Inst(10 downto 8), MEMTOREG_ALU,
                                 JUMPTYPE_NOJUMP);
          when INST_FUNC_OR =>
            cs:=generate_control(ALUOP_OR, "0"&CTRL_Inst(10 downto 8), "0"&CTRL_Inst(7 downto 5), ZERO,
                                 ALU_B_SRC_REGF, MEMCONTROL_DISABLE, REGWRITE_YES, "0"&CTRL_Inst(10 downto 8), MEMTOREG_ALU,
                                 JUMPTYPE_NOJUMP);
          when INST_FUNC_SLTU =>
            cs:=generate_control(ALUOP_SUBU, "0"&CTRL_Inst(10 downto 8), "0"&CTRL_Inst(7 downto 5), ZERO,
                                 ALU_B_SRC_REGF, MEMCONTROL_DISABLE, REGWRITE_YES, REGF_T, MEMTOREG_ALU,
                                 JUMPTYPE_NOJUMP);
          when INST_FUNC_JUMPS=>
            case CTRL_Inst(7 downto 5) is
              when INST_FUNC_JALR =>---???
                cs:=generate_control(ALUOP_ADD, REGF_PC, "0"&CTRL_Inst(10 downto 8), ZERO,
                                     ALU_B_SRC_IMM, MEMCONTROL_DISABLE, REGWRITE_YES, REGF_RA, MEMTOREG_ALU,
                                     JUMPTYPE_JALR);
              when INST_FUNC_JR =>
                cs:=generate_control(ALUOP_ADD, "0"&CTRL_Inst(10 downto 8), REGF_NULL, ZERO,
                                     ALU_B_SRC_IMM, MEMCONTROL_DISABLE, REGWRITE_NO, REGF_NULL, MEMTOREG_ALU,
                                     JUMPTYPE_JUMP);
              when INST_FUNC_JRRA =>
                cs:=generate_control(ALUOP_ADD, REGF_RA, REGF_NULL, ZERO,
                                     ALU_B_SRC_IMM, MEMCONTROL_DISABLE, REGWRITE_NO, REGF_NULL, MEMTOREG_ALU,
                                     JUMPTYPE_JUMP);
              when INST_FUNC_MFPC =>
                cs:=generate_control(ALUOP_ADD, REGF_PC, REGF_NULL, ZERO,
                                     ALU_B_SRC_IMM, MEMCONTROL_DISABLE, REGWRITE_YES, "0"&CTRL_Inst(10 downto 8), MEMTOREG_ALU,
                                     JUMPTYPE_NOJUMP);
              when others=>
                null;
            end case;
          when others =>
            null;
        end case;
      when INST_IH_M         =>
        case CTRL_Inst(0) is
          when INST_FUNC_MFIH =>
            cs:=generate_control(ALUOP_ADD, REGF_IH, REGF_NULL, ZERO,
                                 ALU_B_SRC_IMM, MEMCONTROL_DISABLE, REGWRITE_YES, "0"&CTRL_Inst(10 downto 8), MEMTOREG_ALU,
                                 JUMPTYPE_NOJUMP);
          when INST_FUNC_MTIH =>
            cs:=generate_control(ALUOP_ADD, "0"&CTRL_Inst(10 downto 8), REGF_NULL, ZERO,
                                 ALU_B_SRC_IMM, MEMCONTROL_DISABLE, REGWRITE_YES, REGF_IH, MEMTOREG_ALU,
                                 JUMPTYPE_NOJUMP);
          when others =>
            null;
        end case;
      when others            => null;
    end case;
    ALU_Op <= cs.ALU_Op;
    REGF_A <= cs.REGF_A;
    REGF_B <= cs.REGF_B;
    Imm <= cs.Imm;
    ALU_B_Src <= cs.ALU_B_Src;
    MEMControl <= cs.MEMControl;
    RegWrite <= cs.RegWrite;
    RegWrite_Addr <= cs.RegWrite_Addr;
    MemtoReg <= cs.MemtoReg;
    JumpType <= cs.JumpType;
  end process;
  with CTRL_Inst(15 downto 11) select
    IS_SW <= '1' when INST_SW,
             '0' when others;
end behavioral;
