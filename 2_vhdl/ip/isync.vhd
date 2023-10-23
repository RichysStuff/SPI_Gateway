-- -----------------------------------------------------------------------------
-- Filename: isync.vhd
-- Author  : M. Pichler
-- Date    : 12.04.2018
-- Content : Synchronization of input vectors
--           A single pulse can be generated, depending of g_mode
--           0: no pulse
--           1: pulse at the risinge edge
--           2: pulse at the falling edge
--           3: pulse at both edges
-- -----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity isync is
	generic (
		g_width : natural := 2; -- width of input vector
		g_inv   : natural := 0; -- invert the inputs
		g_mode  : natural := 0  -- mode of outputs
	);
	port(
		clk     : in  std_ulogic; -- clock
		rst_n   : in  std_ulogic; -- asynchronous reset
		idata_a : in  std_ulogic_vector(g_width-1 downto 0); -- asynchronous inputs
		odata_s : out std_ulogic_vector(g_width-1 downto 0) -- single pulse
	);
end isync;

architecture rtl of isync is
	signal idata_1 : std_ulogic_vector(idata_a'range); -- 1st stage
	signal idata_2 : std_ulogic_vector(idata_a'range); -- 2nd stage
begin
	
	-- reset generation
	p_sync : process(rst_n, clk)
	begin
		if rst_n = '0' then
			-- init
			idata_1 <= (others => '0');
			idata_2 <= (others => '0');
			odata_s <= (others => '0');
		elsif rising_edge(clk) then
			-- synchronize with two flipflops
			if g_inv = 1 then
				idata_1 <= not idata_a;
			else
				idata_1 <= idata_a;
			end if;
			idata_2 <= idata_1;

			-- generate odata_s
			case g_mode is
				when 1 => 
					odata_s <= idata_1 and not idata_2; -- pulse @ rising_edge
				when 2 => 
					odata_s <= not idata_1 and idata_2; -- pulse @ falling_edge
				when 3 => 
					odata_s <= idata_1 xor idata_2; -- pulse @ both edges
				when others => 
					odata_s <= idata_2;	-- synchronize only
			end case;
		end if;
	end process p_sync;
	
end rtl;
