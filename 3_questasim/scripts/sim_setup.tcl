# ----------------------------------------
# Initialize variables
# if ![info exists TOP_LEVEL_NAME] { 
  set TOP_LEVEL_NAME "counter_tb"
  set SRC "../2_vhdl"
# }

# ----------------------------------------
# Compile the design files in correct order
alias com {
  echo "\[exec\] com"
  vcom -2008 -work work $SRC/ip/rsync.vhd
  vcom -2008 -work work $SRC/ip/isync.vhd
  vcom -2008 -work work $SRC/ip/bin2seg7.vhd
  vcom -2008 -work work $SRC/ip/bin2bcd_pkg.vhd

  vcom -2008 -work work $SRC/counter.vhd
  vcom -2008 -work work $SRC/counter_verify.vhd
  vcom -2008 -work work $SRC/counter_tb.vhd

  vcom -2008 -work work $SRC/de1_soc_pkg.vhd
  vcom -2008 -work work $SRC/de1_soc_top.vhd
}

# ----------------------------------------
# Elaborate the top level design with novopt option
alias ld {
  echo "\[exec\] elab"
  eval vsim -L work $TOP_LEVEL_NAME -voptargs=+acc
}

# ----------------------------------------
# Simulate
alias sim {
  echo "\[exec\] sim"
  do scripts/sim.do
}

# ----------------------------------------
# Compile, elaborate and run simulation
alias do_all "
  com
  ld
  sim
"

# ----------------------------------------
# Print out user commmand line aliases
alias h {
  echo "List Of Command Line Aliases"
  echo
  echo "com             -- Compile the design files in correct order"
  echo "ld              -- Elaborate the top level design with novopt option"
  echo "sim             -- Run simulation"
  echo
  echo "TOP_LEVEL_NAME  -- $TOP_LEVEL_NAME"
}
h
