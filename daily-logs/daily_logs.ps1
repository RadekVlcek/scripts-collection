# DISCLAIMER: This script is not functional anymore and serves only for pleasure of your eyes

# Description: Download important logs from server on daily basis

$PCPath = "\\IMAGINARY_PC\IMAGINARY_DRIVE$\IMGAINARY_PATH\IMGAINARY_PATH"
$yesterday = (Get-Date).AddDays(-1)
$yesterday_formated = $yesterday.ToString("dd-MM-yyyy")

Get-ChildItem $PCPath | Where-Object { $_.CreationTime -lt (Get-Date).AddDays(-7) } | Remove-Item -Recurse

$log1 = Get-ChildItem -Path \\IMAGINARY_PC\IMAGINARY_DRIVE$\IMGAINARY_PATH\IMGAINARY_PATH\IMGAINARY_PATH | Where-Object { $_.LastWriteTime -gt $yesterday}
$log2 = Get-ChildItem -Path \\IMAGINARY_PC2\IMAGINARY_DRIVE2$\IMGAINARY_PATH2\IMGAINARY_PATH2\IMGAINARY_PATH2 | Where-Object { $_.LastWriteTime -gt $yesterday}

$destinationPath = "$PCPath\$yesterday_formated"
New-Item -Path $destinationPath -ItemType "directory"

Copy-Item -Path "\\IMAGINARY_PC\IMAGINARY_DRIVE$\IMGAINARY_PATH\IMGAINARY_PATH\IMGAINARY_PATH\$log1" -Destination $destinationPath -Force
Copy-Item -Path "\\IMAGINARY_PC2\IMAGINARY_DRIVE2$\IMGAINARY_PATH2\IMGAINARY_PATH2\IMGAINARY_PATH2\$log2" -Destination $destinationPath -Force