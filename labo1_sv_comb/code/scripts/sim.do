
# !/usr/bin/tclsh

# Main proc at the end #

#------------------------------------------------------------------------------
proc compile_duv { } {
  global Path_DUV
  puts "\nVHDL DUV compilation :"

  vlib work
  vcom -2008 -mixedsvvh $Path_DUV/packet_analyzer_pkg.vhd
  vcom -2008 -mixedsvvh $Path_DUV/packet_analyzer.vhd
}

#------------------------------------------------------------------------------
proc compile_tb { } {
  global Path_TB
  global Path_DUV
  puts "\nVHDL TB compilation :"

  vlog -mixedsvvh -sv $Path_TB/packet_analyzer_tb.sv
}

#------------------------------------------------------------------------------
proc sim_start {TESTCASE ERRNO} {

  global StdArithNoWarnings
  global NumericStdNoWarnings
  
  vsim -t 1ns -GERRNO=$ERRNO -GTESTCASE=$TESTCASE work.packet_analyzer_tb
#  do wave.do
  add wave -r *
  wave refresh
  set StdArithNoWarnings 1
  set NumericStdNoWarnings 1
  run 10ns
  set StdArithNoWarnings 0
  set NumericStdNoWarnings 0
  run -all
}

#------------------------------------------------------------------------------
proc do_all {TESTCASE  ERRNO} {
  compile_duv
  compile_tb
  sim_start $TESTCASE $ERRNO
}

## MAIN #######################################################################

# Compile folder ----------------------------------------------------
if {[file exists work] == 0} {
  vlib work
}

puts -nonewline "  Path_VHDL => "
set Path_DUV     "../src_vhdl"
set Path_TB       "../src_tb"

global Path_DUV
global Path_TB

# start of sequence -------------------------------------------------

if {$argc>0} {
  if {[string compare $1 "all"] == 0} {
    do_all $2 $3
  } elseif {[string compare $1 "comp_duv"] == 0} {
    compile_duv
  } elseif {[string compare $1 "comp_tb"] == 0} {
    compile_tb
  } elseif {[string compare $1 "sim"] == 0} {
    sim_start $2 $3 $4
  }

} else {
  do_all 0 0
}
