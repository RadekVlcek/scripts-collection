# DISCLAIMER: This script is not functional anymore and serves only for pleasure of your eyes

# Description: Convert wav files in folder to mp3 format using lame.exe and send over FTP using WinSCP to destination host
# WinSCP plugin required. Also port 22/2222 needs to be open on destination firewall.

# Set folder number here
$folder = "IMAGIN"

# Generate yesterday's date in proper notation
$today = Get-Date
$yesterday = $today.AddDays(-1)
$yesterdayInDub = Get-Date $yesterday -format "yyyyMMdd"
$yesterdayInDutchNotation = Get-Date $yesterday -format "dd-MM-yyyy"

# E-mail constants
$folderManagerNameAndEmailAddress = "<email.email@email.com>"
$systemNameAndEmailAddress = "email@email.com <email@email.com>"
$SMTPserverForSendingEmail = "email-com.mail.mailprotection.outlookmail.com"
$managerCCemailAddress = "<email@email.com>"

$ftp_user = ""
$ftp_pwd = ""
$ftp_host = ""
$ftp_port = 22
$ftp_passphrase = ""

# Path to LAME for conversion from .wav to .mp3
$lamePathAndExeName = "C:\Program Files\Lame\lame.exe"

# Path to folder folder
$wavFileBasePath = "\\IMAGINARY_SERVER\IMAGINARY_DRIVE$\IMAGINARY_PATH\$($folder)\"

# Path to WinSCP program
$winSCPPathAndExeName = "C:\IMAGINARY_PATH\IMAGINARY_PATH\IMAGINARY_PATH\WinSCP\WinSCP.com"

# Final path to date folder in folder folder
$combinedPath = $wavFileBasePath + $yesterdayInDub;

# Create "tempmp3" folder in case it doesn't exist
if(!(Test-Path (Join-Path $wavFileBasePath "tempmp3"))){
	New-Item -Path "$wavFileBasePath\$($folder)\tempmp3" -ItemType Directory
}

# Final path to "tempmp3" folder
$mp3OutputPath = "\\IMAGINARY_SERVER2\IMAGINARY_DRIVE2$\IMAGINARY_PATH\$($folder)\tempmp3\"

# find all files in the directory.
$files = Get-ChildItem -Path "$combinedPath" -filter "*.wav"

if($files) {
    # make sure the output directory has no mp3 files when we start
    Try {
        Get-ChildItem -Path "$mp3OutputPath" -filter "*.mp3" | Remove-Item -Force
    }
	
    Catch {
        Write-Error "Error deleting temporary mp3 files from directory $mp3OutputPath"
    }
   
    Write-Output "Started converting to mp3."

    foreach($file in $files) {
        $wavPathAndFileName=$file.Fullname
      
        $mp3PathAndFileName=$mp3OutputPath+$file.BaseName+".mp3"

        $lameParameters="-b 32 `"$wavPathAndFileName`" `"$mp3PathAndFileName`""
		
        Try {
            # This is where we call lame.exe to convert the .wav file to .mp3. Doing it through a start 
            Start-Process $lamePathAndExeName -ArgumentList $lameParameters -WindowStyle Normal -PassThru -Wait
            Write-Output "Converted a file to mp3."
        }
		
        Catch {
            Write-Error "Error running lame $lamePathAndExeName with the parameters $lameParameters"
        }
    }
	
	$WinSCPparameters= "/command ""open sftp://$ftp_user:$ftp_pwd@$ftp_host:$ftp_port -passphrase=$ftp_passphrase"" ""lcd "+$mp3OutputPath+""" ""put -nopreservetime *.mp3"" ""close"" ""exit""";
	
    Try {
        Start-Process $winSCPPathAndExeName -ArgumentList $WinSCPparameters -WindowStyle Normal -PassThru -Wait
        # send-mailmessage -to $folderManagerNameAndEmailAddress -from $systemNameAndEmailAddress -Cc $managerCCemailAddress -subject "$folder - Some message." -body "Some more messages" -priority High -smtpServer $SMTPserverForSendingEmail
    }
	
    Catch {
        Write-Error "Error running WinSCP $winSCPPathAndExeName with the parameters $WinSCPparameters"
    }

    Try {
        Get-ChildItem -Path "$mp3OutputPath" -filter "*.mp3" | Remove-Item -Force
    }
	
    Catch {
        Write-Error "Error deleting temporary mp3 files from directory $mp3OutputPath"
    }
}

else {
    Write-Output "There were no wav files found in directory $combinedPath"
	
    # Send email to PM & ICT stating that there were no files and stop.
	send-mailmessage -to $folderManagerNameAndEmailAddress -from $systemNameAndEmailAddress -Cc $managerCCemailAddress -subject "$folder - No files to convert and upload." -body "There were no files to be converted and uploaded for $folder for $yesterdayInDutchNotation ." -smtpServer $SMTPserverForSendingEmail
}