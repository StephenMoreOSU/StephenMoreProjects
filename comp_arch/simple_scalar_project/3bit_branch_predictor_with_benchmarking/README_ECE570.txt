OVERVIEW:
The 3-Bit predictor acts similarly to the 2-Bit bimodal. The option to run the 
default 3-Bit (2048 entries) is "-bpred:3bit". Do modify the number of entries 
by command line add "-bpred:3bit 4096" into the command line or modify the default config. 


Included is a set of bash and python tools that help with easy running and visualization


HELPER SCRIPTS:

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