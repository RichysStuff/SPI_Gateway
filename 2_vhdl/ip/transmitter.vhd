-- -----------------------------------------------------------------------------
-- Filename: transmitter.vhd
-- Author  : R. Wassmer
-- Date    : 2023.10.30
-- Content : Transmit data over SPI protokoll 
-- -----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity transmitter is
	port(
		clk    : in  std_ulogic; -- clock
		irst_n : in  std_ulogic; -- asynchronous reset, active low

		send_data_in : in std_ulogic; -- 
		emit_faulty_data_in : in std_ulogic;  --
		data_tx_in : in std_ulogic_vector(7 downto 0);
		
		spi_cs_out : out std_ulogic;
		spi_clk_out : out std_ulogic;
		spi_data_out : out std_ulogic 
	);
end transmitter;

architecture rtl of transmitter is
	signal rst_reg    : std_ulogic_vector(1 downto 0);
begin
	
	
	p_reset : process(irst_n, clk)
	begin
		if irst_n = '0' then
			rst_reg <= (others => '0'); -- assert asynchronous
			spi_cs_out <= (others => '0');
			spi_clk_out <= (others => '0');
			spi_data_out <= (others => '0');

		elsif rising_edge(clk) then
			rst_reg <= rst_reg(0) & '1'; -- deassert synchronous
		end if;
	end process p_reset;
	
end rtl;
