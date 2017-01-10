--=======================================================================================
-- TITLE : instruction_decoder
-- DESCRIPTION : The instruction decoder generates the operation code of the arithmetic
-- logic unit and some control signals based on the operation of the instruction code.
-- FILE : instruction_decoder.vhd
--=======================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.opcodes.all;

entity instruction_decoder is
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
end instruction_decoder;

architecture instruction_decoder_arch of instruction_decoder is
begin
	process(in_op)
	begin
		out_imm 	<= '0';
		out_w 		<= '0';
		out_pop1 	<= '0';  
		out_pop2 	<= '0';  
		out_push 	<= '0';  
		out_get 	<= '0';  
		out_put 	<= '0'; 
		
		out_alu_op <= "000";
	
		case in_op is
			when OP_ADD | OP_AND | OP_OR | OP_SUB | OP_XOR =>
				out_pop1 	<= '1';  
				out_pop2 	<= '1';  
				out_push 	<= '1';
				out_alu_op	<= in_op(2 downto 0);
				
			when OP_CMP =>
				out_pop1 	<= '1';  
				out_pop2 	<= '1';
				out_alu_op	<= in_op(2 downto 0);
				
			when OP_NOT =>
				out_pop1 	<= '1';  
				out_push 	<= '1';
				out_alu_op	<= in_op(2 downto 0);
				
			when OP_ADD_W =>
				out_pop1 	<= '1';
			
			when OP_CONST =>
				out_imm 	<= '1';
				out_push 	<= '1';
				
			when OP_CONST_W =>
				out_w 		<= '1';
			
			when OP_POP_WH | OP_POP_WL =>
				out_pop1 	<= '1';
			
			when OP_PUSH_WH | OP_PUSH_WL =>
				out_push 	<= '1';
			
			when OP_GET =>
				out_imm 	<= '1';
				out_push 	<= '1';  
				out_get 	<= '1';
				
			when OP_PUT =>
				out_imm 	<= '1';
				out_pop1 	<= '1';
				out_put 	<= '1';
				
			when OP_JMP | OP_BEQ | OP_BNE | OP_BNEG | OP_BC =>
				out_imm 	<= '1'; 
			
			when others =>
				out_imm 	<= '0';
				out_w 		<= '0';
				out_pop1 	<= '0';  
				out_pop2 	<= '0';  
				out_push 	<= '0';  
				out_get 	<= '0';  
				out_put 	<= '0';		
		end case;
	end process;	
end instruction_decoder_arch;
	