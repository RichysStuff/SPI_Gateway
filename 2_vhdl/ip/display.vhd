-- -----------------------------------------------------------------------------
-- Filename: display.vhd
-- Author  : D. Bachmann
-- Date    : 2023.10.30
-- Content : display data or pattern 
-- -----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity receiver is
	port(
		clk    : in  std_ulogic; -- clock
		irst_n : in  std_ulogic; -- asynchronous reset, active low
		data_received : in std_ulogic; -- 
		data_valid   : in std_ulogic;  --
		data_out : out std_ulogic_vector(7 downto 0) 
	);
end receiver;

architecture rtl of receiver is
	signal rst_reg    : std_ulogic_vector(1 downto 0);
begin
	
	
	p_reset : process(irst_n, clk)
	begin
		if irst_n = '0' then
			rst_reg <= (others => '0'); -- assert asynchronous
		elsif rising_edge(clk) then
			rst_reg <= rst_reg(0) & '1'; -- deassert synchronous
		end if;
	end process p_reset;
	
	data_out <= (others => '0');
	
end rtl;