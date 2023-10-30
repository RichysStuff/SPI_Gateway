-- -----------------------------------------------------------------------------
-- Filename: synchronizer.vhd
-- Author  : R. Wassmer
-- Date    : 30.10.2023
-- Content : Synchronization of input vectors
--           
-- -----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity synchronizer is
	port(
		clk     : in  std_ulogic; -- clock
		rst_n   : in  std_ulogic; -- asynchronous reset
		slide_switches_in : in  std_ulogic_vector(9 downto 0); -- asynchronous inputs
		buttons_in : in std_ulogic_vector(3 downto 0) -- asynchronous inputs
		slide_switches_out : out std_ulogic_vector(9 downto 0);
		buttons_out: out std_ulogic_vector(3 downto 0)

	);
end synchronizer;

architecture rtl of synchronizer is
	signal slide_switches_1 : std_ulogic_vector(slide_switches'range); -- 1st stage
	signal slide_switches_2 : std_ulogic_vector(slide_switches'range); -- 2nd stage
	signal buttons_1 : std_ulogic_vector(buttons'range); -- 1st stage
	signal buttons_2 : std_ulogic_vector(buttons'range); -- 2nd stage
begin
	
	-- reset generation
	p_sync : process(rst_n, clk)
	begin
		if rst_n = '0' then
			-- init
			slide_switches_1 <= (others => '0');
			slide_switches_2 <= (others => '0');
			buttons_1 <= (others => '0');
			buttons_2 <= (others => '0');

		elsif rising_edge(clk) then
			-- synchronize with two flipflops
			
			slide_switches_1 <= slide_switches;
			slide_switches_2 <= slide_switches_1;

			buttons_1 <= buttons;
			buttons_2 <= buttons_1;
		end if;
	end process p_sync;

	slide_switches_out <= slide_switches_2;
	buttons_out <= buttons_2;
	
end rtl;
