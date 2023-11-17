function Get-URLStatus {
    <#
    .SYNOPSIS
        Test url for TCP Port 80 Listening.

    .DESCRIPTION

    .PARAMETER URL

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Get-URLStatus -URL < >

        PS C:\> Get-URLStatus

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Get-URLStatus
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $URL
    )

    # Test url for TCP Port 80 Listening.
    While (-not(Test-NetConnection -ComputerName $($URL.Split("//")[2]) -Port 80).TCPTestSucceeded) {
        Write-Host -Object "`r`n $URL not ready, sleeping for 30 sec.`r`n" -Foregroundcolor Cyan
        Start-Sleep -Seconds 30
    }

    # https://stackoverflow.com/questions/46036777/unable-to-connect-to-help-content-the-server-on-which-help-content-is-stored-mi
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls, Ssl3"

    # Make sure that the url is Get-URLStatus.
    Do {
        $failed = $false
        Try {
            (Invoke-WebRequest -uri $URL -UseBasicParsing -TimeoutSec 20 -ErrorAction Ignore).StatusCode -ne 200
        }
        Catch {
            $failed = $true
            Write-Host -Object "`r`n $URL not ready, sleeping for 30 sec.`r`n" -Foregroundcolor Cyan
            Start-Sleep -Seconds 30
        }
    } While ($failed)
}