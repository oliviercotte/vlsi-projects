--=======================================================================================
-- TITLE : program_counter
-- DESCRIPTION : Set the sequential execution of instructions.
-- Some instructions, such as jumps and branch, used to change the program counter contents 
-- so as to break the sequential execution of the code.
-- FILE : program_counter.vhd
--=======================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter is
generic	(
	width 	: POSITIVE 	:= 24; 	-- number of counter bits
	init 	: NATURAL 	:= 0; 	-- value at which the counter is reset when rst_n is low
	incr 	: POSITIVE 	:= 2 	-- the value by which the counter is incremented when in_incr is high and the value by which in_pc is incremented before being loaded into the counter when in_jump is high
);
port (
	clk:   in std_logic;
	rst_n: in std_logic;
	
	in_incr: in std_logic;
	in_jump: in std_logic;
	
	in_pc: in std_logic_vector(width - 1 downto 0);
	
	out_pc: out std_logic_vector(width - 1 downto 0)
);  
end program_counter;

architecture program_counter_arch of program_counter is
signal pc :	unsigned(width - 1 downto 0) := to_unsigned(init, out_pc'length); -- Current value of the program counter
begin
	process(clk, rst_n)
	begin
		if rst_n = '0' then
			pc <= to_unsigned(init, out_pc'length);
		elsif rising_edge(clk) then
			if in_jump = '1' then
				pc <= unsigned(in_pc) + incr;
			elsif in_incr = '1' then
				pc <= pc + incr;
			else
				null;
			end if;
		end if;
	end process;
	
	out_pc <= std_logic_vector(pc);	
end program_counter_arch;