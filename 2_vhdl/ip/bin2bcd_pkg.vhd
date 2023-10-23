-----------------------------------------------------
-- File    : bin2bcd_pkg.vhd
-- Library :
-- Author  : michael.pichler@fhnw.ch
-- Company : Institute of Microelectronics (IME) FHNW
-- Copyright(C) IME
-----------------------------------------------------
-- Description : Binary to BCD conversion
--               Speed depends on input width
-----------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

package bin2bcd_pkg is
  
  -- function to convert a binary vector to a bcd vector of a required number of digits
  function f_digits (
      data_in : in std_ulogic_vector; 
      len     : in positive
      ) 
  return std_ulogic_vector;
  
end package bin2bcd_pkg;


package body bin2bcd_pkg is

  -- own types
  type t_digits is array (natural range <>) of natural range 0 to 9;
  type t_digit_in is record
    start  : std_ulogic;
    mod_in : std_ulogic;
    bcd_in : natural range 0 to 9;
  end record;
  type t_digit_out is record
    mod_out : std_ulogic;
    bcd_out : natural range 0 to 9;
  end record;
  type t_digits_in is array (natural range  <>) of t_digit_in;
  type t_digits_out is array (natural range <>) of t_digit_out;
  
  -- funciton to convert BIN2BCD
  --   refer to Xilinx Application Note XAPP029
  function f_digit (
      r_in : in t_digit_in
      ) 
  return t_digit_out is
    variable next_bcd_out : unsigned(2 downto 0);
    variable next_mod_out : std_ulogic;
    variable r_out        : t_digit_out;
  begin
    -- internal calculations
    case r_in.bcd_in is
      when 0 => next_bcd_out := "000"; next_mod_out := '0';
      when 1 => next_bcd_out := "001"; next_mod_out := '0';
      when 2 => next_bcd_out := "010"; next_mod_out := '0';
      when 3 => next_bcd_out := "011"; next_mod_out := '0';
      when 4 => next_bcd_out := "100"; next_mod_out := '0';
      when 5 => next_bcd_out := "000"; next_mod_out := '1';
      when 6 => next_bcd_out := "001"; next_mod_out := '1';
      when 7 => next_bcd_out := "010"; next_mod_out := '1';
      when 8 => next_bcd_out := "011"; next_mod_out := '1';
      when 9 => next_bcd_out := "100"; next_mod_out := '1';
      when others => next_bcd_out := "---";
    end case;
    -- outputs
    if r_in.start = '1' then
      r_out.mod_out := '0';
      if r_in.mod_in = '1' then
        r_out.bcd_out := 1;
      else
        r_out.bcd_out := 0;
      end if;
    else
      r_out.mod_out := next_mod_out;
      r_out.bcd_out := to_integer(unsigned(std_ulogic_vector(next_bcd_out) & r_in.mod_in));
    end if;
    -- return
    return r_out;
  end function f_digit;
  
  -- function to convert a binary vector to a bcd vector of a required number of digits
  function f_digits (
      data_in : in std_ulogic_vector; 
      len     : in positive
      ) 
  return std_ulogic_vector is
    variable r_digit_in  : t_digits_in(0 to len);
    variable r_digit_out : t_digits_out(0 to len);
    variable v_res       : std_ulogic_vector(len*4-1 downto 0);
  begin
    -- bin2bcd convertion concurrently
    for i in data_in'range loop -- process all input bits
      r_digit_out(0).mod_out := data_in(i);
      for j in 1 to len loop -- do this for each digit
        -- inputs
        if i = data_in'high then
          r_digit_in(j).start := '1';
        else
          r_digit_in(j).start := '0';
        end if;
        r_digit_in(j).mod_in := r_digit_out(j-1).mod_out;
        r_digit_in(j).bcd_in := r_digit_out(j).bcd_out;
        -- calculate
        r_digit_out(j) := f_digit(r_digit_in(j));
      end loop;
    end loop;
    -- output
    for i in 1 to len loop
      v_res(i*4-1 downto i*4-4) := std_ulogic_vector(to_unsigned(r_digit_out(i).bcd_out, 4));
    end loop;
    return v_res;
  end function f_digits;

end package body bin2bcd_pkg;
