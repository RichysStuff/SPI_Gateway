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

package gateway_pkg is
	
	-- Component Declarations
	component synchronizer is
			port(
				clk     : in  std_ulogic; -- clock
				rst_n   : in  std_ulogic; -- asynchronous reset
				slide_switches_in : in  std_ulogic_vector(9 downto 0); -- asynchronous inputs
				buttons_in : in std_ulogic_vector(3 downto 0) -- asynchronous inputs
				slide_switches_out : out std_ulogic_vector(9 downto 0);
				buttons_out: out std_ulogic_vector(3 downto 0);
			);
	end component synchronizer;
	
	component transmitter is
		port(
		clk    : in  std_ulogic; -- clock
		irst_n : in  std_ulogic; -- asynchronous reset, active low
		send_data : in std_ulogic; -- 
		emit_faulty_data   : in std_ulogic;  --
		spi_data_out : out std_ulogic 
	);
	end component transmitter;
	
	component receiver port(
		clk    : in  std_ulogic; -- clock
		irst_n : in  std_ulogic; -- asynchronous reset, active low
		data_received : in std_ulogic; -- 
		data_valid   : in std_ulogic;  --
		data_out : out std_ulogic_vector(7 downto 0) 
	);
	end component receiver;

end package gateway_pkg;
