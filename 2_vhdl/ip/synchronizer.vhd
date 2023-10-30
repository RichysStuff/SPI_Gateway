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

-- Keys         : 3   send pattern
--                2   send pattern with one error
--                1   send pattern with two errors
--
-- Switches     : 9   select source : 1=pattern / 0=buffer
--                8   select display: 1=pattern / 0=received data
--                7-0 pattern

entity synchronizer is
	port(
		clk     : in  std_ulogic; -- clock
		rst_n   : in  std_ulogic; -- asynchronous reset
		
		slide_switches_in : in  std_ulogic_vector(9 downto 0); -- asynchronous inputs
		buttons_in : in std_ulogic_vector(3 downto 0); -- asynchronous inputs
		
		send_data_out : out std_ulogic;
		send_one_faulty_bit_out : out std_ulogic;
		send_two_faulty_bits_out : out std_ulogic;
		select_tx_data_source_out : out std_ulogic; 
		pattern_out : out std_ulogic_vector(7 downto 0);
		display_mode_out : out std_ulogic -- 0 is rx buffer; 1 is pattern
	);
end synchronizer;

architecture rtl of synchronizer is
	signal slide_switches_1 : std_ulogic_vector(slide_switches_in'range); -- 1st stage
	signal slide_switches_2 : std_ulogic_vector(slide_switches_in'range); -- 2nd stage
	signal buttons_1 : std_ulogic_vector(buttons_in'range); -- 1st stage
	signal buttons_2 : std_ulogic_vector(buttons_in'range); -- 2nd stage
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
			
			slide_switches_1 <= slide_switches_in;
			slide_switches_2 <= slide_switches_1;

			buttons_1 <= buttons_in;
			buttons_2 <= buttons_1;
		end if;
	end process p_sync;

	send_data_out <= buttons_2(1);
	send_one_faulty_bit_out <= buttons_2(2);
	send_two_faulty_bits_out <= buttons_2(3);

	select_tx_data_source_out <= slide_switches_2(9);
	display_mode_out <= slide_switches_2(8);
	pattern_out <= slide_switches_2(7 downto 0);

end rtl;
