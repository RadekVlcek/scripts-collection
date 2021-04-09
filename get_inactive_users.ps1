# DISCLAIMER: This script is not functional anymore and serves only for pleasure of your eyes

# Description: (Run on domain controller) Export inactive ADUC users into .csv file

$time = (Get-Date).Adddays(-90)
Get-ADUser -Filter {LastLogonTimeStamp -lt $time -and enabled -eq $true} |
Sort-Object -Property Name |
Select-Object -Property Name,SamAccountName |
Export-Csv .\inactive_users.csv -NoTypeInformation