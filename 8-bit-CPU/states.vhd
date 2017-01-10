library ieee;
use ieee.std_logic_1164.all;

package states is
	constant STATE_RESET:  std_logic_vector(3 downto 0) := x"0";
	constant STATE_INIT:   std_logic_vector(3 downto 0) := x"1";
	constant STATE_FETCH:  std_logic_vector(3 downto 0) := x"2";
	constant STATE_DECODE: std_logic_vector(3 downto 0) := x"3";
	constant STATE_EXEC:   std_logic_vector(3 downto 0) := x"4";
	constant STATE_POP1:   std_logic_vector(3 downto 0) := x"5";
	constant STATE_POP2:   std_logic_vector(3 downto 0) := x"6";
	constant STATE_IMM:    std_logic_vector(3 downto 0) := x"7";
	constant STATE_AGET:   std_logic_vector(3 downto 0) := x"8";
	constant STATE_GET:    std_logic_vector(3 downto 0) := x"9";
	constant STATE_WL:     std_logic_vector(3 downto 0) := x"a";
	constant STATE_WH:     std_logic_vector(3 downto 0) := x"c";
	constant STATE_PUSH:   std_logic_vector(3 downto 0) := x"d";
	constant STATE_PUT:    std_logic_vector(3 downto 0) := x"e";
end package;

