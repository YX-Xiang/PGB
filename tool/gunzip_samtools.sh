#!/bin/bash

source conda.sh
conda activate pggb

folder_path=$1

for dir in "$folder_path"/*/; do
    if [ -e "$dir"/*.fna.gz ]; then
        gunzip "$dir"/*.fna.gz
    fi

    if [ ! -e "$dir"/*.fai ]; then
        fna_files=("$dir"/*.fna)
        samtools faidx "$fna_files"
        echo "Processed $fna_files"
    fi
done

conda deactivate