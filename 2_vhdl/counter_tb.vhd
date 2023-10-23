-----------------------------------------------------
-- Project : counter_tb
-----------------------------------------------------
-- File    : count1_binary_tb_symbol.vhd
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

entity counter_tb is
end entity counter_tb;

architecture struct of counter_tb is
	
	constant N       : natural := 6; 
	-- Internal signal declarations:
	signal clk       : std_ulogic;
	signal rst_n     : std_ulogic;
	signal run_p     : std_ulogic;
	signal load_p    : std_ulogic;
	signal setmax_p  : std_ulogic;
	signal cnt_din   : std_ulogic_vector(N-1 downto 0);
	signal cnt_up    : std_ulogic;
	signal cnt_cont  : std_ulogic;
	signal cnt_fast  : std_ulogic;
	signal cnt_dec   : std_ulogic;
	signal write_en  : std_ulogic;
	signal data_reg  : std_ulogic_vector(31 downto 0);
	signal ctrl_reg  : std_ulogic_vector(31 downto 0);
	signal ledr      : std_ulogic_vector(9 downto 0); 
	
	-- Component Declarations
	component counter is
		-- generic (
		-- 	N : natural := 2
		-- );
		port (
			clk       : in  std_ulogic;
			rst_n     : in  std_ulogic;
			run_p     : in  std_ulogic;
			load_p    : in  std_ulogic;
			setmax_p  : in  std_ulogic;
			cnt_din   : in  std_ulogic_vector(N-1 downto 0);
			cnt_up    : in  std_ulogic;
			cnt_cont  : in  std_ulogic;
			cnt_fast  : in  std_ulogic;
			cnt_dec   : in  std_ulogic;
			write_en  : out std_ulogic;
			data_reg : out std_ulogic_vector(31 downto 0);
			ctrl_reg  : out std_ulogic_vector(31 downto 0);
			ledr      : out std_ulogic_vector(9 downto 0)
		);
	end component counter;
	
	component counter_verify is
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
			data_reg : in  std_ulogic_vector(31 downto 0);
			ctrl_reg  : in  std_ulogic_vector(31 downto 0);
			ledr      : in  std_ulogic_vector(9 downto 0)
		);
	end component counter_verify;
	
begin
	
	-- Instance port mappings.
	counter_1 : entity work.counter
		-- generic map (
		-- 	N => N
		-- )
		port map (
			clk       => clk,
			rst_n     => rst_n,
			run_p     => run_p,
			load_p    => load_p,
			setmax_p  => setmax_p,
			cnt_din   => cnt_din,
			cnt_up    => cnt_up,
			cnt_cont  => cnt_cont,
			cnt_fast  => cnt_fast,
			cnt_dec   => cnt_dec,
			write_en  => write_en,
			data_reg => data_reg,
			ctrl_reg  => ctrl_reg,
			ledr      => ledr
		); 
	counter_verify_1 : entity work.counter_verify
		generic map (
			N => N
		)
		port map (
			clk       => clk,
			rst_n     => rst_n,
			run_p     => run_p,
			load_p    => load_p,
			setmax_p  => setmax_p,
			cnt_din   => cnt_din,
			cnt_up    => cnt_up,
			cnt_cont  => cnt_cont,
			cnt_fast  => cnt_fast,
			cnt_dec   => cnt_dec,
			write_en  => write_en,
			data_reg => data_reg,
			ctrl_reg  => ctrl_reg,
			ledr      => ledr
		); 
	
end architecture struct;
