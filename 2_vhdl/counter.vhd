-- -----------------------------------------------------------------------------
-- Filename: counter.vhd
-- Author  : M. Pichler
-- Date    : 2014.01.28
-- Content : 
-- -----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bin2bcd_pkg.all;

entity counter is
	port(
		clk       : in  std_ulogic; -- clock
		rst_n     : in  std_ulogic; -- asynchronous reset
		-- control pulse:
		run_p     : in  std_ulogic; -- start/stop counter
		load_p    : in  std_ulogic; -- load counter with cnd_din
		setmax_p  : in  std_ulogic; -- set max. value of counter with cnd_din
		-- control level:
		cnt_din   : in  std_ulogic_vector(5 downto 0); --       :       load/max value
		cnt_up    : in  std_ulogic; -- 1=count up, 0=count down
		cnt_cont  : in  std_ulogic; -- 1=count continous, 0=count single
		cnt_fast  : in  std_ulogic; -- 1=count fast, 0=count slow
		cnt_dec   : in  std_ulogic; -- 1=count decimal, 0=count hex
		-- outputs to d1_soc_seg7:
		write_en  : out std_ulogic; -- enaable to data_reg
		data_reg  : out std_ulogic_vector(31 downto 0); -- data_reg (to bin2seg7)
		ctrl_reg  : out std_ulogic_vector(31 downto 0); -- ctrl_reg (of bin2seg7)
		-- status:
		ledr      : out std_ulogic_vector(9 downto 0) --  status
	);
end counter;

architecture rtl of counter is
	
	-- fsm states:
	type state_type is (s_init, s_idle, s_load, s_setmax, s_cntup, s_cntdown, s_store);
	signal state_ns : state_type; -- next state
	signal state_cs : state_type; -- current state
	
	-- internal signals:
	type int_record is record
		max_value : natural;
		cnt_value : natural;
		ctrl_data : std_ulogic_vector(31 downto 0);
	end record;
	signal int_cmb            : int_record;
	signal int_reg            : int_record;
	-- prescaler:
	constant max_prescale_sim : natural := 2**3; -- only for simulation
	constant max_prescale_syn : natural := 2**25; -- ca. 1 Hz
	signal cnt_prescale       : natural range 0 to max_prescale_syn;
	signal cnt_en             : std_ulogic;
	-- fsm:
	constant EMPTY            : std_ulogic_vector(1 downto 0) := (others => '0');
	signal max_value          : std_ulogic_vector(5 downto 0);
	signal cnt_value          : std_ulogic_vector(5 downto 0);
	signal new_value          : std_ulogic;
	signal ctrl_data          : std_ulogic_vector(31 downto 0);
	
