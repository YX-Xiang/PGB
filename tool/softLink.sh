#!/bin/bash

source_folder="/home/yxxiang/data/pangenome/benchmark/data/homo_sapiens/raw"
destination_folder="/home/yxxiang/data/pangenome/benchmark/data/homo_sapiens/dataset_8"

# 检查目标文件夹是否存在，如果不存在则创建
if [ ! -d "$destination_folder" ]; then
    mkdir -p "$destination_folder"
fi

# 遍历源文件夹中的子文件夹
for subdir in "$source_folder"/*; do
    # 检查子文件夹是否是一个目录
    if [ -d "$subdir" ]; then
        # 获取子文件夹中以"_xx.fa"结尾的文件，并创建软链接到目标文件夹下
        find "$subdir" -maxdepth 1 -type f -name "*_chroms.fa" -exec ln -s {} "$destination_folder" \;
    fi
done
