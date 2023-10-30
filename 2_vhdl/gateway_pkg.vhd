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
			buttons_in : in std_ulogic_vector(3 downto 0); -- asynchronous inputs
			
			send_data_out : out std_ulogic;
			send_faulty_data_out : out std_ulogic;
			pattern_out : out std_ulogic_vector(7 downto 0);
			display_mode_out : out std_ulogic -- 0 is rx buffer; 1 is pattern
	);
		port(
			clk     : in  std_ulogic; -- clock
			rst_n   : in  std_ulogic; -- asynchronous reset
			
			slide_switches_in : in  std_ulogic_vector(9 downto 0); -- asynchronous inputs
			buttons_in : in std_ulogic_vector(3 downto 0); -- asynchronous inputs
			
			send_data_out : out std_ulogic;
			send_faulty_data_out : out std_ulogic;
			pattern_out : out std_ulogic_vector(7 downto 0);
			display_mode_out : out std_ulogic -- 0 is rx buffer; 1 is pattern
	);
	end component synchronizer;
	
	component transmitter is
		port(
			clk    : in  std_ulogic; -- clock
			clk    : in  std_ulogic; -- clock
		irst_n : in  std_ulogic; -- asynchronous reset, active low

		send_data_in : in std_ulogic; -- 
		emit_faulty_data_in : in std_ulogic;  --
		data_tx_in : in std_ulogic_vector(7 downto 0);
		
		spi_cs_out : out std_ulogic;
		spi_clk_out : out std_ulogic;
		spi_data_out : out std_ulogic

		send_data_in : in std_ulogic; -- 
		emit_faulty_data_in : in std_ulogic;  --
		data_tx_in : in std_ulogic_vector(7 downto 0);
		
		spi_cs_out : out std_ulogic;
		spi_clk_out : out std_ulogic;
		spi_data_out : out std_ulogic
	);
	end component transmitter;
	
	component receiver is port(
	component receiver is port(
		clk    : in  std_ulogic; -- clock
		irst_n : in  std_ulogic; -- asynchronous reset, active low

		spi_data_in : in std_ulogic;
		spi_cs_in : in std_ulogic;
		spi_clk_in : in std_logic;

		data_received_out : out std_ulogic; -- 
		data_valid_out   : out std_ulogic;  --
		data_rx_out : out std_ulogic_vector(7 downto 0) 

		spi_data_in : in std_ulogic;
		spi_cs_in : in std_ulogic;
		spi_clk_in : in std_logic;

		data_received_out : out std_ulogic; -- 
		data_valid_out   : out std_ulogic;  --
		data_rx_out : out std_ulogic_vector(7 downto 0) 
	);
	end component receiver;

	component buffer_block is port(
		clk    : in  std_ulogic; -- clock
		irst_n : in  std_ulogic; -- asynchronous reset, active low

		data_rx_ready_in : in std_ulogic; -- 
		buffer_rx_in : in std_ulogic_vector(7 downto 0);  --
		buffer_pattern_in : in std_ulogic_vector(7 downto 0); 

		buffer_tx_out : out std_ulogic_vector(7 downto 0);
        buffer_pattern_out : out std_ulogic_vector(7 downto 0);
        buffer_rx_out : out std_ulogic_vector(7 downto 0)  
	);
	end component buffer_block;

	component display is port(
		clk    : in  std_ulogic; -- clock
		irst_n : in  std_ulogic; -- asynchronous reset, active low
		
		data_valid_in : in std_ulogic; -- error in data
		display_mode_in   : in std_ulogic;  -- output mode
        display_pattern_in : in std_ulogic_vector(7 downto 0) -- current input pattern
        display_rx_in : in std_ulogic_vector (7 downto 0) -- data from RX Buffer
		
		7_seg_0_out : out std_ulogic_vector(6 downto 0) -- 7 segment 0
        7_seg_1_out : out std_ulogic_vector(6 downto 0) -- 7 segment 1
        7_seg_2_out : out std_ulogic_vector(6 downto 0) -- 7 segment 2
        7_seg_3_out : out std_ulogic_vector(6 downto 0) -- 7 segment 3

	);
	end component display;
	
	component r_sync is generic (
		g_mode : natural := 0
	);
	port(
		clk    : in  std_ulogic; -- clock
		irst_n : in  std_ulogic; -- asynchronous reset, active low
		orst_n : out std_ulogic; -- partially/full synchronized reset, active low
		orst   : out std_ulogic  -- partially/full synchronized reset, active high
	);
	end component r_sync;

end package gateway_pkg;
