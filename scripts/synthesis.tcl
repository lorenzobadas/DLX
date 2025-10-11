# findFiles
# basedir - the directory to start looking in
# pattern - A pattern, as defined by the glob command, that the files must match
proc findFiles { basedir pattern } {

    # Fix the directory name, this ensures the directory name is in the
    # native format for the platform and contains a final directory seperator
    set basedir [string trimright [file join [file normalize $basedir] { }]]
    set fileList {}

    # Look in the current directory for matching files, -type {f r}
    # means only readable normal files are looked at, -nocomplain stops
    # an error being thrown if the returned list is empty
    foreach fileName [glob -nocomplain -type {f r} -path $basedir $pattern] {
        lappend fileList $fileName
    }

    # Now look for any sub directories in the current directory
    foreach dirName [glob -nocomplain -type {d  r} -path $basedir *] {
        # Skip "tb" directory
        if {[string match "*tb" $dirName]} {
            continue
        }
        # Recusively call the routine on the sub directory and append any
        # new files to the results
        set subDirList [findFiles $dirName $pattern]
        if { [llength $subDirList] > 0 } {
            foreach subDirFile $subDirList {
                lappend fileList $subDirFile
            }
        }
    }
    return $fileList
}

set top_entity "cpu"

if {![info exists rootdir]} {
    error "rootdir not set"
    quit
}

if {![info exists outdir]} {
    error "outdir not set"
    quit
}

set files [concat   [findFiles $rootdir/src "instructions_pkg.vhd"] \
                    [findFiles $rootdir/src "alu_instr_pkg.vhd"] \
                    [findFiles $rootdir/src "ctrl_signals_pkg.vhd"] \
                    [findFiles $rootdir/src "utils_pkg.vhd"] \
                    [findFiles $rootdir/src "mem_pkg.vhd"] \
                    [findFiles $rootdir/src "*.vhd"]]

analyze -library work -format vhdl $files

elaborate -lib work $top_entity

set clock_name "CLOCK"

if {$flatten == "all"} {
    set clock_period 1.50
} elseif {$flatten == "auto"} {
    set clock_period 1.85
} elseif {$flatten == "none"} {
    set clock_period 2.01
} else {
    error "Unknown flatten option: $flatten"
}

create_clock -name $clock_name -period $clock_period clk_i

set_dont_touch_network $clock_name
set_clock_uncertainty 0.07 [get_clocks $clock_name]
set_input_delay 0.5 -max -clock $clock_name [remove_from_collection [all_inputs] $clock_name]
set_output_delay 0.5 -max -clock $clock_name [all_outputs] 

set OLOAD [load_of NangateOpenCellLibrary/BUF_X4/A]
set_load $OLOAD [all_outputs]

set_max_delay -from [all_inputs] -to [all_outputs] $clock_period

if { $flatten == "all" } {
    ungroup -all -flatten
    compile_ultra
} elseif { $flatten == "auto" } {
    compile -map_effort high -auto_ungroup delay
} elseif { $flatten == "none" } {
    compile -map_effort high
} else {
    error "Unknown flatten option: $flatten"
}

puts "## Writing Reports ##"
report_power   > "$outdir/power.rpt"
report_area    > "$outdir/area.rpt"
report_timing  > "$outdir/timing.rpt"
report_clocks  > "$outdir/clocks.rpt"

change_names -hierarchy -rules verilog

write -hierarchy -f verilog -output "$outdir/${top_entity}.v"
write_sdc "$outdir/${top_entity}.sdc"
write_sdf "$outdir/${top_entity}.sdf"

exit
