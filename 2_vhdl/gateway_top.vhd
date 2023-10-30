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
	signal send_faulty_data : std_ulogic;
	signal pattern : std_ulogic_vector(7 downto 0);
	signal display_mode : std_ulogic;

	-- receiver signals:
	signal 	data_received : std_ulogic; -- 
	signal 	data_valid   : std_ulogic;  --
	signal 	data_rx : std_ulogic_vector(7 downto 0) 

	-- buffer_block signals:
	signal data_rx_ready : std_ulogic; -- 
	signal buffer_rx : std_ulogic_vector(7 downto 0);  --
	signal buffer_pattern : std_ulogic_vector(7 downto 0); 

	signal buffer_tx : std_ulogic_vector(7 downto 0);
	signal buffer_rx_display std_ulogic_vector()
    signal buffer_pattern : std_ulogic_vector(7 downto 0);

	
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
