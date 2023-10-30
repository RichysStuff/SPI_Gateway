-----------------------------------------------------
-- Project : SPI gateway
-----------------------------------------------------
-- File    : gateway_top.vhd
-- Library : 
-- Author  : richard.wassmer@students.fhnw.ch
-- Company : 
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
use work.gateway_pkg.all;

entity gateway is
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
		ledr : out std_ulogic_vector (9 downto 0);

		-- bus connections Input
		spi_data_in : in std_logic;
		spi_clk_in : in std_logic;
		spi_cs_in : in std_logic;
		
		-- bus connection Output
		spi_data_out : out std_logic;
		spi_clk_out : out std_logic;
		spi_cs_out : out std_logic
	);
	
	-- Declarations
	
end entity gateway;

architecture struct of gateway is
	
	-- Internal signal declarations:
	signal clk           : std_ulogic;
	signal rst_n         : std_ulogic;

	-- synchronizer signals
	signal send_data : std_ulogic;
	signal send_one_faulty_bit : std_ulogic;
	signal send_two_faulty_bits : std_ulogic;
	signal select_tx_data_source : std_ulogic; 
	signal pattern : std_ulogic_vector(7 downto 0);
	signal display_mode : std_ulogic;

	-- receiver signals:
	signal 	data_received : std_ulogic; -- 
	signal 	data_valid   : std_ulogic;  --
	signal 	data_rx : std_ulogic_vector(7 downto 0);

	-- buffer_block signals:
	signal data_rx_ready : std_ulogic; -- 
	signal buffer_rx : std_ulogic_vector(7 downto 0);  --
	signal buffer_pattern : std_ulogic_vector(7 downto 0); 
	signal buffer_rx_display : std_ulogic_vector(7 downto 0);
	signal buffer_tx : std_ulogic_vector(7 downto 0);

begin
	
	-- Wrapping between de1_soc and counter
	-- system clock:
	clk <= clk_50;
	
	-- synchronize the reset
	rsync_1 : entity work.rsync
		generic map (
			g_mode => 0
		)
		port map (
			clk    => clk,
			irst_n => key(1),
			orst_n => rst_n,
			orst   => open
		);
	
	-- synchronisation of all inputs and generating control signal for other blocks
	synchronizer_1 : entity work.synchronizer
		port map (
			clk=> clk,
			rst_n => rst_n,
			
			slide_switches_in => sw,
			buttons_in => key,
			
			send_data_out => send_data,
			send_one_faulty_bit_out => send_one_faulty_bit,
			send_two_faulty_bits_out => send_two_faulty_bits,
			select_tx_data_source_out => select_tx_data_source,
			pattern_out => pattern,
			display_mode_out => display_mode 
		); 


	-- encode and send data 
	transmitter_1 : entity work.transmitter
		port map (
			clk  => clk,
			irst_n => rst_n,
			
			send_data_in => send_data, 
			send_one_faulty_bit_in => send_one_faulty_bit,
			send_two_faulty_bits_in => send_two_faulty_bits,
			data_tx_in => buffer_tx,
		
			spi_cs_out => spi_cs_out,
			spi_clk_out => spi_clk_out,
			spi_data_out => spi_data_out 
		); 

	-- receive and decode data
	receiver_1 : entity work.receiver
		port map(
			clk  => clk,
			irst_n => rst_n,

			spi_data_in => spi_data_in,
			spi_cs_in => spi_cs_in,
			spi_clk_in => spi_clk_in,

			data_received_out => data_received, 
			data_valid_out => data_valid,
			data_rx_out => data_rx 
		);
	
	-- show rx buffer or pattern on displays
	display_1 : entity work.display
	port map(
		clk=>clk,
		irst_n=>rst_n,

		data_valid_in=>data_valid,
		display_mode_in=>display_mode,
        display_pattern_in=>pattern,
        display_rx_in=>buffer_rx_display,

		seg_0_out=>hex0,
        seg_1_out=>hex1,
        seg_2_out=>hex2,
        seg_3_out=>hex3

	);

	buffer_block_1 : entity work.buffer_block
	port map(
		clk => clk,
		irst_n => rst_n,

		data_rx_ready_in => data_valid, 
		buffer_rx_in => buffer_rx,
		buffer_pattern_in => pattern, 
		source_selection_in => select_tx_data_source,

		buffer_tx_out => buffer_tx,
        buffer_pattern_out => buffer_pattern,
        buffer_rx_out => buffer_rx_display
	);
	
end architecture struct;
