--=======================================================================================
-- TITLE : bus_ctrl
-- DESCRIPTION : This module interfaces with the outside of the circuit.
-- FILE : bus_ctrl.vhd
--=======================================================================================

library ieee;
use ieee.std_logic_1164.all;

entity bus_ctrl is
generic	(
	addr_width : positive := 24; -- the width of all signals representing an address
	data_width : positive := 24 -- the width of all data representing signals
);
port (
	clk:   in std_logic;
	rst_n: in std_logic;
	
	in_pop: 	in std_logic;
	in_push: 	in std_logic;
	in_get: 	in std_logic;
	in_put: 	in std_logic;
	in_fetch: 	in std_logic;
	
	in_addr_fetch: 	in std_logic_vector(addr_width - 1 downto 0);
	in_addr_stack: 	in std_logic_vector(addr_width - 1 downto 0);
	in_addr_data: 	in std_logic_vector(addr_width - 1 downto 0);
	in_data: 		in std_logic_vector(data_width - 1 downto 0);
	
	bus_idata: in std_logic_vector(data_width - 1 downto 0);
	
	out_data: out std_logic_vector(data_width - 1 downto 0);
	
	bus_rd: 	out std_logic;
	bus_wr: 	out std_logic;
	bus_addr: 	out std_logic_vector(addr_width - 1 downto 0);
	bus_odata: 	out std_logic_vector(data_width - 1 downto 0)
);  
end bus_ctrl;

architecture bus_ctrl_arch of bus_ctrl is
begin
	-- this output is connected directly to the bus_idata entry
	out_data <= bus_idata;
	
	-- the input of the register whose output is connected to bus_odata is directly connected to in_data
	process(clk)
	begin
		if rising_edge(clk) then
			bus_odata <= in_data;
		end if;
	end process;
	
	process(clk, rst_n)
	begin
		if rst_n = '0' then
			bus_rd <=  '0';
			bus_wr <=  '0';
		elsif rising_edge(clk) then
			if in_pop = '1' then
				bus_rd <=  '1';
				bus_wr <=  '0';
				bus_addr <= in_addr_stack;
			elsif in_push = '1' then
				bus_rd <=  '0';
				bus_wr <=  '1';
				bus_addr <= in_addr_stack;
			elsif in_get = '1' then
				bus_rd <=  '1';
				bus_wr <=  '0';
				bus_addr <= in_addr_data;
			elsif in_put = '1' then
				bus_rd <=  '0';
				bus_wr <=  '1';
				bus_addr <= in_addr_data;
			elsif in_fetch = '1' then
				bus_rd <=  '1';
				bus_wr <=  '0';
				bus_addr <= in_addr_fetch;
			else
				bus_rd <=  '0';
				bus_wr <=  '0';
			end if;
		end if;
	end process;	
end bus_ctrl_arch;