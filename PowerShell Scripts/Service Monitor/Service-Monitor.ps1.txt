CLS


# Script Parameters
$LogFile = "C:\Scripts\ServiceLog.txt"
$ServiceName = "PlugPlay"
$TestInterval = 30 # In Seconds



# Check if log file exists
if (-not (Test-Path -Path $LogFile)){

    # Create empty log file if no log file exists
    New-Item -Path $LogFile -ItemType File -Force | Out-Null
    Write-Host "New Log File Created at: $LogFile"

} else {
    Write-Host "Logging Data is Available at: $LogFile"
}


# Log Function
Function Write-Log{
    Param($Message)
    $Timestamp = Get-Date
    $LogEntry = "$TimeStamp - $Message"
    Write-Host $LogEntry
    $LogEntry | Out-File -FilePath $LogFile -Append
}

# Notification Function
Function Notify{
    Param($Message)
    $URI = "https://api.pushover.net/1/messages.json"
    $UserKey = "urdwd3ni1qujdq2cwqmic8vf86poxk"
    $ApiToken = "a3o3jvz1bstrbasytco7trtx6bawis"

    #build api call body
    $body = @{
        token   = $ApiToken
        user    = $UserKey
        message = $Message 
	title   = "Service Monitor Alert"
        sound   = "alien"
    }

    Invoke-RestMethod -Uri $URI -Method Post -Body $body
}




# Check service validity
Try {
    Get-Service $ServiceName -ErrorAction Stop
    Write-Host "Monitoring Service $ServiceName"
    }
Catch
    {
    Write-Log "The service name $ServiceName is invalid!"
    Exit
    }


While ($True) {
    $Service = Get-Service $ServiceName
    if ($Service.Status -ne 'Running') {
        Write-Log "Service '$ServiceName' is '$($Service.Status)'. Attempting restart..."
        Notify "Service '$ServiceName' is '$($Service.Status)'. Attempting restart..."
        Try {
            Start-Service -Name $ServiceName -ErrorAction Stop
            Write-Log "Service '$ServiceName' was restarted."
            Notify "Service '$ServiceName' was restarted."
        } Catch {
            Write-Log "Failed to restart '$ServiceName': $_"
            Notify "Failed to restart '$ServiceName': $_"
        }
     } else {
         Write-Log "Service '$ServiceName' is running."
     }

    Start-Sleep -Seconds $TestInterval
}
    


