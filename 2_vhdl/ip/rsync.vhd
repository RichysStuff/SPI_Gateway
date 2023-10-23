-- -----------------------------------------------------------------------------
-- Filename: rsync.vhd
-- Author  : M. Pichler
-- Date    : 2014.01.28
-- Content : Synchronization of the reset
--           0=AsynAssertion-SynDeassertion
--           1=SynAssertion-SynDeassertion
-- -----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rsync is
	generic (
		g_mode : natural := 0
	);
	port(
		clk    : in  std_ulogic; -- clock
		irst_n : in  std_ulogic; -- asynchronous reset, active low
		orst_n : out std_ulogic; -- partially/full synchronized reset, active low
		orst   : out std_ulogic  -- partially/full synchronized reset, active high
	);
end rsync;

architecture rtl of rsync is
	signal rst_reg    : std_ulogic_vector(1 downto 0);
begin
	
	-- Partial Synchronizer: Synchronous Deassertion
	g_aasd : if g_mode = 0 generate
		-- reset generation
		p_reset : process(irst_n, clk)
		begin
			if irst_n = '0' then
				rst_reg <= (others => '0'); -- assert asynchronous
			elsif rising_edge(clk) then
				rst_reg <= rst_reg(0) & '1'; -- deassert synchronous
			end if;
		end process p_reset;
	end generate g_aasd;
	
	-- Full Synchronizer: Both Reset Edges
	g_sync : if g_mode = 1 generate
		-- reset generation
		p_reset : process(clk)
		begin
			if rising_edge(clk) then
				rst_reg <= rst_reg(0) & irst_n; -- synchronize both edges
			end if;
		end process p_reset;
	end generate g_sync;
	
	orst_n <= rst_reg(1);
	orst   <= not rst_reg(1);
	
end rtl;
