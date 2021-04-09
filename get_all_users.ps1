# DISCLAIMER: This script is not functional anymore and serves only for pleasure of your eyes

# Description: (Run from domain controller) Export all AD users into .csv file

Get-ADUser -filter * |
Sort-Object -Property Name |
Select-Object -Property Name,SamAccountName |
Export-Csv .\all_users.csv -NoTypeInformation