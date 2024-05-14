#!/bin/bash

decompress_to_original_path() {
    local original_path="$1"
    local backup_path="$2"

    # Unzip the directory using PowerShell
    /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command "Expand-Archive -Path \"$backup_path\" -DestinationPath \"$original_path\""

    echo "Directory '$original_path' decompressed to its original path."
}

read -p "Do you want to decompress these directories? (y/n): " choice
if [ "$choice" = "y" ]; then
    while IFS=, read -r original_path backup_path; do
        decompress_to_original_path "$original_path" "$backup_path"
    done < "$backup_dir/original_paths.csv"
fi