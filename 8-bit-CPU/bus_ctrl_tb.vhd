--=======================================================================================
-- TITLE : bus_ctrl_tb
-- DESCRIPTION : Test the module behavior in response to control signals.
-- FILE : bus_ctrl_tb.vhd
--=======================================================================================

library ieee;
use ieee.std_logic_1164.all;

entity bus_ctrl_tb is
end bus_ctrl_tb;

architecture tb of bus_ctrl_tb is

component bus_ctrl
	generic	(
		addr_width : positive := 24;
		data_width : positive := 24
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
end component;

constant CLK_PERIOD : time := 1 ns;

constant addr_width : positive := 32;
constant data_width : positive := 32;

signal clk: std_logic := '0';
signal rst_n: std_logic := '1';
		
signal in_pop: std_logic := '0';
signal in_push: std_logic := '0';
signal in_get: std_logic := '0';
signal in_put: std_logic := '0';
signal in_fetch: std_logic := '0';
		
signal in_addr_fetch: std_logic_vector(addr_width - 1 downto 0);
signal in_addr_stack: std_logic_vector(addr_width - 1 downto 0);
signal in_addr_data: std_logic_vector(addr_width - 1 downto 0);
signal in_data: std_logic_vector(data_width - 1 downto 0);
		
signal bus_idata: std_logic_vector(data_width - 1 downto 0);
		
signal out_data: std_logic_vector(data_width - 1 downto 0);
		
signal bus_rd: std_logic;
signal bus_wr: std_logic;
signal bus_addr: std_logic_vector(addr_width - 1 downto 0);
signal bus_odata: std_logic_vector(data_width - 1 downto 0);
		
begin
	
	clk <= not clk after CLK_PERIOD;
	
	UUT: bus_ctrl
	generic	map(
		addr_width => addr_width,
		data_width => data_width
		)
	port map (
		clk => clk,
		rst_n => rst_n,	
		in_pop => in_pop,
		in_push => in_push,
		in_get => in_get,
		in_put => in_put,
		in_fetch => in_fetch,
		in_addr_fetch => in_addr_fetch,
		in_addr_stack => in_addr_stack,
		in_addr_data => in_addr_data,
		in_data => in_data,
		bus_idata => bus_idata,
		out_data => out_data,
		bus_rd => bus_rd,
		bus_wr => bus_wr,
		bus_addr => bus_addr,
		bus_odata => bus_odata
	);
	
	process
	begin
		
		in_addr_fetch 	<= x"CAFED00D";
		in_addr_stack 	<= x"DABBAD00";
		in_addr_data 	<= x"DEADBABE";
		in_data 		<= x"FACEFEED";
		bus_idata 		<= x"DEADBEEF";
		
		in_pop <= '1';
		
		wait until rising_edge(clk);
		wait until bus_odata'event;
		assert out_data = bus_idata;
		assert bus_odata = in_data;	
		
		wait until falling_edge(clk);
		assert bus_rd =  '1';
		assert bus_wr =  '0';
		assert bus_addr = in_addr_stack;
		
		in_pop <= '0';
		in_push <= '1';
		wait until falling_edge(clk);
		assert bus_rd =  '0';
		assert bus_wr  =  '1';
		assert bus_addr = in_addr_stack;
		
		in_push <= '0';
		in_get <= '1';
		wait until falling_edge(clk);
		assert bus_rd =  '1';
		assert bus_wr =  '0';
		assert bus_addr = in_addr_data;
		
		in_get <= '0';
		in_put <= '1';
		wait until falling_edge(clk);
		assert bus_rd =  '0';
		assert bus_wr =  '1';
		assert bus_addr = in_addr_data;
		
		in_put <= '0';
		in_fetch <= '1';
		wait until falling_edge(clk);
		assert bus_rd =  '1';
		assert bus_wr =  '0';
		assert bus_addr = in_addr_fetch;
		
		rst_n <= '0';
		wait until falling_edge(clk);
		assert bus_rd <=  '0';
		assert bus_wr <=  '0';
		
		rst_n <= '1';
		in_fetch <= '0';
		wait until falling_edge(clk);
		assert bus_rd <=  '0';
		assert bus_wr <=  '0';
		
		wait until falling_edge(clk);
		
		report "End simulation" severity failure;
	end process;
	
end tb;