--=======================================================================================
-- TITLE : stack_pointer_tb
-- DESCRIPTION : Test different operating mode of the stack pointer.
-- FILE : stack_pointer_tb.vhd
--=======================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stack_pointer_tb is
end stack_pointer_tb;

architecture tb of stack_pointer_tb is

component stack_pointer
	generic	(
		width 	: POSITIVE 	:= 24;
		init 	: NATURAL 	:= 0;
		incr 	: POSITIVE 	:= 2
	);
	port (
		clk:   in std_logic;
		rst_n: in std_logic;
		
		in_pop: in std_logic;
		in_push: in std_logic;
		in_load: in std_logic;
		
		in_sp: in std_logic_vector(width - 1 downto 0);	
		
		out_sp: out std_logic_vector(width - 1 downto 0)
	);  
end component;

constant width: POSITIVE := 16; 
constant init: NATURAL := 0;
constant incr: POSITIVE := 32; 
constant CLK_PERIOD : time := 1 ns;

signal clk: std_logic := '0';
signal rst_n: std_logic := '1';
		
signal in_pop: std_logic := '0';
signal in_push: std_logic := '0';
signal in_load: std_logic := '0';		
signal in_sp: std_logic_vector(width - 1 downto 0) := (others => '0');			
signal out_sp: std_logic_vector(width - 1 downto 0);
		
begin
	
	clk <= not clk after CLK_PERIOD;
	
	UUT : stack_pointer
	generic map	(
		width => width,
		init => init,
		incr => incr 
	)
	port map (
		clk => clk,
		rst_n => rst_n,
		in_pop => in_pop,
		in_push => in_push,
		in_load => in_load,
		in_sp => in_sp,
		out_sp => out_sp
	);
	
	process
	variable curr_sp :	unsigned(width - 1 downto 0) := to_unsigned(init, out_sp'length);
	begin
		
		-- Increment Operation
		in_pop <= '1';
		wait until rising_edge(clk);
		for i in 1 to 2 ** (width - 5)  - 1 loop
			curr_sp := unsigned(out_sp);
			wait until out_sp'event;
			assert unsigned(out_sp) = (curr_sp + incr) report "Error - Output (" & integer'image(to_integer(unsigned(out_sp))) & " /= "  & integer'image(to_integer(curr_sp) + incr) & ")" severity error;
		end loop;
		
		--  Operating the decrement
		in_pop <= '0';
		wait until rising_edge(clk);
		in_push <= '1';
		for i in 1 to 2 ** (width - 5)  - 1 loop
			curr_sp := unsigned(out_sp);
			wait until out_sp'event;
			assert unsigned(out_sp) = (curr_sp - incr) report "Error - Output (" & integer'image(to_integer(unsigned(out_sp))) & " /= "  & integer'image(to_integer(curr_sp) - incr) & ")" severity error;
		end loop;
		
		-- Asynchronous reset operation
		rst_n <= '0';
		in_push <= '0';
		wait until rising_edge(clk);
		assert unsigned(out_sp) = init report "Error - Output" severity error;
		
		-- Jump operation
		rst_n <= '1';
		in_load <= '1';
		in_sp <= x"CAFE";
		wait until rising_edge(clk);
		wait until out_sp'event;
		assert unsigned(out_sp) = unsigned(in_sp) report "Error - Output" severity error;
		
		-- To see clearly the end of the simulation (last quantum)
		wait until rising_edge(clk);
		
		report "End simulation" severity failure;
	end process;
	
end tb;