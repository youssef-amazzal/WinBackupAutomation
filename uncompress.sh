#!/bin/bash

# Source the setupEnv.sh script
source setupEnv.sh

# Function to uncompress a tarball and move the directories back to their original locations
uncompress_and_move() {
    local original_path="$1"
    local name="$2"

    # Extract the directory from the tarball
    if ! (cd "$BACKUP_DIR" && tar -xf "WinBackup.tar.gz" "$name"); then
        echo "Error: Failed to extract directory '$name' from tarball."
        exit 1
    fi

    # Check if the directory already exists
    if [ -d "$original_path/$name" ]; then
        read -p "Directory '$original_path/$name' already exists. Do you want to overwrite it? (y/n) " yn
        case $yn in
            [Yy]* ) ;;
            * ) echo "Skipping directory '$name'."; return;;
        esac
    fi

    # Move the directory back to its original location
    if ! rsync -a "$BACKUP_DIR/$name/" "$original_path/$name" && rm -r "$BACKUP_DIR/$name"; then
        echo "Error: Failed to move directory '$name' to '$original_path'."
        exit 1
    fi

    echo "Directory '$name' moved to '$original_path'."
}

main() {
    echo "Reading original paths from file..."

    # Uncompress the tarball
    if ! tar -xzf "$BACKUP_DIR/WinBackup.tar.gz"; then
        echo "Error: Failed to uncompress tarball."
        exit 1
    fi

    local original_paths=$(tail -n +2 "$BACKUP_DIR/original_paths.csv")
    IFS=$'\n'
    for line in $original_paths; do
        IFS=',' read -r -a array <<< "$line"
        uncompress_and_move "${array[0]}" "${array[1]}"
    done
}

main