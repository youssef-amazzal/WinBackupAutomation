#!/bin/bash

# ===================== Load User Settings =====================
USER_SETTINGS_FILE="$HOME/.win_backup_config"

load_settings() {
    if [ -f $USER_SETTINGS_FILE ]; then
        source $USER_SETTINGS_FILE
    else
        # Log Directory
        LOGDIR="$HOME/WinBackupAutomation"
        export LOGDIR

        mkdir -p $LOGDIR || handle_error $COMMAND_EXECUTION_FAIL "Failed to create log directory."

        # Log file path
        LOGFILE="$LOGDIR/history.log"
        export LOGFILE

        touch $LOGFILE || handle_error $COMMAND_EXECUTION_FAIL "Failed to create log file."
    fi
}
export -f load_settings

load_settings

# ===================== Helper functions =====================

display_help() {
    echo "Usage: bash script.sh [options] [parameters]"
    echo
    echo "+) Parameters: files, directories"
    echo "+) Options:"
    echo "   -h (help)         Display detailed program documentation."
    echo "   -f (fork)         Execute using sub-processes with fork."
    echo "   -t (thread)       Enable execution using threads."
    echo "   -s (subshell)     Execute the program in a subshell."
    echo "   -l (log)          Specify a directory for storing the log file."
    echo "   -r (restore)      Restore default settings."
    echo "   -d (destination)  Specify the destination folder (will be the last parameter)."
    echo
    exit 1
}

log_message() {
    local message_type=$1
    local message=$2
    local output_type=$3
    local timestamp=$(date '+%Y-%m-%d-%H-%M-%S')
    local username=$(whoami)
    if [[ $output_type == 'ERROR' ]]; then
        echo "$timestamp : $username : $message_type : $message" | tee -a $LOGFILE >&2
    else
        echo "$timestamp : $username : $message_type : $message" | tee -a $LOGFILE
    fi
}
export -f log_message

handle_error() {
    local exit_code=$1
    local message=$2
    log_message 'ERROR' "$message" 'ERROR'
    if [ $exit_code -eq $OBLIGATORY_PARAMS ] || [ $exit_code -eq $INVALID_OPTION ]; then
        display_help
    fi
    exit $exit_code
}
export -f handle_error

install_dependency() {
    local package=$1

    # Check if the package is installed
    dpkg -s $package &> /dev/null
    if [ $? -eq 0 ]; then
        # No log message when the package is already installed
        :
    else
        log_message 'INFO' "Installing $package..." 'INFO'
        sudo apt-get install -y $package >> $LOGDIR/install.log 2>&1
        if [ $? -eq 0 ]; then
            log_message 'SUCCESS' "Successfully installed $package." 'SUCCESS'
        else
            handle_error $PACKAGE_INSTALL_FAIL "Failed to install $package."
        fi
    fi
}
export -f install_dependency

pwsh_install_deps() {
    $PWSH -Command "Start-Process -Wait -Verb RunAs powershell -ArgumentList '-ExecutionPolicy Bypass -Command cd \"$WIN_SCRIPT_PATH\"; .\\InstallDeps.ps1'" 
    if [ $? -eq 100 ]; then
        # No log message when the dependencies are already installed
        :
    else
        if [ $? -eq 0 ]; then
            log_message 'SUCCESS' 'Finished installing powershell dependencies.'
        else
            log_message 'INFO' 'Starting installing powershell dependencies...'
            handle_error $PACKAGE_INSTALL_FAIL "Failed to install powershell dependencies."
        fi
    fi
}
export -f pwsh_install_deps
pwsh_install_package() {
    local id=$1
    log_message 'INFO' "Starting installing package with id: $id..."
    $PWSH -Command "winget install --id=$id -e" > /dev/null 2>&1 || handle_error $COMMAND_EXECUTION_FAIL "Failed to install package with id: $id."
    log_message 'SUCCESS' "Finished installing package with id: $id."
}
export -f pwsh_install_package

pwsh_get_installed_packages() {
    log_message 'INFO' 'Getting installed packages...' >&2
    local packages=$($PWSH "Get-WinGetPackage | Where-Object Source -in 'winget', 'msstore' | Select-Object -Property Id,Name | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1") || handle_error $COMMAND_EXECUTION_FAIL "Failed to get installed packages."
    log_message 'SUCCESS' 'Installed packages retrieved.' >&2
    echo "$packages"
}
export -f pwsh_get_installed_packages

is_package_installed() {
    local id=$1
    log_message 'INFO' "Checking if package with id: $id is installed..."
    local package=$($PWSH -Command "Get-WinGetPackage -Id $id")
    if [[ -z "$package" || "$package" != *"$id"* ]]; then
        log_message 'ERROR' "Package with id: $id is not installed."
        return 1
    else
        log_message 'SUCCESS' "Package with id: $id is installed."
        return 0
    fi
}
export -f is_package_installed

path_to_wsl() {
    local path="$1"
    wslpath -u "$path"
}

path_to_win() {
    local path=$1
    wslpath -w "$path"
}

# ===================== Setup Error variables =====================

# Error Handling
INVALID_OPTION=100
OBLIGATORY_PARAMS=101
PACKAGE_INSTALL_FAIL=102
INVALID_PACKAGE_ID=103
COMMAND_EXECUTION_FAIL=104
MISSING_FILE=105
EMPTY_FILE=106

export INVALID_OPTION
export OBLIGATORY_PARAMS
export PACKAGE_INSTALL_FAIL
export INVALID_PACKAGE_ID
export COMMAND_EXECUTION_FAIL
export MISSING_FILE
export EMPTY_FILE

# ===================== Setup Main Variables =====================

# Install wslu
install_dependency "wslu"

# Powershell path
PWSH="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
export PWSH

# Script Absoulte path for Windows
WIN_SCRIPT_PATH=$(wslpath -w $(pwd))
export WIN_SCRIPT_PATH

# Windows Username
WIN_USERNAME=$(wslvar USERNAME)

# Windows Home Directory
WIN_HOME=$(wslpath `wslvar USERPROFILE`)

# Backup Directory
BACKUP_DIR="$WIN_HOME/backup"

mkdir -p $BACKUP_DIR || handle_error $COMMAND_EXECUTION_FAIL "Failed to create backup directory."

# ===================== Setup Dependencies =====================

# Install zip and unzip
install_dependency "zip"
install_dependency "unzip"

# ===================== Setup script directories =====================

# Setup script directories
mkdir -p /mnt/c/Users/$WIN_USERNAME/backup || handle_error $COMMAND_EXECUTION_FAIL "Failed to create backup directory."