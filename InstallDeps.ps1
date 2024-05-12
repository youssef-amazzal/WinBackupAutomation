# Check if the Microsoft.WinGet.Client module is already installed
Write-Host "Checking if Microsoft.WinGet.Client module is installed..."
$module = Get-Module -ListAvailable -Name Microsoft.WinGet.Client

# If the module is not installed, install it
if (-not $module) {
    Write-Host "Microsoft.WinGet.Client module is not installed. Installing..."
    Install-PackageProvider -Name NuGet -Force | Out-Null
    Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
    Repair-WinGetPackageManager
    Write-Host "Microsoft.WinGet.Client module has been installed."
} else {
    Write-Host "Microsoft.WinGet.Client module is already installed."
}