--=======================================================================================
-- TITLE : instruction_decoder_tb
-- DESCRIPTION : For each opcodes, the test bench ensures the validity its controls signals 
-- and output.
-- FILE : instruction_decoder_tb.vhd
--=======================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.opcodes.all;

entity instruction_decoder_tb is
end instruction_decoder_tb;	

architecture tb of instruction_decoder_tb is

component instruction_decoder
	port (
		in_op : in std_logic_vector(7 downto 0);
		
		out_alu_op 	: out std_logic_vector(2 downto 0);
		
		out_imm 	: out std_logic;
		out_w 		: out std_logic;
		out_pop1 	: out std_logic;  
		out_pop2 	: out std_logic;  
		out_push 	: out std_logic;  
		out_get 	: out std_logic;  
		out_put 	: out std_logic  
	);  
end component;

constant CLK_PERIOD : time := 10 ns;

signal in_op: std_logic_vector(7 downto 0) := (others => '0');
		
signal out_alu_op: std_logic_vector(2 downto 0);
		
signal out_imm: std_logic;
signal out_w: std_logic;
signal out_pop1: std_logic;  
signal out_pop2: std_logic;  
signal out_push: std_logic;  
signal out_get: std_logic;  
signal out_put: std_logic;  
				
begin	
	UUT : instruction_decoder
	port map (
		in_op => in_op,
		out_alu_op => out_alu_op,
		out_imm  => out_imm,
		out_w => out_w,
		out_pop1 => out_pop1,
		out_pop2 => out_pop2,
		out_push => out_push,
		out_get => out_get,
		out_put => out_put
	);
	
	process
	begin
		-- We test every opcodes againts its controls signals and output.
		in_op <= OP_ADD;
		wait for CLK_PERIOD;
		assert out_alu_op = ALU_ADD;
		assert out_imm 	= '0';
		assert out_w 	= '0';
		assert out_pop1 = '1';  
		assert out_pop2 = '1';  
		assert out_push = '1';
		assert out_get 	= '0';  
		assert out_put 	= '0';
		
		in_op <= OP_AND;
		wait for CLK_PERIOD;
		assert out_alu_op = ALU_AND;
		assert out_imm 	= '0';
		assert out_w 	= '0';
		assert out_pop1 = '1';  
		assert out_pop2 = '1';  
		assert out_push = '1';
		assert out_get 	= '0';  
		assert out_put 	= '0';

		in_op <= OP_OR;
		wait for CLK_PERIOD;
		assert out_alu_op = ALU_OR;
		assert out_imm 	= '0';
		assert out_w 	= '0';
		assert out_pop1 = '1';  
		assert out_pop2 = '1';  
		assert out_push = '1';
		assert out_get 	= '0';  
		assert out_put 	= '0';

		in_op <= OP_SUB;
		wait for CLK_PERIOD;
		assert out_alu_op = ALU_SUB;
		assert out_imm 	= '0';
		assert out_w 	= '0';
		assert out_pop1 = '1';  
		assert out_pop2 = '1';  
		assert out_push = '1'; 
		assert out_get 	= '0';  
		assert out_put 	= '0';

		in_op <= OP_XOR;
		wait for CLK_PERIOD;
		assert out_alu_op = ALU_XOR;
		assert out_imm 	= '0';
		assert out_w 	= '0';
		assert out_pop1 = '1';  
		assert out_pop2 = '1';  
		assert out_push = '1';
		assert out_get 	= '0';  
		assert out_put 	= '0';

		in_op <= OP_CMP;
		wait for CLK_PERIOD;
		assert out_alu_op = ALU_SUB;
		assert out_imm 	= '0';
		assert out_w 	= '0';
		assert out_pop1 = '1';  
		assert out_pop2 = '1';
		assert out_push = '0';  
		assert out_get 	= '0';  
		assert out_put 	= '0';

		in_op <= OP_NOT;
		wait for CLK_PERIOD;
		assert out_alu_op = ALU_NOT;
		assert out_imm 	= '0';
		assert out_w 	= '0';
		assert out_pop1 = '1';
		assert out_pop2 = '0'; 
		assert out_push = '1';
		assert out_get 	= '0';  
		assert out_put 	= '0';
		
		in_op <= OP_ADD_W;
		wait for CLK_PERIOD;
		assert out_alu_op = "000";
		assert out_imm 	= '0';
		assert out_w 	= '0';
		assert out_pop1 = '1'; 
		assert out_pop2 = '0';  
		assert out_push = '0';  
		assert out_get 	= '0';  
		assert out_put 	= '0'; 
			
		in_op <= OP_CONST;
		wait for CLK_PERIOD;
		assert out_alu_op = "000";
		assert out_imm 	= '1';
		assert out_w 	= '0';
		assert out_pop1 = '0';
		assert out_pop2 = '0';  
		assert out_push = '1';   
		assert out_get 	= '0';  
		assert out_put 	= '0'; 
				
		in_op <= OP_CONST_W;
		wait for CLK_PERIOD;
		assert out_alu_op = "000";
		assert out_imm 	= '0';
		assert out_w 	= '1';
		assert out_pop1 = '0';  
		assert out_pop2 = '0';  
		assert out_push = '0';  
		assert out_get 	= '0';  
		assert out_put 	= '0'; 
			
		in_op <= OP_POP_WH;
		wait for CLK_PERIOD;
		assert out_alu_op = "000";
		assert out_imm 	= '0';
		assert out_w 	= '0';
		assert out_pop1 = '1'; 
		assert out_pop2 = '0';  
		assert out_push = '0';  
		assert out_get 	= '0';  
		assert out_put 	= '0'; 
			
		in_op <= OP_POP_WL;
		wait for CLK_PERIOD;
		assert out_alu_op = "000";
		assert out_imm 	= '0';
		assert out_w 	= '0';
		assert out_pop1 = '1'; 
		assert out_pop2 = '0';  
		assert out_push = '0';  
		assert out_get 	= '0';  
		assert out_put 	= '0'; 
			
		in_op <= OP_PUSH_WH;
		wait for CLK_PERIOD;
		assert out_alu_op = "000";
		assert out_imm 	= '0';
		assert out_w 	= '0';
		assert out_pop1 = '0';  
		assert out_pop2 = '0';  
		assert out_push = '1';  
		assert out_get 	= '0';  
		assert out_put 	= '0'; 
			
		in_op <= OP_PUSH_WL;
		wait for CLK_PERIOD;
		assert out_alu_op = "000";
		assert out_imm 	= '0';
		assert out_w 	= '0';
		assert out_pop1 = '0';  
		assert out_pop2 = '0';  
		assert out_push = '1';  
		assert out_get 	= '0';  
		assert out_put 	= '0'; 
				
		in_op <= OP_GET;
		wait for CLK_PERIOD;
		assert out_alu_op = "000";
		assert out_imm 	= '1';
		assert out_w 	= '0';
		assert out_pop1 = '0';  
		assert out_pop2 = '0';  
		assert out_push = '1';  
		assert out_get 	= '1'; 
		assert out_put 	= '0'; 
				
		in_op <= OP_PUT;
		wait for CLK_PERIOD;
		assert out_alu_op = "000";
		assert out_imm 	= '1';
		assert out_w 	= '0';
		assert out_pop1 = '1';
		assert out_pop2 = '0';  
		assert out_push = '0';  
		assert out_get 	= '0';  
		assert out_put 	= '1'; 
				
		in_op <= OP_JMP;
		wait for CLK_PERIOD;
		assert out_alu_op = "000";
		assert out_imm 	= '1';
		assert out_w 	= '0';
		assert out_pop1 = '0';  
		assert out_pop2 = '0';  
		assert out_push = '0';  
		assert out_get 	= '0';  
		assert out_put 	= '0';
		
		in_op <= OP_BEQ;
		wait for CLK_PERIOD;
		assert out_alu_op = "000";
		assert out_imm 	= '1';
		assert out_w 	= '0';
		assert out_pop1 = '0';  
		assert out_pop2 = '0';  
		assert out_push = '0';  
		assert out_get 	= '0';  
		assert out_put 	= '0';
		
		in_op <= OP_BNE;
		wait for CLK_PERIOD;
		assert out_alu_op = "000";
		assert out_imm 	= '1';
		assert out_w 	= '0';
		assert out_pop1 = '0';  
		assert out_pop2 = '0';  
		assert out_push = '0';  
		assert out_get 	= '0';  
		assert out_put 	= '0';
		
		in_op <= OP_BNEG;
		wait for CLK_PERIOD;
		assert out_alu_op = "000";
		assert out_imm 	= '1';
		assert out_w 	= '0';
		assert out_pop1 = '0';  
		assert out_pop2 = '0';  
		assert out_push = '0';  
		assert out_get 	= '0';  
		assert out_put 	= '0';
		
		in_op <= OP_BC;
		wait for CLK_PERIOD;
		assert out_alu_op = "000";
		assert out_imm 	= '1';
		assert out_w 	= '0';
		assert out_pop1 = '0';  
		assert out_pop2 = '0';  
		assert out_push = '0';  
		assert out_get 	= '0';  
		assert out_put 	= '0';
		
		in_op <= OP_NOP;
		wait for CLK_PERIOD;
		assert out_alu_op = "000";
		assert out_imm 	= '0';
		assert out_w 	= '0';
		assert out_pop1 = '0';  
		assert out_pop2 = '0';  
		assert out_push = '0';  
		assert out_get 	= '0';  
		assert out_put 	= '0';
		
		in_op <= OP_W_TO_PC;
		wait for CLK_PERIOD;
		assert out_alu_op = "000";
		assert out_imm 	= '0';
		assert out_w 	= '0';
		assert out_pop1 = '0';  
		assert out_pop2 = '0';  
		assert out_push = '0';  
		assert out_get 	= '0';  
		assert out_put 	= '0';
		
		in_op <= OP_W_TO_SP;
		wait for CLK_PERIOD;
		assert out_alu_op = "000";
		assert out_imm 	= '0';
		assert out_w 	= '0';
		assert out_pop1 = '0';  
		assert out_pop2 = '0';  
		assert out_push = '0';  
		assert out_get 	= '0';  
		assert out_put 	= '0';
		
		in_op <= OP_W_TO_BP;
		wait for CLK_PERIOD;
		assert out_alu_op = "000";
		assert out_imm 	= '0';
		assert out_w 	= '0';
		assert out_pop1 = '0';  
		assert out_pop2 = '0';  
		assert out_push = '0';  
		assert out_get 	= '0';  
		assert out_put 	= '0';
		
		in_op <= OP_PC_TO_W;
		wait for CLK_PERIOD;
		assert out_alu_op = "000";
		assert out_imm 	= '0';
		assert out_w 	= '0';
		assert out_pop1 = '0';  
		assert out_pop2 = '0';  
		assert out_push = '0';  
		assert out_get 	= '0';  
		assert out_put 	= '0';
		
		in_op <= OP_SP_TO_W;
		wait for CLK_PERIOD;
		assert out_alu_op = "000";
		assert out_imm 	= '0';
		assert out_w 	= '0';
		assert out_pop1 = '0';  
		assert out_pop2 = '0';  
		assert out_push = '0';  
		assert out_get 	= '0';  
		assert out_put 	= '0';
		
		in_op <= OP_BP_TO_W;
		wait for CLK_PERIOD;
		assert out_alu_op = "000";
		assert out_imm 	= '0';
		assert out_w 	= '0';
		assert out_pop1 = '0';  
		assert out_pop2 = '0';  
		assert out_push = '0';  
		assert out_get 	= '0';  
		assert out_put 	= '0';
		
		report "End simulation" severity failure;
	end process;	
end tb;
