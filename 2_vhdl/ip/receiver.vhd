-- -----------------------------------------------------------------------------
-- Filename: receiver.vhd
-- Author  : R. Wassmer
-- Date    : 2023.10.30
-- Content : receive data over SPI protokoll 
-- -----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity receiver is
	port(
		clk    : in  std_ulogic; -- clock
		irst_n : in  std_ulogic; -- asynchronous reset, active low

		spi_data_in : in std_ulogic;
		spi_cs_in : in std_ulogic;
		spi_clk_in : in std_logic;

		data_received_out : out std_ulogic; -- 
		data_valid_out   : out std_ulogic;  --
		data_rx_out : out std_ulogic_vector(7 downto 0) 
	);
end receiver;

architecture rtl of receiver is
	type fsm_state is (IDLE, RECEIVE);
	signal rst_reg    : std_ulogic_vector(1 downto 0);
	signal rx_buffer : std_ulogic_vector(data_rx_out'range);
	signal current_state : fsm_state;
	signal next_state : fsm_state;

begin

	p_fsm : process(irst_n, clk)
	begin
		if irst_n = '0' then
			rx_buffer <= (others => '0');

		elsif rising_edge(clk) then
			case current_state is
			
				when IDLE =>
					if falling_edge(spi_cs_in) then
						next_state <= RECEIVE;
					else
						next_state <= current_state;
					end if;


				when RECEIVE =>
					if rising_edge(spi_cs_in) then
						next_state <= IDLE;
					else
						next_state <= current_state;
					end if;

				when others =>
					next_state <= IDLE;

			end case;
		end if;

	end process p_fsm;

	
end rtl;
