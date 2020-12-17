#!/bin/bash

# SimpleSim sim-outorder benchmarking script
# Author: Stephen More

# Make sure this file and "visualize_bm.py" are both in the "benchmarks/" directory 
# All human friendly readable outputs go to ./benchmarks/bm_output directory

# The command to run everything with sim-outorder is: ./full_bm.sh all
# The command to run everything if sim-outorder has been run is: ./full_bm.sh all nosim
#
#
# ARG1 values: "na" (no input) -> run benchmarks across bpred types only
#              "all" -> run benchmarks across bpred types and bimod table sizes, running all will also run python script and output figures to .png files in benchmarks directory
#              "bpb" -> run benchmarks across table sizes only
# ARG2 values: "na" (no input) -> runs sim-outorder to get results
#              "nosim" -> runs all data output to directories but no sim-outorder (if one had already run simulations once, as they take a long time)
# ARG3 values: "na" (no input) -> replaces old benchmarking values from previous runs
#              "app" -> appends 

# NOTE: For plots to be outputted python3 must be installed with numpy and matplotlib
# Install Steps:
# sudo apt-get install -y python3
# sudo apt-get install -y python3-pip
# pip3 install numpy
# pip3 install matplotlib

ARG1=${1:-na}
ARG2=${2:-na}
ARG3=${3:-na}
PWD=$(pwd)
declare -a bpred_arr=("taken" "nottaken" "bimod" "2lev" "comb")
declare -a bm_arr=("anagram" "go" "gcc")

if [ ! -d ./sim_results ] || [ ! -d ./bm_output ] || [ -d ./vis_bm_output ] || [ -d ./vis_bm_output/data ]
then
    mkdir ./sim_results ./bm_output ./vis_bm_output 2> /dev/null
    mkdir ./vis_bm_output/data 2> /dev/null
fi

