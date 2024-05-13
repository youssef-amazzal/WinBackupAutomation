#!/bin/bash

# Function to zip directory and add it to backup
zip_and_backup() {
    local dir="$1"
    local backup_dir="$2"

    # Get the directory name
    local dirname=$(basename "$dir")

    # Zip the directory using PowerShell
    /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command "Compress-Archive -Path \"$dir\" -DestinationPath \"$backup_dir/${dirname}.zip\""

    # Add the original path to CSV
    echo "$dir,$backup_dir/${dirname}.zip" >> "$backup_dir/original_paths.csv"

    echo "Directory '$dir' zipped and added to backup."
}

# Function to decompress directory to its original path
decompress_to_original_path() {
    local original_path="$1"
    local backup_path="$2"

    # Unzip the directory using PowerShell
    /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command "Expand-Archive -Path \"$backup_path\" -DestinationPath \"$original_path\""

    echo "Directory '$original_path' decompressed to its original path."
}

# Create a directory for the backup
backup_dir="/mnt/c/Users/simob/backup"
mkdir -p "$backup_dir"

# Create CSV file with original file paths
echo "Original_Path,Backup_Path" > "$backup_dir/original_paths.csv"

# Read directories from the file and perform backup
echo "Reading directories from file..."
while IFS= read -r dir; do
    # Check if the directory exists using PowerShell
    if ! /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command "Test-Path \"$dir\"" | grep -q True; then
        echo "Error: Directory '$dir' does not exist."
        continue
    fi

    # Check if the directory is empty
   

    read -p "Do you want to zip directory '$dir'? (y/n): " choice

    if [ "$choice" = "y" ]; then
        zip_and_backup "$dir" "$backup_dir"
    fi
done < ./directories_to_backup.txt

# Ask user if they want to decompress files
read -p "Do you want to decompress these directories? (y/n): " choice
if [ "$choice" = "y" ]; then
    while IFS=, read -r original_path backup_path; do
        decompress_to_original_path "$original_path" "$backup_path"
    done < "$backup_dir/original_paths.csv"
fi
