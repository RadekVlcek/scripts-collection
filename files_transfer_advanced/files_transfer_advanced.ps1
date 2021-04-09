# DISCLAIMER: This script is not functional anymore and serves only for pleasure of your eyes

# Description: automatic transfer of specific files and some more features

$source = "E:\IMAGINARY_PATH\IMAGINARY_PATH\"
$destinationServer = "server.domain.local"
$destination = "\\$($destinationServer)\IMAGINARY_DRIVE$\IMAGINARY_PATH2\IMAGINARY_PATH2\IMAGINARY_PATH2\IMAGINARY_PATH2\"
$logFilePath = "D:\IMAGINARY_PATH3\IMAGINARY_PATH3\"
$logSymbol = ">>"

# Lists to store metadata
$meta = New-Object System.Collections.Generic.List[System.Object]
$destinationMeta = New-Object System.Collections.Generic.List[System.Object]

# Write to log file
function LogMessage {
	param([string]$message)
	$today = "$(Get-Date -UFormat %m-%d-%y).txt"
	Add-content (Join-Path $logFilePath $today) -value $message
}

# Create Specif/sub folder if it doesn't exist
function CreateFolder {
  param([string]$folderPath, [string]$folderType)
  if(!(Test-Path $folderPath)){
    New-Item $folderPath -Type Directory
    if($folderType -eq "Specif") { $type = "Specif" }
    else { $type = "DATE" }
    LogMessage "   Creating new $($type) folder: $($folderPath)"
	Write-Host "   Creating new $($type) folder: $($folderPath)"
  }
  else { return }
}

# Check if file is currently open (in use by server)
function TestFileLock {
  param([parameter(Mandatory=$true)][string]$path)
  $oFile = New-Object System.IO.FileInfo $path
  try {
    $oStream = $oFile.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
    if($oStream){
      $oStream.Close()
    }
    return $false
  }
  catch { return $true }
}

Write-Host "Script running"

$startTime = Get-Date
LogMessage $($startTime)

# Test connection to dest server
if(Test-Connection $destinationServer -Quiet){
  LogMessage "$($logSymbol) Testing connection to '$($destinationServer)'`r`n   Connection OK"
  Write-Host "$($logSymbol) Testing connection to '$($destinationServer)'`r`n   Connection OK"
  LogMessage "$($logSymbol) Transferring Files"
  Write-Host "$($logSymbol) Transferring Files"

  $copiedFilesTotalAmount = 0
  $lockedFilesTotalAmount = 0
  $sourceSpecifs = Get-ChildItem -Name $source

  forEach($SpecifFolder in $sourceSpecifs){
    $sourceSpecifPath = Join-Path $source $SpecifFolder
    $destinationSpecifPath = Join-Path $destination $SpecifFolder

    # If doesn't exist, create new Specif folder in DST
    CreateFolder $destinationSpecifPath "Specif"

    $sourceSpecifDates = Get-ChildItem -Name $sourceSpecifPath
    
    forEach($subfolder in $sourceSpecifDates){
      $sourceSpecifDatePath = Join-Path $sourceSpecifPath $subfolder
      $destinationSpecifDatePath = Join-Path $destinationSpecifPath $subfolder

      # If doesn't exist, create new sub folder in DEST
      CreateFolder $destinationSpecifDatePath "date"
      
      $sourceFilesAmount = (Get-ChildItem $sourceSpecifDatePath | Measure-Object).Count
      $destinationFilesAmount = (Get-ChildItem $destinationSpecifDatePath | Measure-Object).Count

      # Proceed only if there are new files found in SRC sub folder
      if($sourceFilesAmount -gt 0){
        $copiedFilesTempAmount = 0
        $lockedFilesTempAmount = 0
        $sourceFiles = Get-ChildItem -Name $sourceSpecifDatePath

        forEach($File in $sourceFiles){
          $path = Join-Path $sourceSpecifDatePath $File
          if(!(TestFileLock $path)){
            Move-Item $path $destinationSpecifDatePath
            LogMessage "   Transferring '$($File)'"
			Write-Host "   Transferring '$($File)'"
            $copiedFilesTempAmount++
            $copiedFilesTotalAmount++
          }
          else {
            $lockedFilesTempAmount++
            $lockedFilesTotalAmount++
          }
        }

        $meta.Add([ordered]@{
          "SpecifFolder" = $SpecifFolder;
          "subfolder" = $subfolder;
          "copiedFiles" = $copiedFilesTempAmount;
          "destinationFilesAmount" = $destinationFilesAmount;
          "lockedFiles" = $lockedFilesTempAmount
        })

        # Amount of Files in DEST after the transfer
        $destinationMeta.Add((Get-ChildItem $destinationSpecifDatePath | Measure-Object).Count)
      }
    }
  }

  if($copiedFilesTotalAmount -eq 1) { $FileTotalWord = "File" }
  else { $FileTotalWord = "Files" }
  LogMessage "   Done`r`n$($logSymbol) Counting Files"
  Write-Host "   Done`r`n$($logSymbol) Counting Files"
  LogMessage "   $($copiedFilesTotalAmount) $($FileTotalWord) transferred`r`n   $($lockedFilesTotalAmount) Files locked by server"
  Write-Host "   $($copiedFilesTotalAmount) $($FileTotalWord) transferred`r`n   $($lockedFilesTotalAmount) Files locked by server"
}

