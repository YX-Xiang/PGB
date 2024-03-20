#!/bin/bash

set_id=$1
input_folder=/home/yxxiang/data/pangenome/benchmark/result/dataset_${set_id}

input_mc_gfafile=${input_folder}/mc_16/dataset_${set_id}.gfa
input_pggb_gfafiles=(${input_folder}"/pggb_16/"*smooth.final.gfa)

input_mc_time_memory_file=${input_folder}/mc_16//TimeMemory.txt
input_pggb_time_memory_file=${input_folder}/pggb_16/TimeMemorySegmentation.txt

bash table_stat.sh mc ${input_mc_gfafile} ${input_mc_time_memory_file} ${input_folder}/mc_16/info
echo '+++ Finished graph statistics generated by minigraph-cactus !'

for file in "${input_pggb_gfafiles[@]}"; do
    bash table_stat.sh pggb ${file} ${input_pggb_time_memory_file} ${input_folder}/pggb_16/info
done
echo '+++ Finished graph statistics generated by pggb !'