begin
	
	----------------------------------------------------------------------------
	-- prescaler: 50 MHz -> ca. 1 Hz
	----------------------------------------------------------------------------
	p_prescale_reg : process (clk, rst_n)
	begin
		if (rst_n = '0') then
			cnt_en       <= '0';
			cnt_prescale <= 0;
		elsif rising_edge(clk) then
			if cnt_prescale = 0 then
				if (cnt_fast = '1') then
					cnt_prescale <= max_prescale_syn/4 - 1;
					-- synthesis translate_off
					cnt_prescale <= max_prescale_sim/4 - 1;
					-- synthesis translate_on
				else
					cnt_prescale <= max_prescale_syn - 1;
					-- synthesis translate_off
					cnt_prescale <= max_prescale_sim - 1;
					-- synthesis translate_on
				end if;
				cnt_en <= '1';
			else
				cnt_prescale <= cnt_prescale - 1;
				cnt_en       <= '0';
			end if;
		end if;
	end process p_prescale_reg;
	
	----------------------------------------------------------------------------
	-- FSM: Counter with some features
	----------------------------------------------------------------------------
	p_fsm_reg : process (clk, rst_n)
	begin
		if (rst_n = '0') then 
			state_cs          <= s_init;
			int_reg.max_value <= 0;
			int_reg.cnt_value <= 0;
			int_reg.ctrl_data <= (others => '0');
			new_value         <= '0';
			
		elsif rising_edge(clk) then
			state_cs  <= state_ns;
			int_reg   <= int_cmb;
			new_value <= cnt_en;
			
		end if;
	end process p_fsm_reg;
	
	p_fsm_nxt : process (all)
	begin
		-- default
		state_ns <= state_cs;
		
		case state_cs is
			when s_init => 
				state_ns <= s_idle;
			when s_idle => 
				if load_p = '1' then
					state_ns <= s_load;
				elsif setmax_p = '1' then
					state_ns <= s_setmax;
				elsif run_p = '1' then
					if cnt_up = '1' then
						state_ns <= s_cntup;
					else
						state_ns <= s_cntdown;
					end if;
				end if;
			when s_load => 
				if load_p = '1' then
					state_ns <= s_idle;
				end if;
			when s_setmax => 
				if setmax_p = '1' then
					state_ns <= s_idle;
				end if;
			when s_cntup => 
				if run_p = '1' then
					state_ns <= s_store;
				elsif cnt_up = '0' then
					state_ns <= s_cntdown;
				end if;
			when s_cntdown => 
				if run_p = '1' then
					state_ns <= s_store;
				elsif cnt_up = '1' then
					state_ns <= s_cntup;
				end if;
			when s_store => 
				if load_p = '1' then
					state_ns <= s_load;
				elsif setmax_p = '1' then
					state_ns <= s_setmax;
				elsif run_p = '1' then
					if cnt_up = '1' then
						state_ns <= s_cntup;
					else
						state_ns <= s_cntdown;
					end if;
				end if;
			when others => 
				null;
		end case;
	end process p_fsm_nxt;
	
	p_fsm_out : process (all)
	begin
		-- default
		int_cmb           <= int_reg;
		int_cmb.ctrl_data <= (13 => '1', 12 => '1', others => '0'); -- show digits 3-0
		
		case state_cs is
			when s_init => 
				int_cmb.max_value <= 63;
				int_cmb.cnt_value <= 0;
				int_cmb.ctrl_data <= (31 => '1', others => '0'); -- disable all digits
			when s_idle => 
				null;
			when s_load => 
				int_cmb.cnt_value <= to_integer(unsigned(cnt_din));
				int_cmb.ctrl_data <= (
						11     => '1', -- disable digits 3
						10     => '1', -- disable digits 2
						1      => '1', -- blink digits 1
						0      => '1', -- blink digits 0
						others => '0');
			when s_setmax => 
				int_cmb.max_value <= to_integer(unsigned(cnt_din));
				int_cmb.ctrl_data <= ( 
						9      => '1', -- disable digits 1
						8      => '1', -- disable digits 0
						3      => '1', -- blink digits 3
						2      => '1', -- blink digits 2
						others => '0');
			when s_cntup => 
				if cnt_en = '1' then
					if int_reg.cnt_value < int_reg.max_value then
						int_cmb.cnt_value <= int_reg.cnt_value + 1;
					else
						if cnt_cont = '1' then
							int_cmb.cnt_value <= 0;
						else
							int_cmb.cnt_value <= int_reg.cnt_value;
						end if;
					end if;
				end if;
			when s_cntdown => 
				if cnt_en = '1' then
					if int_reg.cnt_value > 0 then
						int_cmb.cnt_value <= int_reg.cnt_value - 1;
					else
						if cnt_cont = '1' then
							int_cmb.cnt_value <= int_reg.max_value;
						else
							int_cmb.cnt_value <= int_reg.cnt_value;
						end if;
					end if;
				end if;
			when s_store => 
				null;
			when others => 
				null;
		end case;
	end process p_fsm_out;
	
	----------------------------------------------------------------------------
	-- output assignments (with type conversion)
	----------------------------------------------------------------------------
	max_value <= std_ulogic_vector(to_unsigned(int_reg.max_value, max_value'length));
	cnt_value <= std_ulogic_vector(to_unsigned(int_reg.cnt_value, cnt_value'length));
	ctrl_reg  <= int_reg.ctrl_data;
	ledr      <= int_reg.ctrl_data(31 downto 28) & int_reg.ctrl_data(5 downto 0);
	
	p_out_reg : process (clk, rst_n)
	begin
		if (rst_n = '0') then
			write_en  <= '0';
			data_reg <= (others => '0');
		elsif rising_edge(clk) then
			write_en <= '1';
			if (cnt_dec = '1') then
				data_reg(23 downto 0) <= std_ulogic_vector(
						f_digits(std_ulogic_vector(cnt_din), 2)     -- digits 5-4         :          
						& f_digits(std_ulogic_vector(max_value), 2) -- digits 3-2
						& f_digits(std_ulogic_vector(cnt_value), 2) -- digits 1-0
				); 
			else
				data_reg(23 downto 0) <= (
						EMPTY & cnt_din 
						& EMPTY & max_value 
						& EMPTY & cnt_value
				);
			end if; 
		end if;
	end process p_out_reg;
	
end rtl;