rm bm_output/*.txt vis_bm_output/*.txt 2> /dev/null
rm vis_bm_output/data/*.txt 2> /dev/null

if [ "$ARG1" = "na" ] || [ "$ARG1" = "all" ]
then
    if [ "$ARG2" != "nosim" ]
    then
        for bpred in "${bpred_arr[@]}"
            do
                declare -a bm_addr_arr=()
                declare -a bm_ipc_arr=()
                
                ./sim-outorder -config default.cfg -bpred $bpred anagram.alpha words < anagram.in > OUT 2> sim_results/anagram_$bpred.txt &
                pids+=($!)
                ./sim-outorder -config default.cfg -bpred $bpred go.alpha 50 9 2stone9.in > OUT 2> sim_results/go_$bpred.txt &
                pids+=($!)
                ./sim-outorder -config default.cfg -bpred $bpred cc1.alpha -O 1stmt.i 2> sim_results/gcc_$bpred.txt &
                pids+=($!)
            done
            for pid in "${pids[@]}"
            do
                tail --pid=$pid -f /dev/null
            done 
    fi
    for bpred in "${bpred_arr[@]}"
    do
        if [ -f bm_output/addr_pred.txt ] && [ -f bm_output/IPC.txt ]
        then
            echo "--------$bpred--------" >> bm_output/addr_pred.txt
            echo "--------$bpred--------" >> bm_output/IPC.txt
            echo "--------$bpred--------" >> vis_bm_output/$bpred\_addr_pred.txt
            echo "--------$bpred--------" >> vis_bm_output/$bpred\_IPC.txt
        else
            echo "--------$bpred--------" > bm_output/addr_pred.txt
            echo "--------$bpred--------" > bm_output/IPC.txt
            echo "--------$bpred--------" > vis_bm_output/$bpred\_addr_pred.txt
            echo "--------$bpred--------" > vis_bm_output/$bpred\_IPC.txt
        fi
        echo "anagram: $(cat sim_results/anagram_$bpred.txt | grep "branch address-prediction")" >> bm_output/addr_pred.txt
        echo "go:      $(cat sim_results/go_$bpred.txt | grep "branch address-prediction")" >> bm_output/addr_pred.txt
        echo "gcc:     $(cat sim_results/gcc_$bpred.txt | grep "branch address-prediction")" >> bm_output/addr_pred.txt

        echo "anagram,$(cat sim_results/anagram_$bpred.txt | grep "branch address-prediction" | grep -o "[0-9]\.[0-9]\+")" >> vis_bm_output/$bpred\_addr_pred.txt
        echo "go,$(cat sim_results/go_$bpred.txt | grep "branch address-prediction" | grep -o "[0-9]\.[0-9]\+")" >> vis_bm_output/$bpred\_addr_pred.txt
        echo "gcc,$(cat sim_results/gcc_$bpred.txt | grep "branch address-prediction" | grep -o "[0-9]\.[0-9]\+")" >> vis_bm_output/$bpred\_addr_pred.txt

        echo "anagram: $(cat sim_results/anagram_$bpred.txt | grep "IPC")" >> bm_output/IPC.txt
        echo "go:      $(cat sim_results/go_$bpred.txt | grep "IPC")" >> bm_output/IPC.txt
        echo "gcc:     $(cat sim_results/gcc_$bpred.txt | grep "IPC")" >> bm_output/IPC.txt
        
        echo "anagram,$(cat sim_results/anagram_$bpred.txt | grep "IPC" | grep -o "[0-9]\.[0-9]\+")" >> vis_bm_output/$bpred\_IPC.txt
        echo "go,$(cat sim_results/go_$bpred.txt | grep "IPC" | grep -o "[0-9]\.[0-9]\+")" >> vis_bm_output/$bpred\_IPC.txt
        echo "gcc,$(cat sim_results/gcc_$bpred.txt | grep "IPC" | grep -o "[0-9]\.[0-9]\+")" >> vis_bm_output/$bpred\_IPC.txt
    done
fi
if [ "$ARG1" = "bpb" ] || [ "$ARG1" = "all" ]
then
    if [ "$ARG2" != "nosim" ]
    then
        for bpb in 256 512 1024 2048 4096
        do
            ./sim-outorder -config default.cfg -bpred:bimod $bpb anagram.alpha words < anagram.in > OUT 2> sim_results/anagram_bimod_$bpb.txt &
            pids=($!)
            ./sim-outorder -config default.cfg -bpred:bimod $bpb go.alpha 50 9 2stone9.in > OUT 2> sim_results/go_bimod_$bpb.txt &
            pids+=($!)
            ./sim-outorder -config default.cfg -bpred:bimod $bpb cc1.alpha -O 1stmt.i 2> sim_results/gcc_bimod_$bpb.txt &
            pids+=($!)
        done
        for pid in "${pids[@]}"
            do
                tail --pid=$pid -f /dev/null
        done
    fi
    for bpb in 256 512 1024 2048 4096
    do
        if [ -f bm_output/bpb_addr_pred.txt ]
        then
            echo "--------bimod:$bpb--------" >> bm_output/bpb_addr_pred.txt
            echo "--------bimod:$bpb--------" >> vis_bm_output/$bpb\_addr_pred.txt
        else
            echo "--------bimod:$bpb--------" > bm_output/bpb_addr_pred.txt
            echo "--------bimod:$bpb--------" > vis_bm_output/$bpb\_addr_pred.txt
        fi
        echo "anagram: $(cat sim_results/anagram_bimod_$bpb.txt | grep "branch address-prediction")" >> bm_output/bpb_addr_pred.txt
        echo "go:      $(cat sim_results/go_bimod_$bpb.txt | grep "branch address-prediction")" >> bm_output/bpb_addr_pred.txt
        echo "gcc:     $(cat sim_results/gcc_bimod_$bpb.txt | grep "branch address-prediction")" >> bm_output/bpb_addr_pred.txt

        echo "anagram,$(cat sim_results/anagram_bimod_$bpb.txt | grep "branch address-prediction" | grep -o "[0-9]\.[0-9]\+")" >> vis_bm_output/$bpb\_addr_pred.txt
        echo "go,$(cat sim_results/go_bimod_$bpb.txt | grep "branch address-prediction" | grep -o "[0-9]\.[0-9]\+")" >> vis_bm_output/$bpb\_addr_pred.txt
        echo "gcc,$(cat sim_results/gcc_bimod_$bpb.txt | grep "branch address-prediction" | grep -o "[0-9]\.[0-9]\+")" >> vis_bm_output/$bpb\_addr_pred.txt
    done
else 
    echo "No bm mode was chosen"
fi

#output for processing
cat bm_output/addr_pred.txt | grep anagram | grep -o "[0-9]\.[0-9]\+" > vis_bm_output/data/anagram_addr.txt
cat bm_output/addr_pred.txt | grep go | grep -o "[0-9]\.[0-9]\+" > vis_bm_output/data/go_addr.txt
cat bm_output/addr_pred.txt | grep gcc | grep -o "[0-9]\.[0-9]\+" > vis_bm_output/data/gcc_addr.txt

cat bm_output/IPC.txt | grep anagram | grep -o "[0-9]\.[0-9]\+" > vis_bm_output/data/anagram_ipc.txt
cat bm_output/IPC.txt | grep go | grep -o "[0-9]\.[0-9]\+" > vis_bm_output/data/go_ipc.txt
cat bm_output/IPC.txt | grep gcc | grep -o "[0-9]\.[0-9]\+" > vis_bm_output/data/gcc_ipc.txt

cat bm_output/bpb_addr_pred.txt | grep anagram | grep -o "[0-9]\.[0-9]\+" > vis_bm_output/data/anagram_addr_bimod.txt
cat bm_output/bpb_addr_pred.txt | grep go | grep -o "[0-9]\.[0-9]\+" > vis_bm_output/data/go_addr_bimod.txt
cat bm_output/bpb_addr_pred.txt | grep gcc | grep -o "[0-9]\.[0-9]\+" > vis_bm_output/data/gcc_addr_bimod.txt

if [ $ARG1 = "all" ] && $(python3 -c 'import numpy') && $(python3 -c 'import matplotlib')
then
    python3 visualize_bm.py
else
    echo "Please make sure you have python3, numpy, and matplotlib installed in your python3 environment"
fi

# grep and regex notes:
# -o, --only-matching, print only the matched part of the line (instead of the entire line)
# -a, --text, process a binary file as if it were text
# -m 1, --max-count, stop reading a file after 1 matching line
# -h, --no-filename, suppress the prefixing of file names on output
# -r, --recursive, read all files under a directory recursively
# -p, POSIX