#!/bin/bash

BasePath='\\wsl.localhost\Ubuntu\'$PWD
# Install winget if it is not already installed
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command "Start-Process -Wait -Verb RunAs powershell ' -ExecutionPolicy Bypass -Command cd $BasePath; .\InstallDeps.ps1'"

# Run winget list and store the output in a variable
Raw_Ids=$(/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe "Get-WinGetPackage | Select-Object -Property Id")

# Delete the header line
Raw_Ids=$(echo "$Raw_Ids" | tail -n +4)

# package.csv file
echo "Id,Name" > packages.csv

# Save the original IFS
OIFS="$IFS"

# Change IFS to newline
IFS=$'\n'

# Count the total number of IDs
Total=$(echo "$Raw_Ids" | wc -l)

# Initialize the counter
Counter=0

for Id in $Raw_Ids
do
    # Increment the counter
    ((Counter++))

    # Calculate the percentage of completion
    Percent=$((100 * Counter / Total))

    # Display the progress bar
    printf "\rProgress: [%-50s] %d%%" $(printf '%.0s#' $(seq 1 $((Percent / 2)))) $Percent

    # Remove leading and trailing whitespace
    Id=$(echo "$Id" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

    # Skip empty lines and the header line
    if [[ -z "$Id" ]]; then
        continue
    fi

    # Get the package source and name in one call
    Result=$(/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe "Get-WinGetPackage -Id \"$Id\" | Select-Object -Property Source,Name | Out-String -Stream")
    Source=$(echo "$Result" | awk 'NR==4 {print $1}')
    Name=$(echo "$Result" | awk 'NR==4 {print $2}')

    # if the source is not winget or msstore, skip the package
    if [[ "$Source" != "winget" && "$Source" != "msstore" ]]; then
        continue
    fi

    echo "$Id,$Name" >> packages.csv
done

# Print a newline at the end to avoid messing up the terminal
echo

# Restore the original IFS
IFS="$OIFS"


cat packages.csv