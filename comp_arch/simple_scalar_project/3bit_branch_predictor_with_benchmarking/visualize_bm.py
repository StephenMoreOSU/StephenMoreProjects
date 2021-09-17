#!/usr/bin/python3

#benchmark python plotter
#Author: Stephen More

#Make sure this file is in "benchmarks/" directory

import matplotlib.pyplot as plt
import numpy as np
import re
import csv

data_path = "./vis_bm_output/data/"

var_list = [ "anagram_addr","go_addr","gcc_addr","anagram_ipc","go_ipc", "gcc_ipc","anagram_addr_bimod","go_addr_bimod","gcc_addr_bimod"]

lst = []
dct = {}
for var in var_list:
    with open((data_path + var + ".txt"), newline='') as f:
        reader = csv.reader(f,delimiter='\n')
        for row in reader:
            lst.append(row)
        dct[var] = lst
        lst=[]

n_bins = 10

anagram_np = np.empty([1,0],dtype=float)
go_np = np.empty([1,0],dtype=float)
gcc_np = np.empty([1,0],dtype=float)
for val in dct["anagram_addr"]:
    anagram_np = np.append(anagram_np,float(val[0]))
for val in dct["go_addr"]:
    go_np = np.append(go_np,float(val[0]))
for val in dct["gcc_addr"]:
    gcc_np = np.append(gcc_np,float(val[0]))

addr_list = [anagram_np,go_np,gcc_np]

anagram_np = np.empty([1,0],dtype=float)
go_np = np.empty([1,0],dtype=float)
gcc_np = np.empty([1,0],dtype=float)

for val in dct["anagram_ipc"]:
    anagram_np = np.append(anagram_np,float(val[0]))
for val in dct["go_ipc"]:
    go_np = np.append(go_np,float(val[0]))
for val in dct["gcc_ipc"]:
    gcc_np = np.append(gcc_np,float(val[0]))

ipc_list = [anagram_np,go_np,gcc_np]

anagram_np = np.empty([1,0],dtype=float)
go_np = np.empty([1,0],dtype=float)
gcc_np = np.empty([1,0],dtype=float)

for val in dct["anagram_addr_bimod"]:
    anagram_np = np.append(anagram_np,float(val[0]))
for val in dct["go_addr_bimod"]:
    go_np = np.append(go_np,float(val[0]))
for val in dct["gcc_addr_bimod"]:
    gcc_np = np.append(gcc_np,float(val[0]))

addr_bimod_list = [anagram_np,go_np,gcc_np]

bm_labels = ['anagram','go','gcc']
bpred_labels = ['taken','nottaken','bimod','2lev','comb']
bpb_labels = ['256','512','1024','2048','4096']
label_list = [bm_labels, bpred_labels, bpb_labels]
colors = ['red', 'green', 'blue']
l = np.arange(len(bpred_labels))
w = 0.25

fig, axes = plt.subplots(nrows=1,ncols=2)
ax1,ax2 = axes.flatten()
ax1.hist(addr_list, n_bins, color=colors, histtype='bar', label=bm_labels,edgecolor='black')
ax1.legend(prop={'size': 10})        
ax1.set_title('Address Prediction Rate by Value')
ax1.set_xlabel('Address Prediction Rate')
ax1.set_ylabel("Frequency")


ax2.bar(l, addr_list[0], w, color=colors[0],label=bm_labels[0],edgecolor='black')
ax2.bar(l + w, addr_list[1], w,color=colors[1],label=bm_labels[1],edgecolor='black')
ax2.bar(l - w, addr_list[2], w,color=colors[2],label=bm_labels[2],edgecolor='black')

ax2.set_title('Address Prediction Rate Seperated by Bpred Type')
ax2.set_ylabel("Address Prediction Rate")
ax2.set_xticks(l)
ax2.set_xticklabels(bpred_labels)
ax2.legend()
f = plt.gcf()
f.set_size_inches(12.8,7.2)
plt.savefig('./bm_output/addr.png',dpi=100)

fig2, axes2 = plt.subplots(nrows=1,ncols=2)
ax3,ax4 = axes2.flatten()

ax3.hist(ipc_list, n_bins, density=True, color=colors, histtype='bar', label=bm_labels,edgecolor='black')
ax3.legend(prop={'size': 10})        
ax3.set_title('Instructions per Cycle')
ax3.set_xlabel('IPC')
ax3.set_ylabel("Frequency")

ax4.bar(l, ipc_list[0], w, color=colors[0],label=bm_labels[0],edgecolor='black')
ax4.bar(l + w, ipc_list[1], w,color=colors[1],label=bm_labels[1],edgecolor='black')
ax4.bar(l - w, ipc_list[2], w,color=colors[2],label=bm_labels[2],edgecolor='black')

ax4.set_title('IPC Seperated by Bpred Type')
ax4.set_ylabel("IPC")
ax4.set_xticks(l)
ax4.set_xticklabels(bpred_labels)
ax4.legend()
f = plt.gcf()
f.set_size_inches(12.8,7.2)
plt.savefig('./bm_output/IPC.png',dpi=100)


fig3, axes3 = plt.subplots(nrows=1,ncols=2)
ax5,ax6 = axes3.flatten()

ax5.hist(addr_bimod_list, n_bins, density=True, color=colors, histtype='bar', label=bm_labels,edgecolor='black')
ax5.legend(prop={'size': 10})        
ax5.set_title('Bimod Address Prediction Rate by Value')
ax5.set_xlabel('Address Prediction Rate')

ax6.bar(l, addr_bimod_list[0], w, color=colors[0],label=bm_labels[0],edgecolor='black')
ax6.bar(l + w, addr_bimod_list[1], w,color=colors[1],label=bm_labels[1],edgecolor='black')
ax6.bar(l - w, addr_bimod_list[2], w,color=colors[2],label=bm_labels[2],edgecolor='black')

ax6.set_title('Address Prediction Rate Seperated by Bpred Type')
ax6.set_ylabel("Address Prediction Rate")
ax6.set_xticks(l)
ax6.set_xticklabels(bpb_labels)
ax6.legend()
f = plt.gcf()
f.set_size_inches(12.8,7.2)
plt.savefig('./bm_output/addr_bimod.png',dpi=100)
