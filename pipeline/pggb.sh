#!/bin/bash

source conda.sh
conda activate pggb

file_list=$1
seq_number=$2
out_name=$3
threads=$4
output_folder=../result/${out_name}/pggb_${threads}
input=${output_folder}/${out_name}.fa

if [ -d "$output_folder" ]; then
    rm -rf "$output_folder"
    echo "Folder cleared: $output_folder"
fi
mkdir -p "$output_folder"
echo "Folder created: $output_folder"

> ${input}

while IFS= read -r line || [[ -n $line ]]; do
   if [[ $(tail -n 1 "$line" | wc -l) -eq 0 ]]; then
        cat "$line" >> "$input"
        echo "" >> "$input"
    else
        cat "$line" >> "$input"
    fi
done < $file_list

samtools faidx ${input}
echo "Sequences are already Prepared!"

# 运行pggb
/usr/bin/time --format="%e\t%M" -a -o ${output_folder}/TimeMemory.txt pggb -i ${input} \
    -p 95 -s 10000 -n ${seq_number} \
    -A -D ${output_folder}/tmp \
    -t ${threads} -T ${threads} -Z -o ${output_folder} > ${output_folder}/log

gzip -d ${output_folder}/*.gfa.gz

conda deactivate

# log分段计时
input_file=${output_folder}/log
output_file1=$(dirname "$input_file")/TimeMemoryTemp.txt
output_file2=$(dirname "$input_file")/TimeMemorySegmentation.txt

> ${output_file1}
grep -B 1 "max memory$" ${input_file} > ${output_file1}


> ${output_file2}
echo -n -e "Wfmash-map:\t\t" >> ${output_file2}
sed -n '2p' ${output_file1} | awk '{print $7"\t\t"$(NF-2)}' >> ${output_file2}

echo -n -e "Wfmash-align:\t" >> ${output_file2}
sed -n '5p' ${output_file1} | awk '{print $7"\t\t"$(NF-2)}' >> ${output_file2}

echo -n -e "Seqwish:\t\t" >> ${output_file2}
sed -n '8p' ${output_file1} | awk '{print $7"\t\t"$(NF-2)}' >> ${output_file2}

echo -n -e "Smoothxg:\t\t" >> ${output_file2}
sed -n '11p' ${output_file1} | awk '{print $7"\t\t"$(NF-2)}' >> ${output_file2}

echo -n -e "Gfaffix:\t\t" >> ${output_file2}
sed -n '13p' ${output_file1} | awk '{print $7"\t\t"$(NF-2)}' >> ${output_file2}

echo -n -e "Odgi:\t\t\t" >> ${output_file2}
odgi_total_time=0
odgi_max_memory=0
while IFS= read -r line
do
    if [[ $line == odgi* ]]; then
        read -r next_line

        # 提取下一行的第一个字符（用时）和倒数第三个字符（内存），并去除单位
        t=$(echo "$next_line" | awk '{gsub(/s/, "", $7); print $7}')
        m=$(echo "$next_line" | awk '{gsub(/Kb/, "", $(NF-2)); print $(NF-2)}')

        # 计算用时的累加和
        odgi_total_time=$(echo "$odgi_total_time + $t" | bc)

        # 更新最大值
        if (( $(echo "$m > $odgi_max_memory" | bc -l) )); then
            odgi_max_memory=$m
        fi
    fi
done < ${output_file1}
echo -e "${odgi_total_time}s\t\t${odgi_max_memory}kb" >> ${output_file2}