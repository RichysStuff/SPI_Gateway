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

package de1_soc_pkg is
	
	-- Component Declarations
	component rsync is
		generic (
			g_mode : natural := 0
		);
		port (
			clk    : in  std_ulogic;
			irst_n : in  std_ulogic;
			orst_n : out std_ulogic;
			orst   : out std_ulogic
		);
	end component rsync;
	
	component isync is
		generic (
			g_width : natural := 2;
			g_inv   : natural := 0;
			g_mode  : natural := 0
		);
		port (
			clk     : in  std_ulogic;
			rst_n   : in  std_ulogic;
			idata_a : in  std_ulogic_vector(g_width-1 downto 0);
			odata_s : out std_ulogic_vector(g_width-1 downto 0)
		);
	end component isync; 
	
	component bin2seg7 is
		generic (
			g_clk_div : natural := 2**25
		);
		port (
			clk      : in  std_ulogic;
			rst_n    : in  std_ulogic;
			wr_en    : in  std_ulogic;
			data_reg : in  std_ulogic_vector(31 downto 0);
			ctrl_reg : in  std_ulogic_vector(31 downto 0);
			hex5     : out std_ulogic_vector(6 downto 0);
			hex4     : out std_ulogic_vector(6 downto 0);
			hex3     : out std_ulogic_vector(6 downto 0);
			hex2     : out std_ulogic_vector(6 downto 0);
			hex1     : out std_ulogic_vector(6 downto 0);
			hex0     : out std_ulogic_vector(6 downto 0)
		);
	end component bin2seg7;
	
	component counter is
		port (
			clk      : in  std_ulogic;
			rst_n    : in  std_ulogic;
			run_p    : in  std_ulogic;
			load_p   : in  std_ulogic;
			setmax_p : in  std_ulogic;
			cnt_din  : in  std_ulogic_vector(5 downto 0);
			cnt_up   : in  std_ulogic;
			cnt_cont : in  std_ulogic;
			cnt_fast : in  std_ulogic;
			cnt_dec  : in  std_ulogic;
			write_en : out std_ulogic;
			data_reg : out std_ulogic_vector(31 downto 0);
			ctrl_reg : out std_ulogic_vector(31 downto 0);
			ledr     : out std_ulogic_vector(9 downto 0)
		);
	end component counter; 
end package de1_soc_pkg;
