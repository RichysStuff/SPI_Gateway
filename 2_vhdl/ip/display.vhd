-- -----------------------------------------------------------------------------
-- Filename: display.vhd
-- Author  : D. Bachmann
-- Date    : 2023.10.30
-- Content : display data or pattern 
-- -----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display is
	port(
		clk    : in  std_ulogic; -- clock
		irst_n : in  std_ulogic; -- asynchronous reset, active low
		data_valid_in : in std_ulogic; -- error in data
		display_mode_in   : in std_ulogic;  -- output mode
        display_pattern_in : in std_ulogic_vector(7 downto 0); -- current input pattern
        display_rx_in : in std_ulogic_vector (7 downto 0); -- data from RX Buffer
		seg_0_out : out std_ulogic_vector(6 downto 0); -- 7 segment 0
        seg_1_out : out std_ulogic_vector(6 downto 0); -- 7 segment 1
        seg_2_out : out std_ulogic_vector(6 downto 0); -- 7 segment 2
        seg_3_out : out std_ulogic_vector(6 downto 0) -- 7 segment 3
	);
end display;

architecture rtl of display is
	signal rst_reg    : std_ulogic_vector(1 downto 0);
	
    -- 7-Seg Values                                   gfedcba
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
    constant C_P : std_ulogic_vector (6 downto 0) := "0001100";
    constant C_Blank : std_ulogic_vector (6 downto 0) := "1111111"; 

    --bin2seg conversion function
    function f_bin2seg (
			ibin          : std_ulogic_vector(3 downto 0)
		) return std_ulogic_vector is
		variable oseg : std_ulogic_vector(6 downto 0);
	begin
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

            when others => oseg := C_Blank;
        end case;

		return oseg;
	end function;

    signal lower_seg : std_ulogic_vector(6 downto 0);
    signal higher_seg : std_ulogic_vector(6 downto 0);
    signal omode : std_ulogic_vector(6 downto 0);
    signal oerror : std_ulogic_vector(6 downto 0);
begin
    --reset
	p_reset : process(irst_n, clk)
	begin
		if irst_n = '0' then
			rst_reg <= (others => '0'); -- assert asynchronous
		elsif rising_edge(clk) then
			rst_reg <= rst_reg(0) & '1'; -- deassert synchronous
		end if;
	end process p_reset;

    --mode output
    p_mode : process(irst_n, clk)
    begin
        if irst_n = '0' then
			omode <= C_Blank; 
		elsif rising_edge(clk) then
			if display_mode_in = '0' then
                omode <= C_B;
            else
                omode <= C_P;
            end if;
		end if;
    end process p_mode;

    --error output
    p_error : process(irst_n, clk)
    begin
        if irst_n = '0' then
			oerror <= C_Blank; 
		elsif rising_edge(clk) then
			if data_valid_in = '1' then
                oerror <= C_Blank;
            else
                oerror <= C_E;
            end if;
		end if;
    end process p_error;

    --data output
    p_data: process(clk, irst_n)
    begin
        if irst_n = '0' then
            lower_seg <= C_Blank;
            higher_seg <= C_Blank;
        elsif rising_edge(clk) then
            if display_mode_in = '1' then
                lower_seg <= f_bin2seg(display_pattern_in(3 downto 0));
                higher_seg <= f_bin2seg(display_pattern_in(7 downto 4));
            else
                lower_seg <= f_bin2seg(display_rx_in(3 downto 0));
                higher_seg <= f_bin2seg(display_rx_in(7 downto 4));
            end if;            
        end if;
    end process p_data;
	
	seg_0_out <= lower_seg;
    seg_1_out <= higher_seg;
    seg_2_out <= omode;
    seg_3_out <= oerror;
	
end rtl;