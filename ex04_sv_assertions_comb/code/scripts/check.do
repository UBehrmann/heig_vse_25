
proc compile_duv { } {
  vcom -mixedsvvh ../src/alu.vhd -work work    -2008
}

proc check_sva { } {

      vlog -mixedsvvh ../src_tb/alu_assertions.sv  ../src_tb/alu_wrapper.sv
      formal compile -d alu_wrapper -work work -GERRNO=17
  formal init
  formal verify -auto_constraint_off
}

compile_duv

check_sva
