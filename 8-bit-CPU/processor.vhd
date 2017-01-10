--=======================================================================================
-- TITLE : processor
-- DESCRIPTION : 8-bit microprocessor whose architecture is based on a stack.
-- FILE : processor.vhd
--=======================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.opcodes.all;
use work.states.all;

entity processor is
port (
	clk:   in std_logic;
	rst_n: in std_logic;
	
	in_data: 		in std_logic_vector(7 downto 0);
	
	out_rd: 	out std_logic;
	out_wr: 	out std_logic;
	
	out_addr: 	out std_logic_vector(15 downto 0);
	out_data: 	out std_logic_vector(7 downto 0)
);
end processor;

architecture processor_arch of processor is

-- PROGRAM_COUNTER --
component program_counter
	generic	(
		width 	: POSITIVE 	:= 24; 
		init 	: NATURAL 	:= 0;
		incr 	: POSITIVE 	:= 2 
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
-- PROGRAM_COUNTER --

-- STACK_POINTER --
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
-- STACK_POINTER 

-- BUS_CTRL --
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
-- BUS_CTRL --

-- ALU --
component alu
port (
	clk:   in std_logic;
	rst_n: in std_logic;
	
	in_op: in std_logic_vector(2 downto 0);
	
	in_oper_a: in std_logic_vector(7 downto 0);
	in_oper_b: in std_logic_vector(7 downto 0);	
	
	out_flag_c: out std_logic;
	out_flag_n: out std_logic;
	out_flag_z: out std_logic;
	
	out_result: out std_logic_vector(7 downto 0)
);
end component;
-- ALU --

-- INSTRUCTION DECODER --
component instruction_decoder
	port (
		in_op : in std_logic_vector(7 downto 0);
		
		out_alu_op 	: out std_logic_vector(2 downto 0);
		
		out_imm 	: out std_logic;
		out_w 		: out std_logic;
		out_pop1 	: out std_logic;  
		out_pop2 	: out std_logic;  
		out_push 	: out std_logic;  
		out_get 	: out std_logic;  
		out_put 	: out std_logic  
	);  
end component;
-- INSTRUCTION DECODER --

-- MACHINE --
component machine
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
end component;
-- MACHINE --

-- ADDER --
component adder 
	port (
		in_oper8 : in std_logic_vector(7 downto 0);
		in_oper16 : in std_logic_vector(15 downto 0);
		out_sum : out std_logic_vector(15 downto 0) 
	);
end component;
-- ADDER --

----     Constants     -----
constant addr_width : positive := 16;
constant data_width : positive := 8;
constant init : NATURAL := 0;
constant incr : POSITIVE := 1;

-- Architectural Registers --
signal bp: std_logic_vector(addr_width - 1 downto 0); -- base pointer (pointing to an area of memory used for storing variables)
signal w: std_logic_vector(addr_width - 1 downto 0); -- This register is used to temporarily store a 16 -bit value

-- Modified by some instructions and provide information on the result produced by them
signal c: std_logic; -- carry flag (indicate when an arithmetic carry or borrow has been generated out of the most significant ALU bit position)
signal n: std_logic; -- negative flag (indicate whether the result of the last mathematical operation resulted in a value whose most significant bit was set)
signal z: std_logic; -- zero flag (an arithmetic result is zero)
-- Architectural Registers --

-- microarchitectural registers --
signal i: std_logic_vector(data_width - 1 downto 0); -- used to store the opcode of the current instruction
signal a: std_logic_vector(data_width - 1 downto 0); -- stores a data and is primarily used as an operand in the calculations ( in_oper_a )
signal b: std_logic_vector(data_width - 1 downto 0); -- stores a data and is also used mainly as an operand in the calculations ( in_oper_b )
-- microarchitectural registers --

----     Signal declarations     -----
signal state : std_logic_vector(3 downto 0);  -- connect the output out_state of the state machine (current execution stage)
signal idata: std_logic_vector(data_width - 1 downto 0); -- a value read into memory connected to the output of the bus controller out_data
signal out_alu_op: std_logic_vector(2 downto 0);

signal in_imm: std_logic;
signal in_w: std_logic;
signal in_pop1: std_logic;
signal in_pop2: std_logic;
signal in_push: std_logic;
signal in_get: std_logic;
signal in_put: std_logic;
	
signal out_pop: std_logic;
signal out_push: std_logic;
signal out_get: std_logic;
signal out_put: std_logic;
signal out_fetch: std_logic;

signal out_pc: std_logic_vector(addr_width - 1 downto 0);

signal fetch_addr: std_logic_vector(addr_width - 1 downto 0);
signal odata: std_logic_vector(data_width - 1 downto 0); -- This signal is used to convey the results to be stored in memory.
signal out_sp: std_logic_vector(addr_width - 1 downto 0);

signal to_sp: std_logic;
signal to_pc: std_logic;

signal c1, c2, c3, c4, c5 : std_logic; -- controls signals for the program counter --

signal out_result: std_logic_vector(7 downto 0);

signal adder_oper8: std_logic_vector(data_width - 1 downto 0);
signal adder_oper16: std_logic_vector(addr_width - 1 downto 0);
signal out_sum: std_logic_vector(addr_width - 1 downto 0);

begin
	-- MICROARCHITECTURAL REGISTERS AND ARCHITECTURAL REGISTERS --
	-- Values to be loaded into the processor registers	
	-- Takes idata value at the FETCH execution step.
	-- Remains unchanged (keeps its current value) at all other execution steps.
	register_i: process(clk)
	begin
		if rising_edge(clk) then
			if state = STATE_FETCH then
				i <= idata;
			end if;
		end if;
	end process;
	
	-- Takes idata value at the POP1 and GET execution step.
	-- Remains unchanged (keeps its current value) at all other execution steps.
	register_a: process(clk)
	begin
		if rising_edge(clk) then
			if state = STATE_POP1 or state = STATE_GET  then
				a <= idata;
			end if;
		end if;
	end process;
	
	-- Takes idata value at the POP2 and IMM execution step.
	-- Remains unchanged (keeps its current value) at all other execution steps.
	registre_b: process(clk)
	begin
		if rising_edge(clk) then
			if state = STATE_POP2 or state = STATE_IMM  then
				b <= idata;
			end if;
		end if;
	end process;
	
	register_w: process(clk)
	begin
		if rising_edge(clk) then
			case state is
				when STATE_WH =>
					w(w'high downto w'high - 8 + 1) <= idata;
				
				when STATE_WL =>
					w(7 downto 0) <= idata;
				
				when STATE_EXEC =>
					case i is
						when OP_ADD_W =>
							w <= out_sum;
						
						when OP_POP_WH =>
							w(w'high downto w'high - 8 + 1) <= a;
						
						when OP_POP_WL =>
							w(7 downto 0) <= a;
						
						when OP_PC_TO_W =>
							w <= out_pc;
						
						when OP_SP_TO_W =>
							w <= out_sp;
						
						when OP_BP_TO_W =>
							w <= bp;
						
						when others =>
					end case;
	
				when others =>
			end case;
		end if;
	end process;
	
	register_bp: process(clk)
	begin
		if rising_edge(clk) then
			if state = STATE_EXEC then
				if i = OP_W_TO_BP then 
					bp <= w;
				end if;
			end if;
		end if;
	end process;
	-- MICROARCHITECTURAL REGISTERS AND ARCHITECTURAL REGISTERS --
	
	-- CONTROL FLOW -- 
	-- Connections leading to the correct operation of the infrastructure to retrieve instructions from memory and decode them.
	-- These are used to generate a plurality of internal control signals to the processor.
	to_sp <= '1' when state = STATE_EXEC and i = OP_W_TO_SP else '0';
		
	c1 <= '1' when state = STATE_EXEC and (i = OP_JMP or i = OP_W_TO_PC) else '0';
	c2 <= '1' when state = STATE_EXEC and i = OP_BEQ and z = '1' else '0';
	c3 <= '1' when state = STATE_EXEC and i = OP_BNE and z = '0' else '0';
	c4 <= '1' when state = STATE_EXEC and i = OP_BNEG and n = '1' else '0';
	c5 <= '1' when state = STATE_EXEC and i = OP_BC and c = '1' else '0';
	to_pc <= '1' when c1 = '1' or c2 = '1' or c3 = '1' or c4 = '1' or c5 = '1' else '0';
	
	fetch_address: process(state, i, w, to_pc, out_sum, out_pc)
	begin
		case state is
			when STATE_EXEC =>
				if i = OP_W_TO_PC then
					fetch_addr <= w;
				elsif to_pc = '1' then
					fetch_addr <= out_sum;
				else
					fetch_addr <= out_pc;
				end if;
			when others => fetch_addr <= out_pc;
		end case;
	end process;
	-- CONTROL FLOW --
	
	-- DATAFLOW --
	data_to_mem: process(i, out_result, b, a, w)
	begin
		if i(i'high downto i'high - 4 + 1) = ALU_PREFIX then
			odata <= out_result;
		else
			case i is
				when OP_CONST =>
					odata <= b;
				when OP_GET | OP_PUT =>
					odata <= a;
				when OP_PUSH_WH =>
					odata <= w(w'high downto w'high - 8 + 1);
				when OP_PUSH_WL =>
					odata <= w(7 downto 0);
				when others =>
			end case;
		end if;
	end process;
	
	adder_oper: process(i, a, w, b, bp, out_pc)
	begin
		case i is
			when OP_ADD_W =>
				adder_oper8	 <= a;
				adder_oper16 <= w;
			when OP_GET | OP_PUT=>
				adder_oper8	 <= b;
				adder_oper16 <= bp;
			when OP_JMP | OP_BEQ | OP_BNE | OP_BNEG | OP_BC =>
				adder_oper8	 <= b;
				adder_oper16 <= out_pc;
			when others =>
		end case;
	end process;
	-- DATAFLOW --
	
	-- INTERNAL MODULE --
	u_instruction_decoder: instruction_decoder
	port map (
		in_op => i,
		out_alu_op => out_alu_op,
		out_imm  => in_imm,
		out_w => in_w,
		out_pop1 => in_pop1,  
		out_pop2 => in_pop2,
		out_push => in_push,
		out_get => in_get,
		out_put => in_put
	);
	
	u_alu : alu
	port map(
		clk => clk,
		rst_n => rst_n,
		in_op => out_alu_op,
		in_oper_a => a,
		in_oper_b => b,	
		out_flag_c => c,
		out_flag_n => n,
		out_flag_z => z,
		out_result => out_result
	);
	
	u_machine: machine
	port map(
		clk => clk,
		rst_n => rst_n,
		in_imm => in_imm,
		in_w => in_w,
		in_pop1 => in_pop1,
		in_pop2 => in_pop2,
		in_push => in_push,
		in_get => in_get,
		in_put => in_put,
		out_pop => out_pop,
		out_push => out_push,
		out_get => out_get,
		out_put => out_put,
		out_fetch => out_fetch,
		out_state => state
  );
  
  u_bus_ctrl: bus_ctrl
	generic	map(
		addr_width => addr_width,
		data_width => data_width
		)
	port map (
		clk => clk,
		rst_n => rst_n,	
		in_pop => out_pop,
		in_push => out_push,
		in_get => out_get,
		in_put => out_put,
		in_fetch => out_fetch,
		in_addr_fetch => fetch_addr,
		in_addr_stack => out_sp,
		in_addr_data => out_sum,
		in_data => odata,
		bus_idata => in_data,
		out_data => idata,
		bus_rd => out_rd,
		bus_wr => out_wr,
		bus_addr => out_addr,
		bus_odata => out_data
	);
	
	u_stack_pointer: stack_pointer
	generic map	(
		width => addr_width,
		init => init,
		incr => incr 
	)
	port map (
		clk => clk,
		rst_n => rst_n,
		in_pop => out_pop,
		in_push => out_push,
		in_load => to_sp,
		in_sp => w,
		out_sp => out_sp
	);  

	u_program_counter: program_counter
	generic map	(
		width => addr_width,
		init => init,
		incr => incr 
	)
	port map (
		clk => clk,
		rst_n => rst_n,
		in_incr => out_fetch,
		in_jump => to_pc,
		in_pc => fetch_addr,
		out_pc => out_pc
	); 
	
	u_adder: adder
	port map(
		in_oper8 => adder_oper8,
		in_oper16 => adder_oper16,
		out_sum => out_sum
	);
	-- INTERNAL MODULE --	
end processor_arch;