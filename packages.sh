#!/bin/bash

source setupEnv.sh

# Run winget list and store the output in a variable
Packages=$(pwsh_get_installed_packages) || handle_error $? "Failed to get installed packages"

# package.csv file
echo "Id,Name" > packages.csv || handle_error $COMMAND_EXECUTION_FAIL "Failed to write to 'packages.csv'"

while IFS=',' read -r Id Name
do
    # Write to packages.csv
    echo "$Id,$Name" >> packages.csv || handle_error $COMMAND_EXECUTION_FAIL "Failed to write to 'packages.csv'"
done <<< "$Packages"

log_message "SUCCESS" "Installed packages saved to 'packages.csv' file."