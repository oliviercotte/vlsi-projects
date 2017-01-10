library ieee;
use ieee.std_logic_1164.all;
use work.states.all;

entity machine is
port (
	clk:   in std_logic;
	rst_n: in std_logic;
	
	in_imm:  in std_logic;
	in_w:    in std_logic;
	in_pop1: in std_logic;
	in_pop2: in std_logic;
	in_push: in std_logic;
	in_get:  in std_logic;
	in_put:  in std_logic;
	
	out_pop:   out std_logic;
	out_push:  out std_logic;
	out_get:   out std_logic;
	out_put:   out std_logic;
	out_fetch: out std_logic;
	
	out_state: out std_logic_vector(3 downto 0) );
end machine;

architecture rtl of machine is
	signal state: std_logic_vector(3 downto 0);
	signal next_state: std_logic_vector(3 downto 0);
begin

	-- sortie état
	out_state <= state;
	
	-- sorties état prochain
	process(next_state) begin
		out_pop   <= '0';
		out_push  <= '0';
		out_get   <= '0';
		out_put   <= '0';
		out_fetch <= '0';
		
		case next_state is
		
		when STATE_POP1 | STATE_POP2 =>
			out_pop   <= '1';
			out_push  <= '0';
			out_get   <= '0';
			out_put   <= '0';
			out_fetch <= '0';
		
		when STATE_PUSH =>
			out_pop   <= '0';
			out_push  <= '1';
			out_get   <= '0';
			out_put   <= '0';
			out_fetch <= '0';
		
		when STATE_GET =>
			out_pop   <= '0';
			out_push  <= '0';
			out_get   <= '1';
			out_put   <= '0';
			out_fetch <= '0';
		
		when STATE_PUT =>
			out_pop   <= '0';
			out_push  <= '0';
			out_get   <= '0';
			out_put   <= '1';
			out_fetch <= '0';
		
		when STATE_FETCH | STATE_IMM | STATE_WL | STATE_WH =>
			out_pop   <= '0';
			out_push  <= '0';
			out_get   <= '0';
			out_put   <= '0';
			out_fetch <= '1';
		
		when others =>
			out_pop   <= '0';
			out_push  <= '0';
			out_get   <= '0';
			out_put   <= '0';
			out_fetch <= '0';

		end case;
	end process;
	
	-- processus synchrone de la machine à états
	process(clk, rst_n) begin
		if rst_n = '0' then
			state <= STATE_RESET;
		elsif clk'event and clk = '1' then
			state <= next_state;
		end if;
	end process;

	-- logique de changement d'état
	process(in_imm, in_w, in_pop1, in_pop2, in_push, in_get, in_put, state) begin
		case state is
		
		when STATE_RESET =>
			next_state <= STATE_INIT;
		
		when STATE_INIT =>
			next_state <= STATE_FETCH;
		
		when STATE_FETCH =>
			next_state <= STATE_DECODE;
		
		when STATE_DECODE =>
			if in_w = '1' then
				next_state <= STATE_WL;
			elsif in_imm = '1' then
				next_state <= STATE_IMM;
			elsif in_pop1 = '1' then
				next_state <= STATE_POP1;
			else
				next_state <= STATE_EXEC;
			end if;
		
		when STATE_EXEC =>
			if in_put = '1' then
				next_state <= STATE_PUT;
			elsif in_push = '1' then
				next_state <= STATE_PUSH;
			else
				next_state <= STATE_FETCH;
			end if;
		
		when STATE_PUSH =>
			next_state <= STATE_FETCH;
		
		when STATE_POP1 =>
			if in_pop2 = '1' then
				next_state <= STATE_POP2;
			else
				next_state <= STATE_EXEC;
			end if;
		
		when STATE_POP2 =>
			next_state <= STATE_EXEC;
		
		when STATE_IMM =>
			if in_get = '1' then
				next_state <= STATE_AGET;
			elsif in_pop1 = '1' then
				next_state <= STATE_POP1;
			else
				next_state <= STATE_EXEC;
			end if;
	
		when STATE_AGET =>
			next_state <= STATE_GET;
		
		when STATE_WL =>
			next_state <= STATE_WH;
		
		when STATE_WH =>
			next_state <= STATE_FETCH;
		
		when STATE_GET =>
			next_state <= STATE_EXEC;
		
		when STATE_PUT =>
			next_state <= STATE_FETCH;
		
		when others =>
			next_state <= STATE_RESET;
		
		end case;
	end process;
end rtl;

