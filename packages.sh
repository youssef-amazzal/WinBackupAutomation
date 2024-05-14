#!/bin/bash

# Install dependencies if not already installed
$PWSH -Command "Start-Process -Wait -Verb RunAs powershell -ArgumentList '-ExecutionPolicy Bypass -Command cd \"$WIN_SCRIPT_PATH\"; .\\InstallDeps.ps1'"

# Run winget list and store the output in a variable
Raw_Ids=$($PWSH "Get-WinGetPackage | Where-Object Source -in 'winget', 'msstore' | Select-Object -Property Id,Name | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1")

# package.csv file
echo "Id,Name" > packages.csv

# Count the total number of IDs
Total=$(echo "$Raw_Ids" | wc -l)

# Initialize the counter
Counter=0

while IFS=',' read -r Id Name
do
    ((Counter++))
    # Calculate the percentage of completion
    Percent=$((100 * Counter / Total))
    # Display the progress bar
    printf "\rProgress: [%-50s] %d%%" $(printf '%.0s#' $(seq 1 $((Percent / 2)))) $Percent

    # Write to packages.csv
    echo "$Id,$Name" >> packages.csv
done <<< "$Raw_Ids"

# Print a newline at the end to avoid messing up the terminal
echo

# Display packages.csv
cat packages.csv
