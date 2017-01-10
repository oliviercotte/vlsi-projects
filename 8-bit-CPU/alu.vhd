--=======================================================================================
-- TITLE : alu
-- DESCRIPTION : Perform various arithmetic and logic operations.
-- An operand is presented on each of the two in_oper_a and in_oper_b inputs and,
-- based on an operation code given on in_op, an operation is performed, and the corresponding
-- result is provided on out_result in a purely combinatorial manner.
-- FILE : alu.vhd
--=======================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.opcodes.all;

entity alu is
port (
	clk:   in std_logic;
	rst_n: in std_logic;
	
	in_op: in std_logic_vector(2 downto 0);
	
	in_oper_a: in std_logic_vector(7 downto 0);
	in_oper_b: in std_logic_vector(7 downto 0);	
	
	out_flag_c: out std_logic;
	out_flag_n: out std_logic;
	out_flag_z: out std_logic;
	
	out_result: out std_logic_vector(7 downto 0)
);
end alu;

architecture alu_arch of alu is
signal flag_c, flag_n, flag_z: std_logic := '0';

begin
	process(clk, rst_n)
	begin
		if rst_n = '0' then
			out_flag_c <= '0';
			out_flag_n <= '0';
			out_flag_z <= '0';
		elsif rising_edge(clk) then
			-- When the operation code is alu_nop or is not specified, the flags are not affected .
			if in_op = ALU_ADD or in_op = ALU_AND or in_op = ALU_NOT or in_op = ALU_OR or in_op = ALU_SUB or in_op = ALU_XOR then
				if in_op = ALU_ADD or in_op = ALU_SUB then
					out_flag_c <= flag_c;
				end if;
				out_flag_n <= flag_n;
				out_flag_z <= flag_z;
			end if;	
		end if;	
	end process;
	
	process(in_op, in_oper_a, in_oper_b)
	variable Temp: std_logic_vector(8 downto 0) := (others => '0');
	begin	
		case in_op is
			when ALU_ADD =>
				Temp := std_logic_vector(UNSIGNED('0' & in_oper_a) + UNSIGNED('0' & in_oper_b));
			
			when ALU_AND =>
				Temp := std_logic_vector(resize(unsigned(in_oper_a), Temp'length) and resize(unsigned(in_oper_b), Temp'length));
		
			when ALU_NOT =>
				Temp := not std_logic_vector(resize(unsigned(in_oper_a), Temp'length));
			
			when ALU_OR =>
				Temp := std_logic_vector(resize(unsigned(in_oper_a), Temp'length) or resize(unsigned(in_oper_b), Temp'length));
		
			when ALU_SUB =>
				Temp := std_logic_vector(UNSIGNED('0' & in_oper_a) - UNSIGNED('0' & in_oper_b));
			
			when ALU_XOR =>
				Temp := std_logic_vector(resize(unsigned(in_oper_a), Temp'length) xor resize(unsigned(in_oper_b), Temp'length));
			when others => -- No operation (ALU_NOP or otherwise)
		end case;
		
		flag_c <= Temp(8);
		flag_n <= Temp(7);
		if Temp(7 downto 0) = "00000000" then
			flag_z <= '1';
		else
			flag_z <= '0';
		end if;
		out_result <= Temp(7 downto 0);			
	end process;
end alu_arch;