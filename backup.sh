#!/bin/bash

zip_and_backup() {
    local dir="$1"
    local backup_dir="$2"

    # Get the directory name
    local dirname=$(basename "$dir")
    echo "$dir"
    # Create a tarball of the directory contents using tar command
    if ! tar -czf "$backup_dir/${dirname}.tar.gz" -C "$dir" .;  then
        echo "Error: Failed to create tarball of directory '$dir'."
        exit 1
    fi

    # Add the original path to CSV
    echo "$dir,$backup_dir/${dirname}.tar.gz" >> "$backup_dir/original_paths.csv"

    echo "Directory '$dir' tarballed and added to backup."
}

backup_dir="/mnt/c/Users/simob/backup"
mkdir -p "$backup_dir"

echo "Original_Path,Backup_Path" > "$backup_dir/original_paths.csv"

echo "Reading directories from file..."

WIN_PWD="//wsl.localhost/Ubuntu/$(pwd)"
BACKUP_PATHS=$(cat directories_to_backup.txt)
for dir in $BACKUP_PATHS; do
    # Check if the directory exists using Linux test command
    if ! test -d "$dir"; then
        echo "Error: Directory '$dir' does not exist."
        continue
    fi
    # Check if the directory is empty

    read -p "Do you want to tarball directory '$dir'? (y/n): " choice

    if [ "$choice" = "y" ]; then
        zip_and_backup "$dir" "$backup_dir"
    fi
done