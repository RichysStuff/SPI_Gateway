-----------------------------------------------------
-- Project : count_binary
-----------------------------------------------------
-- File    : de1_soc_top_symbol.vhd
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

library work;
use work.de1_soc_pkg.all;

entity de1_soc_top is
	port(
		clk_50 : in std_ulogic;
		-- Input Peripherals
		key : in std_ulogic_vector (3 downto 0);
		sw  : in std_ulogic_vector (9 downto 0);
		-- Output Peripherals
		hex0 : out std_ulogic_vector (6 downto 0);
		hex1 : out std_ulogic_vector (6 downto 0);
		hex2 : out std_ulogic_vector (6 downto 0);
		hex3 : out std_ulogic_vector (6 downto 0);
		hex4 : out std_ulogic_vector (6 downto 0);
		hex5 : out std_ulogic_vector (6 downto 0);
		ledr : out std_ulogic_vector (9 downto 0)
	);
	
	-- Declarations
	
end entity de1_soc_top;

architecture struct of de1_soc_top is
	
	-- Architecture declarations
	constant c_cnt_width : natural := 6;
	constant c_clk_div   : natural := 2**25;
	-- Internal signal declarations:
	signal clk           : std_ulogic;
	signal rst_n         : std_ulogic;
	signal key_pulse     : std_ulogic_vector(key'range);
	signal sw_sync       : std_ulogic_vector(sw'range);
	-- :
	signal write_en      : std_ulogic;
	signal data_reg      : std_ulogic_vector(31 downto 0);
	signal ctrl_reg      : std_ulogic_vector(31 downto 0);
	-- Pulses:
	signal run_p         : std_ulogic;
	signal load_p        : std_ulogic;
	signal setmax_p      : std_ulogic;
	-- Counter control:
	signal cnt_din       : std_ulogic_vector(5 downto 0);
	signal cnt_up        : std_ulogic;
	signal cnt_cont      : std_ulogic;
	signal cnt_fast      : std_ulogic;
	signal cnt_dec       : std_ulogic;
	signal max_value     : std_ulogic_vector(5 downto 0);
	signal cnt_value     : std_ulogic_vector(5 downto 0);
	
begin
	
	-- Wrapping between de1_soc and counter
	-- system clock:
	clk <= clk_50;
	-- key:
	run_p    <= key_pulse(1);        -- Start/Stop
	load_p   <= key_pulse(2);        -- Load
	setmax_p <= key_pulse(3);        -- Set Counter Maximum Value
	-- sw:
	cnt_din  <= sw_sync(5 downto 0); -- Load/Max Value
	cnt_up   <= sw_sync(6);          -- Count Direction       :        0=down, 1=up
	cnt_cont <= sw_sync(7);          -- Count Modus         :        0=single, 1=continous
	cnt_fast <= sw_sync(8);          -- Count Speed         :        0=slow, 1=fast
	cnt_dec  <= sw_sync(9);          -- Count Format         :        0=hex, 1=dec
	
	
	-- synchronize the reset
	rsync_1 : entity work.rsync
		generic map (
			g_mode => 0
		)
		port map (
			clk    => clk,
			irst_n => key(0),
			orst_n => rst_n,
			orst   => open
		);
	
	-- edge detection of the keys
	isync_2 : entity work.isync
		generic map (
			g_width => key'length,
			g_inv   => 0,
			g_mode  => 2 -- generate pulse on falling edge
		)
		port map (
			clk     => clk,
			rst_n   => rst_n,
			idata_a => key,
			odata_s => key_pulse
		); 
	-- synchronization of the switches
	isync_1 : entity work.isync
		generic map (
			g_width => sw'length,
			g_inv   => 0,
			g_mode  => 0
		)
		port map (
			clk     => clk,
			rst_n   => rst_n,
			idata_a => sw,
			odata_s => sw_sync
		); 
	-- user design: here it is a counter
	counter_1 : entity work.counter
		port map (
			clk      => clk,
			rst_n    => rst_n,
			run_p    => run_p,
			load_p   => load_p,
			setmax_p => setmax_p,
			cnt_din  => cnt_din,
			cnt_up   => cnt_up,
			cnt_cont => cnt_cont,
			cnt_fast => cnt_fast,
			cnt_dec  => cnt_dec,
			write_en => write_en,
			data_reg => data_reg,
			ctrl_reg => ctrl_reg,
			ledr     => ledr
		); 
	-- conversion from binary to sevensegment (HEX/DEC)
	bin2seg7_1 : entity work.bin2seg7
		generic map (
			g_clk_div => c_clk_div
		)
		port map (
			clk       => clk,
			rst_n     => rst_n,
			wr_en     => write_en,
			data_reg  => data_reg,
			ctrl_reg  => ctrl_reg,
			hex5      => hex5,
			hex4      => hex4,
			hex3      => hex3,
			hex2      => hex2,
			hex1      => hex1,
			hex0      => hex0
		);
	
end architecture struct;
