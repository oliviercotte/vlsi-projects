library ieee;
use ieee.std_logic_1164.all;

entity processor_tb is
end processor_tb;

architecture tb of processor_tb is
	constant PERIOD: time := 50 ns;
	
	component processor_ic is
	port(
		clk:   in std_logic;
		rst_n: in std_logic;
	
		out_wr: out std_logic;
		out_rd: out std_logic;
	
		out_addr: out   std_logic_vector(15 downto 0);
		io_data:  inout std_logic_vector( 7 downto 0) );
	end component;
	
	component ram is
	port(
		clk:       in std_logic;
		rst_n:     in std_logic;
		in_wr:     in std_logic;
		in_rd:     in std_logic;

		in_addr:   in    std_logic_vector(15 downto 0);
		io_data:   inout std_logic_vector(7 downto 0) );
	end component;
	
	for u_ram: ram use entity work.ram(fibo);
	
	signal clk:   std_logic := '0';
	signal rst_n: std_logic := '0';
	
	signal bus_addr: std_logic_vector(15 downto 0);
	signal bus_data: std_logic_vector( 7 downto 0);
	signal bus_rd:   std_logic := '0';
	signal bus_wr:   std_logic := '0';
		
begin
	
	clk <= not clk after PERIOD / 2;

	process begin
		rst_n <= '0';
		wait for 3.75 * PERIOD;
		rst_n <= '1';
		wait;
	end process;
	
	u_dut: processor_ic
	port map(
		clk      => clk,
		rst_n    => rst_n,
		
		out_wr   => bus_wr,
		out_rd   => bus_rd,
		
		out_addr => bus_addr,
		io_data  => bus_data );
	
	u_ram: ram
	port map(
		clk     => clk,
		rst_n   => rst_n,
		
		in_wr   => bus_wr,
		in_rd   => bus_rd,
		
		in_addr => bus_addr,
		io_data => bus_data );	
end tb;
