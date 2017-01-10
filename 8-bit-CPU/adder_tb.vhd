--=======================================================================================
-- TITLE : adder_tb
-- DESCRIPTION : We compare the structural description to one behavioral.
-- FILE : adder_tb.vhd
--=======================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder_tb is
end adder_tb;

architecture tb of adder_tb is

component adder 
	port (
		in_oper8: in std_logic_vector(7 downto 0);
		in_oper16: in std_logic_vector(15 downto 0);
		out_sum: out std_logic_vector(15 downto 0) 
	);
end component;

signal in_oper8: std_logic_vector(7 downto 0);
signal in_oper16: std_logic_vector(15 downto 0);
signal out_sum: std_logic_vector(15 downto 0);

begin
	UUT : adder
		port map (
			in_oper8 => in_oper8,
			in_oper16 => in_oper16,
			out_sum => out_sum
			);
	
	-- Behavioral description of the adder that will be use to compare the structural description
	process
	variable sum : integer;
	begin
		for tb_oper8 in -2 ** 6 to 2 ** 6 - 1 loop	
			for tb_oper16 in -2 ** 14 - tb_oper8 to 2 ** 14 - 1 - tb_oper8 loop
				in_oper8 <= std_logic_vector(to_signed(tb_oper8, in_oper8'length));
				in_oper16 <= std_logic_vector(to_signed(tb_oper16, in_oper16'length));
				sum := tb_oper8 + tb_oper16; 
				wait for 10 ns;
				assert sum = to_integer(signed(out_sum)) report "Difference between the structural and the behavioral architecture" severity failure;
			end loop;
		end loop;
		report "End simulation" severity failure;
	end process;
end tb;