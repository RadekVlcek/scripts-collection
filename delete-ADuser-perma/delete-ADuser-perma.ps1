# DISCLAIMER: This script is not functional anymore and serves only for pleasure of your eyes

# Description: Delete ADUC user with all account features

Import-Module ActiveDirectory

$user = "Name Surname"
$newPwd = "NewPasswordForUser"
$userObject = Get-ADUser -Filter {Name -eq $user}

# 1. Change password
Write-Host "Changing password"
$userObject | Select-Object -expandProperty SamAccountName | Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $newPwd -Force)

# 2. Remove AD group memberships if any
$groups = $userObject | Get-ADPrincipalGroupMembership | Where-Object {$_.name -ne "Domain Users"}
if(($groups | Measure-Object).Count -gt 0){
    forEach($group in $groups){
        Write-Host "Removing membership from group $($group | Select-Object name)"
        Remove-ADGroupMember -Identity $group -Members $userObject
    }
}
else {
    Write-Host "No group membership to be deleted."
}

# 3. Set msExchHideFromAddressLists to True
Write-Host "Setting msExchHideFromAddressLists attribute to True."
Set-ADUser -Identity $userObject -Replace @{"msExchHideFromAddressLists" = $True}

# 4. Set msDS-cloudExtensionAttribute1 to HideFromGAL
Write-Host "Setting msDS-cloudExtensionAttribute1 attribute to HideFromGAL."
Set-ADUser -Identity $userObject -Replace @{"msDS-cloudExtensionAttribute1" = "HideFromGAL"}

# 5. Edit Description with a date of deletion (1st day of a month)
$split = [datetime]::now.AddDays(90).ToString("dd-MM-yyyy").Split("-")
$final_date = "$($split[0] - $($split[0] - 1)).$($split[1]).$($split[2])"
Write-Host "Updating user description with date of deletion."
Set-ADuser -Identity $userObject -Description "To be deleted on $final_date"