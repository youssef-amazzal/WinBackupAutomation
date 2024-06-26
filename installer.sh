#!/bin/bash

# Source the setupEnv.sh script
source setupEnv.sh

# Function to get packages from the CSV file
get_packages() {
    if [ ! -f packages.csv ]; then
        handle_error $MISSING_FILE "The 'packages.csv' file is missing."
        exit 1
    fi

    local packages_csv=$(tail -n +2 packages.csv)
    if [ -z "$packages_csv" ]; then
        handle_error $EMPTY_FILE "The 'packages.csv' file is empty."
        exit 1
    fi

    IFS=$'\n' read -d '' -r -a lines <<< "$packages_csv"
    echo "${lines[@]}"
}

# Function to install a package
install_package() {
    local id=$1
    local package_name=$2
    if ! is_package_installed $id; then
        pwsh_install_package "$id"
        if ! is_package_installed $id; then
            log_message "ERROR" "Failed to install package: $package_name"
            echo "$package_name" >> failed_packages.txt
        else
            log_message "INFO" "Successfully installed package: $package_name"
        fi
    fi
}

main() {
    # Read packages from CSV file, skipping the header line
    mapfile -t packages < <(tail -n +2 packages.csv)

    # Install dependencies if not already installed
    for line in "${packages[@]}"
    do
        IFS=',' read -r id package_name <<< "$line"
        id=${id//\"/}  # Remove double quotes from id
        package_name=${package_name//\"/}  # Remove double quotes from package_name
        
        log_message "INFO" "Installing package: $package_name"
        install_package "$id" "$package_name"
    done

    if [[ $? -ne 0 ]]; then
        log_message "ERROR" "An error occurred during the installation process."
    fi
}

main