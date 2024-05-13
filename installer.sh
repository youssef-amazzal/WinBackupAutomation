powershell="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
WIN_PWD="//wsl.localhost/Ubuntu/$(pwd)"
PACKAGES_CSV=$(tail -n +2 packages.csv)

# Convert PACKAGES_CSV into an array of lines
IFS=$'\n' read -d '' -r -a lines <<< "$PACKAGES_CSV"

# Install dependencies if not already installed
for line in "${lines[@]}"
do
    IFS=',' read -r id package_name <<< "$line"
    id=${id//\"/}  # Remove double quotes from id
    package_name=${package_name//\"/}  # Remove double quotes from package_name
    
    echo "Checking package: $package_name"
    if ! $powershell -Command "Get-WinGetPackage -Id $id" | grep -q "$id"; then
        echo "Installing package: $package_name"
        if ! $powershell -Command "winget install --id=$id -e"; then
            echo "Failed to install package: $package_name"
            echo "$package_name" >> failed_packages.txt
        else
            echo "Successfully installed package: $package_name"
        fi
    else
        echo "Package already installed: $package_name"
    fi
done

if [[ $? -ne 0 ]]; then
    echo "An error occurred during the installation process."
fi