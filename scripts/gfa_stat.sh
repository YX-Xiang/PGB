#!/bin/bash

input_gfafile=$1
output_folder=$2
output_file=${output_folder}/gfa_info.txt

/home/yxxiang/data/pangenome/Bandage/Bandage info ${input_gfafile} > ${output_file}