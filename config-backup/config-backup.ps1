# DISCLAIMER: This script is not functional anymore and serves only for pleasure of your eyes

# Description: Make backup of important configuration file in the same directory with date and version number in its filename

$pc_name = $env:COMPUTERNAME
$date = Get-Date -Format 'yyyyMMdd'
$config_file = ".\Config_$($env:COMPUTERNAME)_$($date)-v"
$version = ((Get-Item "$config_file*" | Measure-Object).Count) + 1

Copy-Item -Path ".\Config.xml" -Destination "$config_file$version.xml"