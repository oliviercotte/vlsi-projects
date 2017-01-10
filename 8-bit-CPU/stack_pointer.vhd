--=======================================================================================
-- TITLE : stack_pointer
-- DESCRIPTION : The stack grow downward. 
-- Thus, when data is taken from the stack (in_pop), it is read from the sp address and 
-- the stack pointer is incremented. When data is placed on the stack (in_push), it is 
-- written to the address SP-1 address and the stack pointer is decremented.
-- FILE : stack_pointer.vhd
--=======================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stack_pointer is
generic	(
	width 	: POSITIVE 	:= 24; 	-- number of bits of the pointe
	init 	: NATURAL 	:= 0;	-- value at which the counter is reset when rst_n is low
	incr 	: POSITIVE 	:= 2 	-- the value by which increments the pointer when in_pop or in_push are high
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
end stack_pointer;

architecture stack_pointer_arch of stack_pointer is
signal sp :	unsigned(width - 1 downto 0) := to_unsigned(init, out_sp'length); -- Current value of the stack pointer
begin
	process(in_push, sp) begin
        if in_push = '1' then
            out_sp <= STD_LOGIC_VECTOR(sp - incr);
        else
            out_sp <= STD_LOGIC_VECTOR(sp);
        end if;
    end process; 

	process(clk, rst_n)
	begin
		if rst_n = '0' then
			sp <= to_unsigned(init, out_sp'length);
		elsif rising_edge(clk) then
			if in_load = '1' then
				sp <= unsigned(in_sp);
			elsif in_pop = '1' then
				sp <= sp + incr;
			elsif in_push = '1' then  
				sp <= sp - incr;
			else 
				null;
			end if;
		end if;	
	end process;	
end stack_pointer_arch;