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

		send_data_in : in std_ulogic; 
		send_one_faulty_bit_in : in std_ulogic;
		send_two_faulty_bits_in : in std_ulogic;

		data_tx_in : in std_ulogic_vector(7 downto 0);
		
		spi_cs_out : out std_ulogic;
		spi_clk_out : out std_ulogic;
		spi_data_out : out std_ulogic 
	);
end transmitter;

architecture rtl of transmitter is
	signal rst_reg    : std_ulogic_vector(1 downto 0);
	signal cnt : integer range 9 downto 0;
	signal freq : integer range 11 downto 0;
	signal stored_data : std_ulogic_vector(8 downto 0);
	signal spi_clk : std_ulogic;
	signal prev_data_in_state: std_ulogic;
	signal data_in_edge: std_logic;
	signal prev_one_faulty: std_ulogic;
	signal one_faulty_edge: std_ulogic;
	signal prev_two_faulty: std_ulogic;
	signal two_faulty_edge: std_ulogic;
  
	type t_state is (
	  idle,
	  set_cs_n,
	  sck_low,
	  sck_high,
	  delay
	);
  
	signal current_state : t_state;
	signal next_state : t_state;
begin
	
	
	p_reset : process(irst_n, clk)
	begin
		if irst_n = '0' then
			rst_reg <= (others => '0'); -- assert asynchronous
		elsif rising_edge(clk) then
			rst_reg <= rst_reg(0) & '1'; -- deassert synchronous
		end if;
	end process p_reset;

	p_store : process(irst_n, clk)
	begin
		if irst_n = '0' then
			stored_data <= (others => '0'); 
		elsif rising_edge(clk) then
			if data_in_edge = '1' then
				stored_data <= data_tx_in & xor data_tx_in;
			elsif one_faulty_edge = '1' then
				stored_data <= data_tx_in & xor data_tx_in;
				stored_data(8) <= not stored_data(8);
			elsif two_faulty_edge = '1' then
				stored_data <= data_tx_in & xor data_tx_in;
				stored_data(7) <= not stored_data(7);
				stored_data(5) <= not stored_data(5);
			end if;
		end if;
	end process;

	
	p_next_state : process(all)
	begin
		if current_state = idle then
			if data_in_edge = '1' then
				next_state <= set_cs_n;
			elsif one_faulty_edge = '1' then
				next_state <= set_cs_n;
			elsif two_faulty_edge ='1' then
				next_state <= set_cs_n;
			else
				next_state <= idle;
			end if;
		elsif spi_clk = '1' then
			case current_state is
			when set_cs_n => 
					next_state <= sck_low;
			when sck_low => 
					next_state <= sck_high;
			when sck_high => 			
				if cnt = 0 then 
					next_state <= delay;
				else
					next_state <= sck_low;
				end if;
			when delay =>
					next_state <= idle;
			when others =>
				next_state <= idle;
			end case;
		end if;
	end process p_next_state;
	
	p_output : process(all)
	begin
		case current_state is
		when idle => 
			spi_cs_out <= '1';
			spi_clk_out  <= '0';
			spi_data_out  <= '0';
		when set_cs_n => 
			spi_cs_out <= '0';
			spi_clk_out  <= '0';
			spi_data_out  <= '0';
		when sck_low => 
			spi_cs_out <= '0';
			spi_clk_out  <= '0';
			spi_data_out  <= stored_data(cnt);
		when sck_high => 
			spi_cs_out <= '0';
			spi_clk_out  <= '1';
			spi_data_out  <= stored_data(cnt);
		when delay =>
			spi_cs_out <= '0';
			spi_clk_out  <= '0';
			spi_data_out  <= '0';
		end case;
	end process p_output;
	

	p_count : process(irst_n, clk)
	begin
		if irst_n = '0' then
		cnt <= 8;
		elsif rising_edge(clk) then
			if spi_clk = '1' then
				if current_state = sck_high then
					if cnt = 0 then
						cnt <= 8;
					else
						cnt <= cnt - 1;
					end if;
				end if;
        	end if;
		end if;
	end process p_count;
	  

	p_current_stat: process(clk, irst_n)
	begin
		if irst_n = '0' then
			current_state <= idle;
		elsif rising_edge(clk) then
				current_state <= next_state;
		end if;
	end process p_current_stat;

	p_spi_clk: process(clk, irst_n)
	begin
		if irst_n = '0' then
			freq <= 0;
			spi_clk <= '0';
		elsif rising_edge(clk) then
			if freq = 4 then
				spi_clk <= '1';
				freq <= freq + 1;
			elsif freq = 5 then
				spi_clk <= '0';
				freq <= 0;
			else
				freq <= freq + 1;
			end if;
		end if;
	end process p_spi_clk;

	p_data_in_edge: process(clk, irst_n)
  	begin
		if irst_n = '0' then
			prev_data_in_state <= '0';
			data_in_edge <= '0';
    	elsif rising_edge(clk) then
			if send_data_in = '1' and prev_data_in_state = '0' then
				data_in_edge <= '1';
			else
				data_in_edge <= '0';
			end if;
			prev_data_in_state <= send_data_in;
		end if;
    end process p_data_in_edge;

	p_one_faulty_edge: process(clk, irst_n)
  	begin
		if irst_n = '0' then
			prev_one_faulty <= '0';
			one_faulty_edge <= '0';
    	elsif rising_edge(clk) then
			if send_one_faulty_bit_in = '1' and prev_one_faulty = '0' then
				one_faulty_edge <= '1';
			else
				one_faulty_edge <= '0';
			end if;
			prev_one_faulty <= send_one_faulty_bit_in;
		end if;
    end process p_one_faulty_edge;

	p_two_faulty_edge: process(clk, irst_n)
  	begin
		if irst_n = '0' then
			prev_two_faulty <= '0';
			two_faulty_edge <= '0';
    	elsif rising_edge(clk) then
			if send_two_faulty_bits_in = '1' and prev_two_faulty = '0' then
				two_faulty_edge <= '1';
			else
				two_faulty_edge <= '0';
			end if;
			prev_two_faulty <= send_two_faulty_bits_in;
		end if;
    end process p_two_faulty_edge;

	
end rtl;
