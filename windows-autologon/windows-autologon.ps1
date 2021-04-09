# DISCLAIMER: This script is not functional anymore and serves only for pleasure of your eyes

# Description: Enable windows autologon for local admin on windows 10 workstation

set-executionpolicy unrestricted

$station = $Env:Computername
$password = "myP@ssword"
$domain = "domain.local"

try {
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoAdminLogon -Value 1
    Write-Host "AutoAdminLogon... done"
}

catch {
    Write-Host $_.Exception.Message
}

try {
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultUserName -Value $station
    Write-Host "DefaultUserName... done"
}

catch {
    Write-Host $_.Exception.Message
}

try {
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultPassword -Value $password
    Write-Host "DefaultPassword... done"
}

catch {
    Write-Host $_.Exception.Message
}

try {
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultDomainName -Value $domain
    Write-Host "DefaultDomainName... done"
}

catch {
    Write-Host $_.Exception.Message
}

Read-Host 'Done. Press key to exit...'