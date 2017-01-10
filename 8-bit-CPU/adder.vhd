--=======================================================================================
-- TITLE : adder
-- DESCRIPTION : A signed 16-bit extension of the 8-bit operand (in_oper8) is performed.
-- Then, this value is added to the 16-bit operand (in_oper16).
-- The result is set to the output out_sum.
-- FILE : adder.vhd
--=======================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
port (
	in_oper8 : in std_logic_vector(7 downto 0);
	in_oper16 : in std_logic_vector(15 downto 0);
	out_sum : out std_logic_vector(15 downto 0) 
	);
end adder;

architecture adder_arch of adder is
begin
	out_sum <= std_logic_vector(signed(in_oper16) + resize(signed(in_oper8), in_oper16'length));
end adder_arch;