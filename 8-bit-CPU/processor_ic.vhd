library ieee;
use ieee.std_logic_1164.all;

entity processor_ic is
port(
	clk:   in std_logic;
	rst_n: in std_logic;
	
	out_wr: out std_logic;
	out_rd: out std_logic;
	
	out_addr: out   std_logic_vector(15 downto 0);
	io_data:  inout std_logic_vector( 7 downto 0) );
end processor_ic;

architecture rtl of processor_ic is
	
	-- processor
	component processor is
	port(
		clk:   in std_logic;
		rst_n: in std_logic;
		
		out_wr: out std_logic;
		out_rd: out std_logic;
		
		out_addr: out std_logic_vector(15 downto 0);
		out_data: out std_logic_vector( 7 downto 0);
		in_data:  in  std_logic_vector( 7 downto 0) );
	end component;
	
	-- input pad
	component PDISDGZ
	port(
		pad:  in std_logic;
		c:   out std_logic );
	end component;
	
	-- output pad
	component PDO02CDG
	port(
		i:    in std_logic;
		pad: out std_logic );
	end component;
	
	-- 3-state input-output pad
	component PDB02DGZ
	port(
		i:      in std_logic;
		c:     out std_logic;
		oen:    in std_logic;
		pad: inout std_logic );
	end component;
	
	-- signals
	signal s_clk:   std_logic;
	signal s_rst_n: std_logic;
	signal s_wr:    std_logic;	
	signal s_rd:    std_logic;
	signal s_oe_n:  std_logic;
	signal s_addr:  std_logic_vector(15 downto 0);
	signal s_idata: std_logic_vector( 7 downto 0);
	signal s_odata: std_logic_vector( 7 downto 0);

begin
	-- output enable signal
	s_oe_n <= not s_wr;
	
	-- processor
	u_processor_core: processor
	port map(
		clk      => s_clk,
		rst_n    => s_rst_n,
		
		out_wr   => s_wr,
		out_rd   => s_rd,
		
		out_addr => s_addr,
		in_data  => s_idata,
		out_data => s_odata );
	
	-- clock pad
	pad_clk: PDISDGZ
	port map(
		pad => clk,
		c   => s_clk );
	
	-- reset pad
	pad_rst: PDISDGZ
	port map(
		pad => rst_n,
		c   => s_rst_n );
	
	-- write signal pad
	pad_wr: PDO02CDG
	port map(
		i   => s_wr,
		pad => out_wr );
	
	-- read signal pad
	pad_rd: PDO02CDG
	port map(
		i   => s_rd,
		pad => out_rd );
	
	-- address output pads
	gen_addr: for idx in 0 to 15 generate
		pad_addr: PDO02CDG
		port map(
			i   =>  s_addr(idx),
			pad =>  out_addr(idx) );
	end generate;

	-- data 3-state input-output pads
	gen_io_data: for idx in 0 to 7 generate
		pad_io_data: PDB02DGZ
		port map(
			i   => s_odata(idx),
			c   => s_idata(idx),
			oen => s_oe_n,
			pad => io_data(idx) );
	end generate;
	
end rtl;
