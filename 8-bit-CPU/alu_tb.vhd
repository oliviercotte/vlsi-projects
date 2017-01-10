--=======================================================================================
-- TITLE : alu_tb
-- DESCRIPTION : Black box testing (Stress testing the alu).
-- For a certain input check if the opcode stand for the right operation,
-- check if the operation is done the right way
-- and check if the behavior is correct (update of the flag for the righ opcode).
-- FILE : alu_tb.vhd
--=======================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.opcodes.all;

entity alu_tb is
end alu_tb;

architecture tb of alu_tb is

component alu
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
end component;

constant CLK_PERIOD : time := 1 ns;

signal clk: std_logic := '0';
signal rst_n: std_logic := '1';
	
signal in_op: std_logic_vector(2 downto 0) := (others => '0');
	
signal in_oper_a: std_logic_vector(7 downto 0);
signal in_oper_b: std_logic_vector(7 downto 0);	
	
signal out_flag_c: std_logic;
signal out_flag_n: std_logic;
signal out_flag_z: std_logic;
	
signal out_result: std_logic_vector(7 downto 0);
	
begin
	clk <= not clk after CLK_PERIOD;
	
	UUT : alu
	port map(
		clk => clk,
		rst_n => rst_n,
		in_op => in_op,
		in_oper_a => in_oper_a,
		in_oper_b => in_oper_b,	
		out_flag_c => out_flag_c,
		out_flag_n => out_flag_n,
		out_flag_z => out_flag_z,
		out_result => out_result
	);
	
	process
	variable saved_c, saved_z, saved_n : std_logic;
	variable result_or, result_not, result_and, result_xor: std_logic_vector(7 downto 0);
	begin
		L1: for i in 0 to 2 ** 8 - 1 loop
			in_oper_a <= std_logic_vector(to_unsigned(i, in_oper_a'length));
			L2: for j in 0 to 2 ** 8 - 1 loop
				in_oper_b <= std_logic_vector(to_unsigned(j, in_oper_b'length));
				
				-- A+B, send operands and operation mode
				in_op <= ALU_ADD;
				wait until rising_edge(clk);
				
				-- We need one more cycle b/c the flags are registered.
				wait until rising_edge(clk);
				
				-- two unsigned numbers were added and the result is larger than "capacity" of register where it is saved.
				if out_flag_c = '1'  then
					assert i + j > 2 ** 8 - 1 severity failure;
				else
					assert unsigned(out_result) = unsigned(in_oper_a) + unsigned(in_oper_b) severity failure;
				end if;
				
				if out_flag_z = '1' then	
					assert signed(in_oper_a) + signed(in_oper_b) = 0 or unsigned(in_oper_a) - unsigned(in_oper_b) = 0 severity failure;
				else
					assert signed(in_oper_a) + signed(in_oper_b) /= 0 or unsigned(in_oper_a) - unsigned(in_oper_b) /= 0 severity failure;
				end if;
				
				if out_flag_n = '1' then
					assert signed(in_oper_a) + signed(in_oper_b) < 0 severity failure;
				else
					assert signed(in_oper_a) + signed(in_oper_b) >= 0 severity failure;
				end if;
				
				saved_c := out_flag_c;
				saved_z := out_flag_z;
				saved_n := out_flag_n;
				
				-- For the next two operation, flags should remain the same
				in_op <= ALU_NOP;
				wait until rising_edge(clk);
				
				-- We need one more cycle b/c the flags are registered.
				wait until rising_edge(clk);
				assert saved_c = out_flag_c severity failure;
				assert saved_z = out_flag_z severity failure;
				assert saved_n = out_flag_n severity failure;
				
				-- Non-existing operation code
				in_op <= "011";
				wait until rising_edge(clk);
				
				-- We need one more cycle b/c the flags are registered.
				wait until rising_edge(clk);
				assert saved_c = out_flag_c severity failure;
				assert saved_z = out_flag_z severity failure;
				assert saved_n = out_flag_n severity failure;
				
				-- A-B, send operands and operation mode
				in_op <= ALU_SUB;
				wait until rising_edge(clk);
				
				-- We need one more cycle b/c the flags are registered.
				wait until rising_edge(clk);
				
				-- two unsigned numbers were substracted and we substracked bigger one from smaller one. Ex: 1-2 will give you 255 in result and CF flag will be set.
				if out_flag_c = '1' then
					assert unsigned(in_oper_a) < unsigned(in_oper_b) severity failure;
				else
					assert signed(out_result) = signed(in_oper_a) - signed(in_oper_b) severity failure;
				end if;
				
				if out_flag_z = '1' then
					assert signed(in_oper_a) - signed(in_oper_b) = 0 severity failure;
				else
					assert signed(in_oper_a) - signed(in_oper_b) /= 0 severity failure;
				end if;
				
				if out_flag_n = '1' then
					assert signed(in_oper_a) - signed(in_oper_b) < 0 severity failure;
				else
					assert signed(in_oper_a) - signed(in_oper_b) >= 0 severity failure;
				end if;
				
				result_and := in_oper_a and in_oper_b;
				result_not := not in_oper_a;
				result_or := in_oper_a or in_oper_b;
				result_xor := in_oper_a xor in_oper_b;
				
				-- A and B
				in_op <= ALU_AND;
				wait until rising_edge(clk);
				assert result_and = out_result severity failure;
				
				-- We need one more cycle b/c the flags are registered.
				wait until rising_edge(clk);
				
				if out_result = "00000000" then
					assert out_flag_z = '1' severity failure;
				else
					assert out_flag_z = '0' severity failure;
				end if;
				
				if signed(out_result) < 0 then
					assert out_flag_n = '1' severity failure;
				else
					assert out_flag_n = '0' severity failure;
				end if;
				
				-- not A
				in_op <= ALU_NOT;
				wait until rising_edge(clk);
				assert result_not = out_result severity failure;
				
				-- We need one more cycle b/c the flags are registered.
				wait until rising_edge(clk);
				
				if out_result = "00000000" then
					assert out_flag_z = '1' severity failure;
				else
					assert out_flag_z = '0' severity failure;
				end if;
				
				if signed(out_result) < 0 then
					assert out_flag_n = '1' severity failure;
				else
					assert out_flag_n = '0' severity failure;
				end if;
				
				-- A or B
				in_op <= ALU_OR;
				wait until rising_edge(clk);
				assert result_or = out_result severity failure;
				
				-- We need one more cycle b/c the flags are registered.
				wait until rising_edge(clk);
				
				if out_result = "00000000" then
					assert out_flag_z = '1' severity failure;
				else
					assert out_flag_z = '0' severity failure;
				end if;
				
				if signed(out_result) < 0 then
					assert out_flag_n = '1' severity failure;
				else
					assert out_flag_n = '0' severity failure;
				end if;
				
				-- A xor B
				in_op <= ALU_XOR;
				wait until rising_edge(clk);
				assert result_xor = out_result severity failure;
				
				-- We need one more cycle b/c the flags are registered.
				wait until rising_edge(clk);
				
				if out_result = "00000000" then
					assert out_flag_z = '1' severity failure;
				else
					assert out_flag_z = '0' severity failure;
				end if;
				
				if signed(out_result) < 0 then
					assert out_flag_n = '1' severity failure;
				else
					assert out_flag_n = '0' severity failure;
				end if;		
			end loop L2;
		end loop L1;
		
		report "End simulation" severity failure;
	end process;	
end	tb;