else {
  LogMessage "$($logSymbol) Testing connection to $($destinationServer)...`r`n   Connection FAILED"
  Write-Host "$($logSymbol) Testing connection to $($destinationServer)...`r`n   Connection FAILED"
  exit
}

# Check Files
$errorAmount = 0
if($copiedFilesTotalAmount -gt 0){
  LogMessage "$($logSymbol) Checking Files"
  Write-Host "$($logSymbol) Checking Files"
  
  for($x=0 ; $x -lt ($meta | Measure-Object).Count ; $x++){
      $sum = ($meta[$x]["copiedFiles"] + $meta[$x]["destinationFilesAmount"])

      if($sum -eq $destinationMeta[$x]){
        # If any locked Files exist
        if($meta[$x]["lockedFiles"] -gt 0){
          if($meta[$x]["lockedFiles"] -lt 2){ $FileMessage1 = "File" }
          else { $FileMessage1 = "Files" }
          $lockedWarning = ", $($meta[$x]["lockedFiles"]) $($FileMessage1) locked (in use by STG)"
        }
  
        else {
          $lockedWarning = ", no locked Files"
        }
        
        if($meta[$x]["copiedFiles"] -lt 2) { $FileMessage2 = "File " }
        else { $FileMessage2 = "Files" }

        LogMessage "   $($meta[$x]["SpecifFolder"]) [$($meta[$x]["subfolder"])] -> $($meta[$x]["copiedFiles"]) $($FileMessage2) transferred$($lockedWarning)"
		Write-Host "   $($meta[$x]["SpecifFolder"]) [$($meta[$x]["subfolder"])] -> $($meta[$x]["copiedFiles"]) $($FileMessage2) transferred$($lockedWarning)"
      }
      else {
        LogMessage "   ERROR! $($meta[$x]["SpecifFolder"]) ($($meta[$x]["subfolder"])) -> $($sum - $destinationMeta[$x]) File(s) might be missing"
		Write-Host "   ERROR! $($meta[$x]["SpecifFolder"]) ($($meta[$x]["subfolder"])) -> $($sum - $destinationMeta[$x]) File(s) might be missing"
        $errorAmount++
      }
  }

  LogMessage "   Done"
  Write-Host "   Done"
}

else {
  LogMessage "   No new Files were found"
  Write-Host "   No new Files were found"
}

# E-mail settings
if($copiedFilesTotalAmount -eq 0){ $copiedFilesTotalAmount = "No" }
if($errorAmount -eq 0){ $errorAmount = "No" }

$SMTPMailServer = "EMAIL.COM.MAIL.MAILPROTECTION.OUTLOOKMAIL.COM"
$emailSender = "LARGE FILES <LARGER-FILES@EMAIL.COM>"
$emailRecipient = "<EMAIL.EMAIL@EMAIL.com>,<EMAIL2@EMAIL2.com>"
$emailSubject = "$($copiedFilesTotalAmount) new File(s) transferred to dest server"
$emailBody = "Please check 'files_transfer_log.txt' on server for more details`r`n`r`n   $($copiedFilesTotalAmount) File(s) transferred`r`n   $($errorAmount) error(s) detected`r`n`r`nPlease do not reply to this auto-generated message"

# Send e-mail notification
LogMessage "$($logSymbol) Sending e-mail to $($emailRecipient) (This feature is temporarily disabled)"
Write-Host "$($logSymbol) Sending e-mail to $($emailRecipient)"
Send-MailMessage -From $emailSender -To $emailRecipient -Subject $emailSubject -body $emailBody -SmtpServer $SMTPMailServer -Port "25"

# Calculate runtime
$endTime = Get-Date
$runTimeTemp = New-TimeSpan $startTime $endTime
$runTimeTotal = "$($runTimeTemp.minutes)min $($runTimeTemp.Seconds).$($runTimeTemp.Milliseconds)sec"

LogMessage "$($logSymbol) Terminating script`r`n   [Script runtime: $($runTimeTotal)]"
Write-Host "$($logSymbol) Terminating script`r`n   [Script runtime: $($runTimeTotal)]"
LogMessage "---------------"

Write-Host "Done`r`nCheck 'files_transfer_log.txt' for details"