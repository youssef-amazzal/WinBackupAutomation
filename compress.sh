#!/bin/bash

# Source the setupEnv.sh script
source setupEnv.sh

# Function to create a tarball of a directory
create_tarball() {
    local dir="$1"
    local dirname=$(basename `path_to_wsl "$dir"`)

    # Convert the Windows-style path to a Linux-style path
    local linux_dir=$(path_to_wsl "$dir")

    # Get the parent directory of the original path
    local parent_dir=$(dirname "$linux_dir")

    # Append the directory to the existing tarball
    if ! (cd "$(dirname "$linux_dir")" && tar -rf "$BACKUP_DIR/WinBackup.tar" "$(basename "$linux_dir")");  then
        echo "Error: Failed to add directory '$dir' to tarball."
        exit 1
    fi

    echo "$parent_dir,$dirname" >> "$BACKUP_DIR/original_paths.csv"
    echo "Directory '$dir' added to tarball."
}

check_directory() {
    local dir="$1"

    if ! test -d "$dir"; then
        echo "Error: Directory '$dir' does not exist."
        return 1
    fi

    return 0
}

prompt_tarball() {
    local dir="$1"

    read -p "Do you want to tarball directory '$dir'? (y/n): " choice

    if [ "$choice" = "y" ]; then
        create_tarball "$dir"
    fi
}

main() {
    echo "Original_Path,Name" > "$BACKUP_DIR/original_paths.csv"
    echo "Reading directories from file..."

    # Remove the existing tarball if it exists
    rm -f "$BACKUP_DIR/WinBackup.tar"

    local backup_paths=$(cat directories_to_backup.txt)
    for dir in $backup_paths; do
        if check_directory $(path_to_wsl "$dir"); then
            prompt_tarball "$dir"
        fi
    done

    # Compress the tarball
    gzip "$BACKUP_DIR/WinBackup.tar"
}

main