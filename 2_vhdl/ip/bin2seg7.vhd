--------------------------------------------------------------------------------
-- Filename: bin2seg7.vhd
-- Author  : M. Pichler
-- Date    : 14.11.2008
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin2seg7 is
	generic (
		-- Blinking Period ca. 1 Hz (e.g. 50 MHz / 50e6)
		g_clk_div : natural := 2**25
	);
	port (
		clk       : in  std_ulogic;
		rst_n     : in  std_ulogic;
		-- Control:
		wr_en     : in  std_ulogic;
		data_reg  : in  std_ulogic_vector(31 downto 0);
		ctrl_reg  : in  std_ulogic_vector(31 downto 0);
		-- Seven Segment Displays:
		hex5      : out std_ulogic_vector(6 downto 0);
		hex4      : out std_ulogic_vector(6 downto 0);
		hex3      : out std_ulogic_vector(6 downto 0);
		hex2      : out std_ulogic_vector(6 downto 0);
		hex1      : out std_ulogic_vector(6 downto 0);
		hex0      : out std_ulogic_vector(6 downto 0)
	);
end entity bin2seg7;

architecture rtl of bin2seg7 is
	-------------------------------------------------------------------------------
	-- Constants                                         gfedcba
	-------------------------------------------------------------------------------
	constant C_Blank : std_ulogic_vector (6 downto 0) := "1111111";
	constant C_Reset : std_ulogic_vector (6 downto 0) := "0111111";
	-- HEX Values
	constant C_0 : std_ulogic_vector (6 downto 0) := "1000000";  -- h40
	constant C_1 : std_ulogic_vector (6 downto 0) := "1111001";	 -- h79
	constant C_2 : std_ulogic_vector (6 downto 0) := "0100100";  -- h24
	constant C_3 : std_ulogic_vector (6 downto 0) := "0110000";  -- h30
	constant C_4 : std_ulogic_vector (6 downto 0) := "0011001";  -- h19
	constant C_5 : std_ulogic_vector (6 downto 0) := "0010010";  -- h12
	constant C_6 : std_ulogic_vector (6 downto 0) := "0000010";  -- h02
	constant C_7 : std_ulogic_vector (6 downto 0) := "1111000";  -- h78
	constant C_8 : std_ulogic_vector (6 downto 0) := "0000000";  -- h00
	constant C_9 : std_ulogic_vector (6 downto 0) := "0010000";  -- h10
	constant C_A : std_ulogic_vector (6 downto 0) := "0001000";  -- h08
	constant C_B : std_ulogic_vector (6 downto 0) := "0000011";  -- h03
	constant C_C : std_ulogic_vector (6 downto 0) := "1000110";  -- h46
	constant C_D : std_ulogic_vector (6 downto 0) := "0100001";  -- h21
	constant C_E : std_ulogic_vector (6 downto 0) := "0000110";  -- h06
	constant C_F : std_ulogic_vector (6 downto 0) := "0001110";  -- h0e
	-- Extended Values
	constant C_G : std_ulogic_vector (6 downto 0) := "1000010";
	constant C_H : std_ulogic_vector (6 downto 0) := "0001001";  -- h09
	constant C_I : std_ulogic_vector (6 downto 0) := C_1;
	constant C_J : std_ulogic_vector (6 downto 0) := "1100001";
	constant C_K : std_ulogic_vector (6 downto 0) := C_H;
	constant C_L : std_ulogic_vector (6 downto 0) := "1000111";
	constant C_M : std_ulogic_vector (6 downto 0) := "0101010";
	constant C_N : std_ulogic_vector (6 downto 0) := "1001000";
	constant C_O : std_ulogic_vector (6 downto 0) := C_0;
	constant C_P : std_ulogic_vector (6 downto 0) := "0001100";
	constant C_Q : std_ulogic_vector (6 downto 0) := "0011000";
	constant C_R : std_ulogic_vector (6 downto 0) := "1001110";
	constant C_S : std_ulogic_vector (6 downto 0) := C_5;
	constant C_T : std_ulogic_vector (6 downto 0) := "0000111";
	constant C_U : std_ulogic_vector (6 downto 0) := "1000001";
	constant C_V : std_ulogic_vector (6 downto 0) := "1010101";
	constant C_W : std_ulogic_vector (6 downto 0) := "0010101";
	constant C_X : std_ulogic_vector (6 downto 0) := "0110110";
	constant C_Y : std_ulogic_vector (6 downto 0) := "0010001";
	constant C_Z : std_ulogic_vector (6 downto 0) := C_2;
	-------------------------------------------------------------------------------
	-- SEG7_LUT         
	-------------------------------------------------------------------------------
	function f_bin2seg (
			ibin          : std_ulogic_vector(4 downto 0);
			clk_1hz       : std_ulogic;
			disable_all   : std_ulogic;
			blink_all     : std_ulogic;
			disable_digit : std_ulogic;
			blink_digit   : std_ulogic
		) return std_ulogic_vector is
		variable oseg : std_ulogic_vector(6 downto 0);
	begin
		if disable_all = '1' or disable_digit = '1' then
			oseg := C_Blank;
		elsif clk_1hz = '0' and (blink_all = '1' or blink_digit = '1') then
			oseg := C_Blank;
		else
			case resize(unsigned(ibin),8) is
					-- HEX values
				when X"00" => oseg := C_0;
				when X"01" => oseg := C_1;
				when X"02" => oseg := C_2;
				when X"03" => oseg := C_3;
				when X"04" => oseg := C_4;
				when X"05" => oseg := C_5;
				when X"06" => oseg := C_6;
				when X"07" => oseg := C_7;
				when X"08" => oseg := C_8;
				when X"09" => oseg := C_9;
				when X"0A" => oseg := C_A;
				when X"0B" => oseg := C_B;
				when X"0C" => oseg := C_C;
				when X"0D" => oseg := C_D;
				when X"0E" => oseg := C_E;
				when X"0F" => oseg := C_F;
					-- extended values
				when X"10" => oseg := C_G;
				when X"11" => oseg := C_H;
					--                        C_I
				when X"12" => oseg := C_J;
					--                        C_K
				when X"13" => oseg := C_L;
				when X"14" => oseg := C_M;
				when X"15" => oseg := C_N;
					--                        C_O
				when X"16" => oseg := C_P;
				when X"17" => oseg := C_Q;
				when X"18" => oseg := C_R;
					--                        C_S
				when X"19" => oseg := C_T;
				when X"1A" => oseg := C_U;
				when X"1B" => oseg := C_V;
				when X"1C" => oseg := C_W;
				when X"1D" => oseg := C_X;
				when X"1E" => oseg := C_Y;
					--                        C_Z
				when X"1F" => oseg := C_Blank;
					-- else
				when others => oseg := C_Reset;
			end case;
		end if;
		return oseg;
	end function;
	---------------------------------------------------------------------------
	-- Constants         
	---------------------------------------------------------------------------
	constant NR_OF_DIGITS : integer range 1 to 6 := 6;
	---------------------------------------------------------------------------
	-- Types         
	---------------------------------------------------------------------------
	-- type reg_type is array(integer range  <>) of std_ulogic_vector(31 downto 0);
	type t_oseg is array(integer range <>) of std_ulogic_vector(6 downto 0);
	---------------------------------------------------------------------------
	-- Signals         
	---------------------------------------------------------------------------
	signal regs          : std_ulogic_vector(31 downto 0);
	signal oseg          : t_oseg(0 to NR_OF_DIGITS-1);
	signal count         : natural range 0 to g_clk_div-1;
	signal clk_1hz       : std_ulogic;
	signal blink_all     : std_ulogic;
	signal blink_digit   : std_ulogic_vector(5 downto 0);
	signal disable_all   : std_ulogic;
	signal disable_digit : std_ulogic_vector(5 downto 0);
	
