function Install-OpenSSL {
    <#
    .SYNOPSIS
        Check is module is installed.

    .DESCRIPTION

    .PARAMETER InputObject

    .PARAMETER FilePath

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Save-ToJson -InputObject < > -FilePath < >

        PS C:\> Save-Json

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-25
        Version 1.0 - Install-OpenSSL
    #>
    [CmdletBinding ()]
    Param ()

    # Get list of installed Applications
    $InstalledApps = Get-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object {$_.DisplayName} | Sort-Object

    # Download OpenSSL if it's not already installed
    if (-not($InstalledApps | Where-Object {$_.DisplayName -like "*openssl*"})) {
        $uri = "https://slproweb.com/products/Win32OpenSSL.html"
        $downloadRef = ((Invoke-WebRequest -uri $uri).Links | Where-Object {$_.outerHTML -like "*Win64OpenSSL_*"} | Select-Object -first 1).href.Split("/")[2]
        Write-Host -Object "Downloading OpenSSL $downloadRef ..." -ForegroundColor "DarkBlue" -BackgroundColor "White"
        $null = New-Item -Type Directory $configData.CertInfo[0].openssldir -ErrorAction SilentlyContinue
        $SSLUrl = "http://slproweb.com/download/$downloadRef"
        $SSLExe = "$env:temp\openssl.exe"
        $WC = New-Object -TypeName System.Net.WebClient
        $WC.UseDefaultCredentials = $true
        $WC.DownloadFile($SSLUrl,$SSLExe)
        $env:path = $env:path + ";$($configData.CertInfo[0].openssldir)"
        if (-not(test-Path($SSLExe))) {
            Write-Host -ForegroundColor "red" -BackgroundColor "white" -Object "Could not download or find OpenSSL. Please install the latest $downloadRef manually or update download name."
            exit
        }
        Write-Host -ForegroundColor "DarkBlue" -BackgroundColor "White" -Object "Installing OpenSSL..."
        cmd /c $SSLExe /DIR="$($configData.CertInfo[0].openssldir)" /silent /verysilent /sp- /suppressmsgboxes
        Remove-Item -Path $SSLExe
    }

    # Get list of installed Applications
    $InstalledApps = Get-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object {$_.DisplayName} | Sort-Object

    $OpenSSL = ($InstalledApps | Where-Object {$_.DisplayName -like "*openssl*"}).InstallLocation + "bin\openssl.exe"

    # Check for openssl
    Test-OpenSSL -OpenSSL $OpenSSL
}