[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$SourceFile
)

CLS

$fileContent = Get-Content -Path $SourceFile



$password = ConvertTo-SecureString "Admin123" -AsPlainText -Force

foreach ($line in $fileContent) {
    $parts = $line -split ","
    $first_name = $parts[0].Trim()
    $last_name = $parts[1].Trim()

    $baseUsername = ($first_name.Substring(0,1) + $last_name).ToLower()

    $username = $baseUsername
    $counter = 1


    while (Get-ADObject -Filter "SamAccountName -eq '$username'") {
    $username = "$baseUsername$counter"
    $counter++
    }

    try{

        $params = @{
            Name                  = $username
            SamAccountName        = $username
            UserPrincipalName     = "$username@comp2150.private"
            Path                  = "OU=Students,DC=comp2150,DC=private"
            AccountPassword       = $password
            Enabled               = $true
            ChangePasswordAtLogon = $true
        }

        New-ADUser @params
            
        $createdUser = Get-ADUser -Filter { SamAccountName -eq $username}
        if ($createdUser) {
            Write-Host "SUCCESS: User '$username' ($first_name $last_name) created." -ForegroundColor Green
        }
        else {
            Write-Host "ERROR: User '$username' was NOT found after creation." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "FAILED: Could not create user '$username'. Error: $_" -ForegroundColor Red
    }
}
