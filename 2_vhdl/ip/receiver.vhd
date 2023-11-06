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
		spi_clk_in : in std_ulogic;

		data_received_out : out std_ulogic; -- 
		data_valid_out   : out std_ulogic;  --
		data_rx_out : out std_ulogic_vector(7 downto 0) 
	);
end receiver;

architecture rtl of receiver is
	type fsm_state is (IDLE, RECEIVE);
	signal rx_buffer : std_ulogic_vector(8 downto 0);
	signal bit_index : integer range 0 to 9; 
	signal current_state : fsm_state := IDLE;
	
	signal sync_spi_data_in : std_ulogic_vector(2 downto 0);
	signal sync_spi_cs_in : std_ulogic_vector(3 downto 0);
	signal sync_spi_clk_in : std_ulogic_vector(3 downto 0);

begin
	-- synchronize spi input signals to system clk
	p_sync_spi_inputs : process(irst_n, clk)
	begin
		if irst_n = '0' then
			sync_spi_data_in <= (others => '0');
			sync_spi_cs_in <= (others => '1');
			sync_spi_clk_in <= (others => '0');
		elsif rising_edge(clk) then
			sync_spi_data_in <= sync_spi_data_in(1 downto 0) & spi_data_in;
			sync_spi_cs_in <= sync_spi_cs_in(2 downto 0) & spi_cs_in;
			sync_spi_clk_in <= sync_spi_clk_in(2 downto 0) & spi_clk_in;
		end if;
		
	end process p_sync_spi_inputs;

	-- SPI specification
	-- 8 databits
	-- 1 parity bit (even)

	p_fsm : process(irst_n, clk)
	variable v_parity_target : std_ulogic := '0';
	variable next_state : fsm_state := IDLE;
	begin
		if irst_n = '0' then
			rx_buffer <= (others => '0');
			next_state := IDLE;

			data_received_out <= '0';
			data_valid_out <= '1';
			data_rx_out <= (others => '0');

		elsif rising_edge(clk) then
			case current_state is
			
				when IDLE =>
					if sync_spi_cs_in(3) = '1' and sync_spi_cs_in(2) =  '0' then  -- falling edge sync_spi_cs_in
						next_state := RECEIVE;
						data_rx_out <= (others => '0');
					else
						next_state := current_state;
					end if;
					
					bit_index <= 0;
					rx_buffer <= (others => '0');

					data_valid_out <= '1';
					data_received_out <= '0';


				when RECEIVE =>
					if sync_spi_cs_in(3) = '0' and sync_spi_cs_in(2) = '1' then  -- rising edge sync_spi_cs_in
						next_state := IDLE;
					else
						next_state := current_state;
					end if;
					
					if sync_spi_clk_in(3) = '0' and sync_spi_clk_in(2) = '1' and bit_index < 9 then  -- rising edge sync_spi_clk_in 
						rx_buffer <= (rx_buffer(8 downto bit_index+1) & sync_spi_data_in(2) & rx_buffer(bit_index-1 downto 0));
						bit_index <= bit_index + 1;

						data_received_out <= '0';
						data_valid_out <= '1';

					elsif bit_index >= 9 then
						
						-- calculate even parity bit
						v_parity_target := xor rx_buffer; 
						
						-- check if message has parity error
						if rx_buffer(0) /= v_parity_target then
							data_valid_out <= '0';
						else 
							data_valid_out <= '1';
						end if;
						
						data_rx_out <= rx_buffer(8 downto 1);
						data_received_out <= '1';
						
					end if;

				when others =>
					next_state := IDLE;

					data_received_out <= '0';
					data_valid_out <= '1';
					data_rx_out <= (others => '0');

			end case;
			current_state <= next_state;
		end if;
		

	end process p_fsm;

	
end rtl;
