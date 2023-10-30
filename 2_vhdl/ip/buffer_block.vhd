-- -----------------------------------------------------------------------------
-- Filename: buffer_block.vhd
-- Author  : R. Wassmer, Daniel Bachmann
-- Date    : 2023.10.30
-- Content : store data 
-- -----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity buffer_block is
	port(
		clk    : in  std_ulogic; -- clock
		irst_n : in  std_ulogic; -- asynchronous reset, active low

		data_rx_ready_in : in std_ulogic; -- 
		buffer_rx_in : in std_ulogic_vector(7 downto 0);  --
		buffer_pattern_in : in std_ulogic_vector(7 downto 0); 

		buffer_tx_out : out std_ulogic_vector(7 downto 0);
        buffer_pattern_out : out std_ulogic_vector(7 downto 0);
        buffer_rx_out : out std_ulogic_vector(7 downto 0) 
	);
end buffer_block;

architecture rtl of buffer_block is
	signal rst_reg    : std_ulogic_vector(1 downto 0);
begin
	
	
	p_reset : process(irst_n, clk)
	begin
		if irst_n = '0' then
			rst_reg <= (others => '0'); -- assert asynchronous
            buffer_tx_out <= (others => '0');
        	buffer_pattern_out <= (others => '0');
        	buffer_rx_out <= (others => '0'); 
        
		elsif rising_edge(clk) then
			rst_reg <= rst_reg(0) & '1'; -- deassert synchronous
		end if;
	end process p_reset;
	
end rtl;
