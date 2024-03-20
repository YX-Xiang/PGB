#!/bin/bash

mode=$1 # 'pggb' or 'mc'
input_gfafile=$2
input_time_memory_file=$3
output_folder=$4

gfa_file=${output_folder}/gfa_info.txt
output_file=${output_folder}/table_info.txt

if [ ! -d "$output_folder" ]; then
    mkdir -p "$output_folder"
fi

total_time=0
max_memory=0

> ${output_file}

if [ "${mode}" == 'pggb' ]; then
    while IFS=$'\t' read -r _ time memory; do
        # Strip the trailing 's' from the time value and convert it to float
        time="${time%s}"
        time_float=$(echo "$time" | bc -l)
        
        # Remove 'Kb' and convert memory to integer
        memory="${memory%Kb}"
        memory="${memory%kb}"
        memory_int=$(echo "$memory" | tr -d '[:space:]')

        # Update total_time
        total_time=$(echo "$total_time + $time_float" | bc -l)

        # Update max_memory
        if (( memory_int > max_memory )); then
            max_memory=$memory_int
        fi
    done < "$input_time_memory_file"
elif [ "${mode}" == 'mc' ]; then
    while IFS= read -r line; do
        read -r _ time memory <<< "$line"
        time_float=$(echo "$time" | bc -l)
        memory_int=$(echo "$memory" | tr -d '[:space:]')

        total_time=$(echo "$total_time + $time_float" | bc -l)

        # Update max_memory
        if (( memory_int > max_memory )); then
            max_memory=$memory_int
        fi
    done < "$input_time_memory_file"
else
    echo 'Error: parameter 1 can be only pggb or mc !!!'
fi

max_memory_gb=$(echo "scale=2; $max_memory / 1024 / 1024" | bc)
file_size=$(du -b "$input_gfafile" | awk '{print $1}')
file_size_gb=$(echo "scale=2; $file_size / 1024 / 1024" | bc)

printf "%.2f\n" $total_time > $output_file
printf "%.2f\n" $max_memory_gb >> $output_file
printf "%.2f\n" $file_size_gb >> $output_file


bash gfa_stat.sh ${input_gfafile} ${output_folder}

counter=1
while IFS= read -r line; do
    number=$(echo "$line" | awk '{print $NF}')
    if [[ $counter -eq 1 || $counter -eq 2 || $counter -eq 5 || $counter -eq 9 ]]; then
        echo "$number" >> ${output_file}
    fi
    ((counter++))
done < "$gfa_file"