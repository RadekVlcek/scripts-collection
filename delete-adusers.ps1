# DISCLAIMER: This script is not functional anymore and serves only for pleasure of your eyes

# Description: Delete ADUC users from .csv file in the same directory

Import-Module ActiveDirectory

$users = Import-Csv .\USERS.csv | Sort-Object UsersToDelete | Select-Object -ExpandProperty UsersToDelete

forEach($user in $users){
    $user_id = Get-ADUser -Filter {name -eq $user}
    Write-Host "Removing user: $user_id"
    Remove-ADUser -Identity $user_id
}