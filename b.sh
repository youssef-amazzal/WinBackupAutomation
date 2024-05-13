#!/bin/bash

# Function to process folder
process_folder() {
    folder_path="$1"
    # Your processing logic here
    echo "Processing folder: $folder_path"
    # For demonstration, let's list files in the folder
    ls "$folder_path"
}

# Main function
main() {
    # File containing directory paths
    file_path="directory_paths.txt"

    # Check if the file exists
    if [ ! -f "$file_path" ]; then
        echo "Error: File not found."
        exit 1
    fi

    # Read each directory path from file
    while IFS= read -r dir_path; do
        # Check if the directory exists
        if [ ! -d "$dir_path" ]; then
            echo "Error: Directory $dir_path not found."
        else
            # Process the folder
            process_folder "$dir_path"
        fi
    done < "$file_path"
}

# Call the main function
main
