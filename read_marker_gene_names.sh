#!/bin/bash

# Set the directory path
folder_path="tipp2-refpkg/markers-v3"

# Create the output text file
output_file="marker_genes_names.txt"

# Remove the output file if it already exists
if [ -f "$output_file" ]; then
    rm "$output_file"
fi

# Loop through each folder in the specified directory
for folder_name in "$folder_path"/*; do
    if [ -d "$folder_name" ]; then
        # Extract just the folder name from the full path
        folder_name=$(basename "$folder_name")
        echo "$folder_name" >> "$output_file"
    fi
done

echo "Folder names have been written to $output_file"
