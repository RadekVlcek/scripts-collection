# DISCLAIMER: This script is not functional anymore and serves only for pleasure of your eyes

# Description: Delete files older than 1 year

$script_name = "delete-old-files-366"

$destinations = "D:\IMAGINARY_PATH1\IMAGINARY_PATH1\IMAGINARY_PATH1\", "D:\IMAGINARY_PATH2\IMAGINARY_PATH2\IMAGINARY_PATH2\"
$logFilePath = "C:\IMAGINARY_PATH3\IMAGINARY_PATH3\IMAGINARY_PATH3\"

$day_limit = [datetime]::now.AddDays(-366).date

$excluded_folders = ""
$files_total = 0
$files_total_bytes = 0

function LogMessage {
	param([string]$message)

    $today = [datetime]::Now.toString("dd-MM-yyyy")
	$fileName = "test-$script_name-$today.txt"
		
	Add-content (Join-Path $logFilePath $fileName) -value $message
}

$start_time = Get-Date
LogMessage $start_time

# Get all folders
LogMessage "> Searching through all files within all folder folders"
Write-Host "> Searching through all files within all folder folders"

forEach($destination in $destinations){
	LogMessage "Cleaning up files in: $destination"
	Write-Host "Cleaning up files in: $destination"
	
	$folders = Get-ChildItem -Path $destination -Exclude $excluded_folders
	
	# Loop through folders
	forEach($folder in $folders){
			LogMessage "> Searching folder: $folder"
			Write-Host "> Searching folder: $folder"
			
			$folder_path = (Join-Path $destination $folder)
			$files_per_folder = Get-ChildItem -Path $folder -File -Recurse | Where-Object { $_.CreationTime -lt $day_limit }
		
			# If any old files within folder folder are found
			if($files_per_folder.Count -gt 0){
				forEach($file in $files_per_folder){
					$file_path = (Join-Path $($file.DirectoryName) $file)
					
					LogMessage "  Deleting file: $file_path"
					Write-Host "  Deleting file: $file_path"
					
					# Delete recording
					Remove-Item $file_path -Force
					
					$recordings_total++
					$files_total_bytes += $file.Length
				}
			}
			else {
				LogMessage "  No old files for this folder"
				Write-Host "  No old files for this folder"
			}
	}
}

# Delete empty subfolders
LogMessage "> Searching for empty folders"
$emp_folders = Get-ChildItem "D:\IMAGINARY_PATH4\IMAGINARY_PATH4\" -Directory -Recurse | Sort-Object -Property CreationTime
forEach($folder in $emp_folders){
    $folder_path = $folder.FullName
    $files_within = (Get-ChildItem $folder_path | Measure-Object).Count
	if($files_within -lt 1){
		LogMessage "   Deleting folder $folder_path ($files_within files)"
		Remove-Item $folder_path -Force
	}
}

# Calculate runtime
$end_time = Get-Date
$run_time_temp = New-TimeSpan $start_time $end_time
$run_time_total = "$($run_time_temp.minutes)min $($run_time_temp.Seconds).$($run_time_temp.Milliseconds)sec"

LogMessage "Total amount of files removed: $files_total"
LogMessage "Total space freed up: $($files_total_bytes / 1KB) KB"
S
LogMessage "Terminating script"
LogMessage "  [Script runtime: $run_time_total]"