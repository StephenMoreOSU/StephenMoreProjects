#!/bin/bash

savewlf()
{
    local simModule=$1
    if [ -f "vsim.wlf" ]
        then
            if [ ! -d "$wlfdir" ]
            then
                mkdir "$wlfdir"
            fi
            cp "vsim.wlf" "$wlfdir/${simModule}_sim.wlf"
        else
            >&2 echo "Could not find vsim.wlf"
    fi
}
confirm_prompt()
{
    confirm_str=${1:-"Are you sure? "}
    read -p "$1" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        return 0
    else 
        return 2
    fi
}
mk_synth_dofile()
{
    local svModule=$1
    sdf="synth_dofile.do"
    echo "read_sverilog rtl_src/${svModule}.sv" > $sdf
    echo "compile" >> $sdf
    echo "write -hierarchy -format verilog -output ${svModule}.gate.v" >> $sdf
    echo "quit!" >> $sdf
}
synthesis()
{
    local svModule=$1
    cd ..
    #echo "cd .."
    mk_synth_dofile $svModule
    dc_shell-xg-t -f $sdf
    #echo "dc_shell-xg-t -f $sdf"
    vlog ${svModule}.gate.v
    #echo "vlog ${svModule}.gate.v"
    vlog /nfs/guille/a1/cadlibs/synop_lib/SAED_EDK90nm/Digital_Standard_Cell_Library/verilog/*.v
    #echo "vlog /nfs/guille/a1/cadlibs/synop_lib/SAED_EDK90nm/Digital_Standard_Cell_Library/verilog/*.v"
}
svModuleFile=$1
dofile=${2:-nodo}
svtbFile=${3:-notb}
viewWaveFlag=${4:-noview}
#FORMAT OF INPUTS
#Ex. svModuleFile="glitchy.sv"
#Ex. dofile="test.do"
#Ex. svtbFile="glitchy_tb.sv"

#NOTES:
# Make sure the dofile used for sim has a quit -f on the last line, this will allow the script to continue operation
# For notb nodo file input module name will have to be name of svModuleFile without .sv extension Ex. svModuleFile="test.sv", svModule="test"
# For tb svtbFile tb module name will have to be name of svtbFile without .sv extension Ex svtbFile="glitchy_tb.sv", svtbModule="glitchy_tb"
# Make sure to run in the rtl_src dir

#EXIT VAL MEANING:
# 0: No error
# 1: error
# 2: script halted by user prompt

#concatenating strs
#VAR2="${VAR1}World"

#to remove file extension from str
#y=${x%.*}

if [ -f "$svModuleFile" ]
then
    wlfdir="wlf_files"
    addwaves="add_all_waves.do"
    echo "add wave *" > $addwaves
    vlog $svModuleFile
    #echo "vlog $svModuleFile"
    vlogRet=$?
    svModule=${svModuleFile%.*}
    if [ $vlogRet = 2 ]
    then
        >&2 echo "SystemVerilog module threw compilation error"
        exit 1
    elif [ $vlogRet = 0 ]
    then
        if [ $svtbFile = "notb" ] && [ $dofile = "nodo" ]
        then
            confirm_prompt "Are you sure you want to simulate without dofile or testbench? "
            if [ $? = 0 ]
            then
                vsim $svModule -novopt 
                #echo "vsim $svModule -novopt"
                savewlf $svModule
                synthesis $svModule
                vsim "${svModule}.gate"
                savewlf "${svModule}.gate"
            else
                exit 2
            fi
        elif [ $svtbFile = "notb" ] && [ $dofile = $2 ] 
        then
            vsim $svModule -do $dofile -novopt -quiet -c
            #echo "vsim $svModule -do $dofile -novopt -quiet -c"
            savewlf $svModule
            synthesis $svModule
            savewlf "${svModule}.gate"
        else
            vlog $svtbFile
            #echo "vlog $svtbFile"
            svtbModule=${svtbFile%.*}
            vsim $svtbModule -do $dofile -novopt -quiet -c
            #echo "vsim $svtbModule -do $dofile -novopt -quiet -c"
            savewlf $svModule
            synthesis $svModule
            vlog $svtbFile
            vsim $svtbModule -do rtl_src/$dofile -novopt -quiet -c
            #echo "vsim $svtbModule -do rtl_src/$dofile -novopt -quiet -c"
            savewlf "${svModule}.gate"
            #if [ $viewWaveFlag = "-v" ]
            #then
            #    echo "vsim -view rtl_src/$wlfdir/${svtbModule}_sim.wlf -do $addwaves"
            #    echo "vsim -view "
            #fi
        fi
    fi
else
    >&2 echo "Could not find SystemVerilog module file"
    exit 1
fi
