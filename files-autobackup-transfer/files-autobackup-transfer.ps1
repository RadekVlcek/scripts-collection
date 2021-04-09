# DISCLAIMER: This script is not functional anymore and serves only for pleasure of your eyes

# Description: hourly transfer of files from main server to backup server with nice logging feature (setup via task scheduler)

# Name of this script
$scriptName = "files-autobackup-transfer"

# Source
$sourceServer = "server1.domain.local"
$sourceDirectory = "C:\IMAGINARY_PATH\IMAGINARY_PATH\IMAGINARY_PATH\"

# Destination
$destinationServer = "server2.domain.local"
$destinationDirectory = "\\$IMAGINARY_SERVER2\IMAGINARY_DRIVE2$\IMAGINARY_PATH2\"

# Date from 1 month ago
$monthAgo = [datetime]::now.AddDays(-31).date

# Logging
$logFilePath = "L:\$scriptName\"

function LogMessageSymbol {
    param([int]$amount)

	$symbol = ""

	for($x=0 ; $x -lt $amount ; $x++){
		$symbol += ">"
	}
		
	return $symbol + " "
}

function LogMessageGap {
	param([int]$amount)

	$gap = ""

	for($x=0 ; $x -lt $amount; $x++){
		$gap += " "
	}

	return $gap
}

function LogMessage {
	param([int]$logSpaces, [int]$logSymbol, [string]$message)

    $today = [datetime]::Now.toString("dd-MM-yyyy")
    $fileName = "$scriptName-$today.txt"
	$gap = LogMessageGap($logSpaces)
    $symbol = LogMessageSymbol($logSymbol)
	$message = $gap + $symbol + $message
	
	Add-content (Join-Path $logFilePath $fileName) -value $message
}

# Script start
$startTime = Get-Date
LogMessage 0 0 $startTime

LogMessage 0 1 "Testing connection to $destinationServer"
if(Test-Connection $destinationServer -Quiet){
    LogMessage 1 0 "Connection OK"
	Write-Host "Connection OK"

    # All filess in Dub folder
    $filess = Get-ChildItem $sourceDirectory
	
	LogMessage 0 1 "Searching filess in $sourceDirectory"
	Write-Host "Searching filess in $sourceDirectory"
	
    forEach($files in $files){
		$files = $files.toString()
			
        Try {
            $dateFolders = Get-ChildItem (Join-Path $sourceDirectory $files) | Where-Object {$_.CreationTime.date -lt $monthAgo}
			LogMessage 4 0 "..."
			Write-Host "..."
			LogMessage 4 0 "files $files"
			Write-Host "files $files"
        }

        Catch {
			LogMessage 4 0 "files $files failed"
			Write-Host "files $files failed"
            LogMessage 6 0 $_.Exception
			Write-Host $_.Exception
        }
      
		LogMessage 2 2 "Searching for sub folders older than 1 month"
		if($dateFolders.length -gt 0){
			LogMessage 4 0 "Found $($dateFolders.length) such sub folders"
			Write-Host "Found $($dateFolders.length) such sub folders"
			
			# Validate 
			forEach($dateFolder in $dateFolders){
				# $dateFolder = $dateFolder.toString()
				
				# Make sure that "tempmp3" folders are excluded
				if(-not ($dateFolder -eq "tempmp3") -and -not($dateFolder -eq "tempmp3_DoNotDelete")){
					
					# Move sub folders to destination directory
					$dateFolderPath = [IO.Path]::Combine($sourceDirectory, $files, $dateFolder)
                    $destination = (Join-Path $destinationDirectory $files)

					# Create files folder in destination if it doesn't exist
					if(!(Test-Path $destination)){
						New-Item $destination -Type Directory
					}
					
					LogMessage 5 3 "Moving $dateFolderPath to $destination"
					Write-Host "Moving $dateFolderPath to $destination"
					
					Try {
                        # Log SUCCESS if moved successfully
						Move-Item -Path $dateFolderPath -Destination $destination -force
						LogMessage 8 0 "SUCCESS"
						Write-Host "SUCCESS"
					}
					
					Catch {
                        # Else log FAILURE with exception
						LogMessage 8 0 "FAILURE"
						LogMessage 10 0 $_.Exception
						Write-Host "FAILURE"
						Write-Host $_.Exception
					}
				}
			}
		}
		
		else{
			LogMessage 4 0 "No such sub folders were found"
			Write-Host "No such sub folders were found"
		}
    }
}

else{
    LogMessage 1 0 "Connection failed"
	Write-Host "Connection failed"
}

# Delete empty subfolders
LogMessage 0 1 "> Searching for empty folders"
$emp_folders = Get-ChildItem $sourceDirectory -Directory -Recurse | Sort-Object -Property CreationTime
forEach($folder in $emp_folders){
    $folder_path = $folder.FullName
    $files_within = (Get-ChildItem $folder_path | Measure-Object).Count
	if($files_within -lt 1){
		LogMessage 2 0 "Deleting folder $folder_path ($files_within files within)"
		Remove-Item -Path $folder_path -Force
	}
}

# Calculate runtime
$endTime = Get-Date
$runTimeTemp = New-TimeSpan $startTime $endTime
$runTimeTotal = "$($runTimeTemp.minutes)min $($runTimeTemp.Seconds).$($runTimeTemp.Milliseconds)sec"

LogMessage 0 1 "Terminating script"
LogMessage 1 0 "[Script runtime: $runTimeTotal]"