library ieee;
use ieee.std_logic_1164.all;

package opcodes is
	-- ALU operation codes
	constant ALU_NOP:    std_logic_vector(2 downto 0) := "000";
	constant ALU_ADD:    std_logic_vector(2 downto 0) := "001";
	constant ALU_AND:    std_logic_vector(2 downto 0) := "010";
	constant ALU_NOT:    std_logic_vector(2 downto 0) := "100";
	constant ALU_OR:     std_logic_vector(2 downto 0) := "101";
	constant ALU_SUB:    std_logic_vector(2 downto 0) := "110";
	constant ALU_XOR:    std_logic_vector(2 downto 0) := "111";
	
	-- prefix of ALU instructions
	constant ALU_PREFIX: std_logic_vector(3 downto 0) := "0001";
	
	-- no-operation (00)
	constant OP_NOP:     std_logic_vector(7 downto 0) := x"00";
	
	-- arithmetic and logic operations (1x)
	constant OP_ADD:     std_logic_vector(7 downto 0) := x"11";
	constant OP_AND:     std_logic_vector(7 downto 0) := x"12";
	constant OP_CMP:     std_logic_vector(7 downto 0) := x"1e";
	constant OP_NOT:     std_logic_vector(7 downto 0) := x"14";
	constant OP_OR:      std_logic_vector(7 downto 0) := x"15";
	constant OP_SUB:     std_logic_vector(7 downto 0) := x"16";
	constant OP_XOR:     std_logic_vector(7 downto 0) := x"17";
	
	constant OP_ADD_W:   std_logic_vector(7 downto 0) := x"21";
	
	-- constants (3x)
	constant OP_CONST:   std_logic_vector(7 downto 0) := x"31";
	constant OP_CONST_W: std_logic_vector(7 downto 0) := x"32";
	
	constant OP_PUSH_WH: std_logic_vector(7 downto 0) := x"33";
	constant OP_PUSH_WL: std_logic_vector(7 downto 0) := x"34";
	constant OP_POP_WH:  std_logic_vector(7 downto 0) := x"35";
	constant OP_POP_WL:  std_logic_vector(7 downto 0) := x"36";
	
	constant OP_W_TO_PC: std_logic_vector(7 downto 0) := x"38";
	constant OP_W_TO_SP: std_logic_vector(7 downto 0) := x"39";
	constant OP_W_TO_BP: std_logic_vector(7 downto 0) := x"3a";
	
	constant OP_PC_TO_W: std_logic_vector(7 downto 0) := x"3c";
	constant OP_SP_TO_W: std_logic_vector(7 downto 0) := x"3d";
	constant OP_BP_TO_W: std_logic_vector(7 downto 0) := x"3e";
	
	-- load and store operations (4x)
	constant OP_GET:     std_logic_vector(7 downto 0) := x"41";
	constant OP_PUT:     std_logic_vector(7 downto 0) := x"43";
	
	-- jump and branch operations (8x)
	constant OP_JMP:     std_logic_vector(7 downto 0) := x"81";
	constant OP_BEQ:     std_logic_vector(7 downto 0) := x"82";
	constant OP_BNE:     std_logic_vector(7 downto 0) := x"83";
	constant OP_BNEG:    std_logic_vector(7 downto 0) := x"84";
	constant OP_BC:      std_logic_vector(7 downto 0) := x"86";	
	
end package;
