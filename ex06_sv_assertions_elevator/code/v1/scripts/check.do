
proc compile_duv { } {
    vcom -mixedsvvh ../src/elevator_fsm.vhd -work work    -2008
}

proc check_sva { } {

    vlog -mixedsvvh ../src_tb/elevator_fsm_assertions.sv  ../src_tb/elevator_fsm_wrapper.sv
    formal compile -d elevator_fsm_wrapper -work work -GERRNO=0
    formal init
    formal verify -auto_constraint_off
}

compile_duv

check_sva