begin
	
	-- 1. Write Data Register
	p_avs : process(clk, rst_n)
	begin
		if rst_n = '0' then
			regs <= (others => '0');
		elsif rising_edge(clk) then
			if wr_en = '1' then
				regs <= data_reg;
			end if;
		end if;
	end process p_avs;
	
	-- Control Register 1
	blink_digit   <= ctrl_reg(5 downto 0);
	disable_digit <= ctrl_reg(13 downto 8);
	blink_all     <= ctrl_reg(30);
	disable_all   <= ctrl_reg(31);
	
	-- 2. Blink Counter
	p_count : process(clk, rst_n)
	begin
		if rst_n = '0' then
			count   <= 0;
			clk_1hz <= '0';
		elsif rising_edge(clk) then
			if count = 0 then
				clk_1hz <= not clk_1hz;
				count <= g_clk_div-1;
				-- synthesis translate_off
				count <= 3;
				-- synthesis translate_on
			else
				count   <= count - 1;
			end if;
		end if;
	end process p_count;
	
	-- 3. Bin2Seg Conversion
	p_bin2seg : process(clk, rst_n)
		variable v_ibin : std_ulogic_vector(4 downto 0);
	begin
		if rst_n = '0' then
			oseg <= (others => C_Reset);
		elsif rising_edge(clk) then
			for i in 0 to NR_OF_DIGITS-1 loop
				v_ibin  := regs(i+24) & regs(i*4+3 downto i*4);
				oseg(i) <= f_bin2seg (
						ibin          => v_ibin,
						clk_1hz       => clk_1hz,
						disable_all   => disable_all,
						blink_all     => blink_all,
						disable_digit => disable_digit(i),
						blink_digit   => blink_digit(i)
				); 
			end loop;
		end if;
	end process p_bin2seg;
	
	-- 4. Mapping to outputs
	hex5 <= oseg(5);
	hex4 <= oseg(4);
	hex3 <= oseg(3);
	hex2 <= oseg(2);
	hex1 <= oseg(1);
	hex0 <= oseg(0);
	
end architecture rtl;
