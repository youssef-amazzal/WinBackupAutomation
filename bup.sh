#!/bin/bash

# Function to zip the directory contents and add to backup
zip_and_backup() {
    local dir="$1"
    local backup_dir="$2"

    # Get the directory name
    local dirname=$(basename "$dir")
    
    # Zip the directory contents
    if ! zip -r "$backup_dir/${dirname}.zip" "$dir"; then
        echo "Error: Failed to zip directory '$dir'."
        exit 1
    fi

    # Add the original path to CSV
    echo "$dir,$backup_dir/${dirname}.zip" >> "$backup_dir/original_paths.csv"

    echo "Directory '$dir' zipped and added to backup."
}

# Path to backup directory
backup_dir="/mnt/c/Users/simob/backup"
mkdir -p "$backup_dir"

# Header for CSV
echo "Original_Path,Backup_Path" > "$backup_dir/original_paths.csv"

echo "Reading directories from file..."

# Loop through directories listed in the file
$WIN_PWD="//wsl.localhost/Ubuntu/$(pwd)"
while IFS= read -r dir; do
    # Check if the directory exists using PowerShell
    if ! /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command "Test-Path \"$WIN_PWD/$dir\"\"" | grep -q True; then
        echo "Error: Directory '$dir' does not exist."
        continue
    fi

    # Confirm zipping with user
    read -p "Do you want to zip directory '$dir'? (y/n): " choice

    # Check user's choice
    if [ "$choice" = "y" ]; then
        zip_and_backup "$dir" "$backup_dir"
    elif [ "$choice" != "n" ]; then
        echo "Invalid choice, skipping directory '$dir'."
    fi
done < ./directories_to_backup.txt
