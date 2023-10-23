-----------------------------------------------------
-- Project : counter_verify
-----------------------------------------------------
-- File    : counter_verify_sim.vhd
-- Library : count_binary_lib
-- Author  : michael.pichler@fhnw.ch
-- Company : Institute of Microelectronics (IME) FHNW
-- Copyright(C) IME
-----------------------------------------------------
-- Last commit:
--   $Author::                                      $
--      $Rev::                                      $
--     $Date::             $
-----------------------------------------------------
-- Description :
-----------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_verify is
	generic (
		N : natural := 2
	);
	port (
		clk       : out std_ulogic;
		rst_n     : out std_ulogic;
		run_p     : out std_ulogic;
		load_p    : out std_ulogic;
		setmax_p  : out std_ulogic;
		cnt_din   : out std_ulogic_vector(N-1 downto 0);
		cnt_up    : out std_ulogic;
		cnt_cont  : out std_ulogic;
		cnt_fast  : out std_ulogic;
		cnt_dec   : out std_ulogic;
		write_en  : in  std_ulogic;
		data_reg  : in  std_ulogic_vector(31 downto 0);
		ctrl_reg  : in  std_ulogic_vector(31 downto 0);
		ledr      : in  std_ulogic_vector(9 downto 0)
	);
	
	-- Declarations
	
end entity counter_verify;

architecture sim of counter_verify is
	constant c_clk_cycle : time := 20 ns;
	constant c_delay     : time := 2 ns;
	signal sim_end       : boolean;
	
	signal cnt_value : std_ulogic_vector(N-1 downto 0);
	
begin
	
	p_clock_reset : process
	begin
		rst_n <= transport '0', '1' after 3*c_clk_cycle;
		l_clk : while (not sim_end) loop
			clk <= transport '0', '1' after c_clk_cycle/2;
			wait for c_clk_cycle;
		end loop l_clk;
		
		--report "Process p_clock_reset stopped";
		clk <= '0';
		wait;
	end process p_clock_reset;
	
	p_control : process
	begin
		sim_end <= false;
		
		report "Initialization";
		run_p    <=  '0';
		load_p   <=  '0';
		setmax_p <=  '0';
		-- :
		cnt_din   <= (others => '0');
		cnt_up    <= '1'; -- 
		cnt_cont  <= '1';
		cnt_fast  <= '0';
		cnt_dec   <= '0';
		wait for 5*c_clk_cycle;
		
		report "Set max_value to value 9";
		setmax_p <= '1', '0' after c_clk_cycle;
		cnt_din  <= std_ulogic_vector(to_unsigned(9, N));
		wait for 5*c_clk_cycle;
		setmax_p <= '1', '0' after c_clk_cycle;
		wait for 5*c_clk_cycle;

		report "Counting up twice from 0 to 9 and stop";
		run_p <= '1', '0' after c_clk_cycle;
		wait until cnt_value = std_ulogic_vector(to_unsigned(9, N));
		wait until cnt_value = std_ulogic_vector(to_unsigned(0, N));
		cnt_cont <= '0' after 2*c_clk_cycle;
		wait until cnt_value = std_ulogic_vector(to_unsigned(9, N));
		wait for 10*c_clk_cycle;
		run_p <= '1', '0' after c_clk_cycle;
		wait for 10*c_clk_cycle;
		wait until falling_edge(clk);
		
		report "Load counter with value 7, change direction to down and count twice from 7 to 0 and stop";
		load_p <= '1', '0' after c_clk_cycle;
		cnt_din      <= std_ulogic_vector(to_unsigned(7, N));
		wait for 5*c_clk_cycle;
		load_p <= '1', '0' after c_clk_cycle;
		cnt_up   <= '0';
		cnt_cont <= '1';
		wait for 5*c_clk_cycle;

		run_p    <= '1', '0' after c_clk_cycle;
		wait until cnt_value = std_ulogic_vector(to_unsigned(0, N));
		wait until cnt_value = std_ulogic_vector(to_unsigned(7, N));
		cnt_cont <= '0' after 2*c_clk_cycle;
		wait until cnt_value = std_ulogic_vector(to_unsigned(0, N));
		wait for 10*c_clk_cycle;
		run_p <= '1', '0' after c_clk_cycle;
		wait for 10*c_clk_cycle;
		wait until falling_edge(clk);
		
		report "Change to fast counting"; 
		cnt_up   <= '1';
		cnt_fast <= '1';
		wait for 5*c_clk_cycle;

		run_p    <= '1', '0' after c_clk_cycle;
		wait until cnt_value = std_ulogic_vector(to_unsigned(7, N));
		wait for 10*c_clk_cycle;
		
		sim_end <= true;
		report "Process p_end stopped";
		wait;
	end process p_control;
	
	p_inputs : process (all)
	begin
		cnt_value <= data_reg (5 downto 0);
	end process p_inputs;
	
end architecture sim;
	 