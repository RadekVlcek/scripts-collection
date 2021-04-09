# DISCLAIMER: This script is not functional anymore and serves only for pleasure of your eyes

# Description: Search for files older than 4 months and delete them. Logging included.

$script_name = "delete-4mnt-old-files"

$destination = "F:\IMAGINARY_DRIVE$\IMAGINARY_FOLDER\"
$logFilePath = "C:\IMAGINARY_DRIVE$2\IMAGINARY_FOLDER2\"
$timeLimit = (Get-Date).AddDays(-122)

function LogMessage {
	param([string]$message)

    $today = (Get-Date).ToString("dd-MM-yyyy")
	$fileName = "$script_name-$today.txt"
		
	Add-content(Join-Path $logFilePath $fileName) -value $message
}

$startTime = Get-Date
LogMessage $startTime

LogMessage "> Searching for files older than 122 days"
Write-Host "> Searching for files older than 122 days"

# Delete old files
$all_files = Get-ChildItem $destination -Exclude XXXX1, XXXX2, XXXX3, XXXX4, XXXX5 -File -Recurse | Where-Object {$_.CreationTime -lt $timeLimit}
ForEach($file in $all_files){
    $filePath = $file.FullName
    LogMessage "  Deleting file: $filePath [Created on IMAGINARY SERVER: $($file.CreationTime)]"
    Write-Host "  Deleting file: $filePath [Created on IMAGINARY SERVER: $($file.CreationTime)]"
    Remove-Item -Path $filePath -Force
}

# Delete empty subfolders
LogMessage "> Searching for empty folders"
Write-Host "> Searching for empty folders"
$emp_folders = Get-ChildItem $destination -Directory -Recurse | Sort-Object -Property CreationTime
forEach($folder in $emp_folders){
    $folder_path = $folder.FullName
    $files_within = (Get-ChildItem $folder_path | Measure-Object).Count
	if($files_within -lt 1){
		LogMessage "  Deleting folder $folder_path ($files_within files within)"
        Write-Host "  Deleting folder $folder_path ($files_within files within)"
		Remove-Item -Path $folder_path -Force
	}
}

# Some statistics
$files_count = ($all_files | Measure-Object).Count
$total_size_deleted = ($all_files | Measure-Object -Property Length -Sum | Select-Object -ExpandProperty Sum)/1MB
LogMessage "> Done. Deleted $($files_count) old files."
Write-Host "> Done. Deleted $($files_count) old files."
LogMessage ">       Total size deleted: $total_size_deleted MB"
Write-Host ">       Total size deleted: $total_size_deleted MB"

# Calculate runtime
$endTime = Get-Date
$runTimeTemp = New-TimeSpan $startTime $endTime
$runTimeTotal = "$($runTimeTemp.minutes)min $($runTimeTemp.Seconds).$($runTimeTemp.Milliseconds)sec"

LogMessage "Terminating script"
LogMessage "[Script runtime: $runTimeTotal]"