# DISCLAIMER: This script is not functional anymore and serves only for pleasure of your eyes

# Description: Daily clean up of drive on FTP server from files older than 10 days (setup via task scheduler)

$scriptName = "zftp-file-cleanup"
$destination = "D:\IMAGIN\IMAGIN\"
$dayLimit = [datetime]::now.AddDays(-10).date
$logFilePath = "C:\IMAGIN2\IMAGIN2\IMAGIN2\"

function LogMessage {
	param([string]$message)

    $today = [datetime]::Now.toString("dd-MM-yyyy")
	$fileName = "$scriptName-$today.txt"
		
	Add-content (Join-Path $logFilePath $fileName) -value $message
}

LogMessage "> Searching for files older than 10 days"

Try {
	$old_files = Get-ChildItem -File $destination -recurse | Where-Object {$_.CreationTime.date -lt $dayLimit}
}

Catch {
	LogMessage $_.Exception
}

$old_files_count = $old_files | Measure-Object

if($old_files_count.Count -gt 0){
	LogMessage "> Found $($old_files_count.Count) such file(s)"
	
	forEach($file in $old_files){
		LogMessage "  Deleting file $($file.DirectoryName)\$($file.Name) (created on $($file.CreationTime.datetime))"
		
		Try {
			Remove-Item (Join-Path $file.DirectoryName $file.Name) -force
		}
		
		Catch {
			LogMessage $_.Exception
		}
	}
	
	LogMessage "> Done"	
}

else {
	LogMessage "> No such files were found"
}