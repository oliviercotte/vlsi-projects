--=======================================================================================
-- TITLE : program_counter_tb
-- DESCRIPTION : Test different program counter operating mode.
-- FILE : program_counter_tb.vhd
--=======================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter_tb is
end program_counter_tb;

architecture tb of program_counter_tb is

component program_counter
	generic	(
		width 	: POSITIVE 	:= 24; 
		init 	: NATURAL 	:= 0;
		incr 	: POSITIVE 	:= 16 
	);
	port (
		clk:   in std_logic;
		rst_n: in std_logic;
		
		in_incr: in std_logic;
		in_jump: in std_logic;
		
		in_pc: in std_logic_vector(width - 1 downto 0);
		
		out_pc: out std_logic_vector(width - 1 downto 0)
	);  
end component;

constant width: POSITIVE := 16; 
constant init: NATURAL := 0;
constant incr: POSITIVE := 32; 
constant CLK_PERIOD : time := 1 ns;

signal clk: std_logic := '0';
signal rst_n:  std_logic := '1';		
signal in_incr: std_logic := '0';
signal in_jump: std_logic := '0' ;		
signal in_pc: std_logic_vector(width - 1 downto 0) := (others => '0');		
signal out_pc: std_logic_vector(width - 1 downto 0);

begin
	clk <= not clk after CLK_PERIOD;
	
	UUT : program_counter
	generic map	(
		width => width,
		init => init,
		incr => incr 
	)
	port map (
		clk => clk,
		rst_n => rst_n,
		in_incr => in_incr,
		in_jump => in_jump,
		in_pc => in_pc,
		out_pc => out_pc
	);
	
	process
	variable curr_pc :	unsigned(width - 1 downto 0) := to_unsigned(init, out_pc'length);
	begin	
		-- Operation of the increment
		wait until rising_edge(clk);
		in_incr <= '1';
		for i in 0 to 2 ** (width - 5)  - 1 loop
			curr_pc := unsigned(out_pc);
			wait until out_pc'event;
			assert unsigned(out_pc) = (curr_pc + incr) report "Error - Output (" & integer'image(to_integer(unsigned(out_pc))) & " /= "  & integer'image(to_integer(curr_pc) + incr) & ")" severity error;
		end loop;
		
		-- Asynchronous reset operation
		rst_n <= '0';
		in_incr <= '0';
		wait until rising_edge(clk);
		assert unsigned(out_pc) = init report "Error - Output" severity error;
		
		-- Jump operation
		rst_n <= '1';
		in_jump <= '1';
		in_pc <= x"CAFE";
		wait until rising_edge(clk);
		wait until out_pc'event;
		assert unsigned(out_pc) = unsigned(in_pc) + incr report "Error - Output" severity error;
		
		-- To see clearly the end of the simulation (last quantum)
		wait until rising_edge(clk);
		
		report "End simulation" severity failure;
	end process;	
end tb;
