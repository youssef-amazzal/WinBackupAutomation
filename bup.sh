#!/bin/bash

zip_and_backup() {
    local dir="$1"
    local backup_dir="$2"

    # Get the directory name
    local dirname=$(basename "$dir")

    # Zip the directory contents using zip command
    if ! zip -r "$backup_dir/${dirname}.zip" "/mnt/$dir"; then
        echo "Error: Failed to zip directory '$dir'."
        exit 1
    fi

    # Add the original path to CSV
    echo "$dir,$backup_dir/${dirname}.zip" >> "$backup_dir/original_paths.csv"

    echo "Directory '$dir' zipped and added to backup."
}

backup_dir="/mnt/c/Users/simob/backup"
mkdir -p "$backup_dir"

echo "Original_Path,Backup_Path" > "$backup_dir/original_paths.csv"

echo "Reading directories from file..."

dir="c:/Users/simob/Desktop/test"

if ! /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command "Test-Path \"$dir\"" | grep -q True; then
    echo "Error: Directory '$dir' does not exist."
    exit 1
fi

read -p "Do you want to zip directory '$dir'? (y/n): " choice

if [ "$choice" = "y" ]; then
    zip_and_backup "$dir" "$backup_dir"
    echo "Zipped"
fi
