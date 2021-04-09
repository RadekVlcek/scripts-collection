# DISCLAIMER: This script is not functional anymore and serves only for pleasure of your eyes

# Description: Add log files to zip archive on daily basis (setup via task scheduler)

Import-Module Pscx

# Server name
$hostname = $env:computername

# Yesterday's date
$yesterday = [datetime]::now.addDays(-1).date

# Folder containing the files that need to be zipped
$targetFolder = "D:\IMAGIN\IMAGIN\"

# Folder where the archive needs to be stored
$destinationFolder = "D:\IMAGIN\IMAGIN\IMAGIN\"

# Name of the zipped file (archive)
$zipFile = $hostname + "_" + ($yesterday.ToString('dd-MM-yyyy') + '.zip') 

# Select the files to be added to the zip file
$files = Get-ChildItem $targetFolder | Where-Object {$_.CreationTime.date -eq $yesterday} | sort lastWriteTime -desc

# Add the files to the zip file
Try {
	$files | Write-Zip -OutputPath ($destinationFolder + $zipFile) -EntryPathRoot $targetFolder
}
	
Catch {
	Write-Host $_.Exception
}

# Remove files from the target folder
forEach($file in $files){
	Remove-Item (Join-Path $targetFolder $file)
}