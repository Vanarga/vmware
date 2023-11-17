function Copy-FileToServer {
    <#
    .SYNOPSIS
        Copy a file to a VM.

    .DESCRIPTION

    .PARAMETER Path

    .PARAMETER Hostname

    .PARAMETER Username

    .PARAMETER Password

    .PARAMETER ViHandle

    .PARAMETER Upload

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Copy-FileToServer -Path < > -Hostname < > -Username < > -Password < > -ViHandle < > -Upload < >

        PS C:\> Copy-FileToServer

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Copy-FileToServer
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $Path,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $Hostname,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [SecureString]$Credential,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $ViHandle,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $Upload
    )

    Write-SeparatorLine

    for ($i=0; $i -le ($Path.count/2)-1;$i++) {
        Write-Host -Object "Sources: `n"
        Write-Output -InputObject $Path[$i*2] | Out-String
        Write-Host -Object "Destinations: `n"
        Write-Output -InputObject $Path[($i*2)+1] | Out-String
        if ($Upload) {
            $params = @{
                VM = $Hostname
                LocalToGuest = $true
                Source = $Path[$i*2]
                Destination = $Path[($i*2)+1]
                GuestUser = $Credential.Username
                GuestPassword = $Credential.GetNetworkCredential().password
                Server = $ViHandle
                Force = $true
            }
            Copy-VMGuestFile @params
        } else {
            $params = @{
                VM = $Hostname
                GuestToLocal = $true
                Source = $Path[$i*2]
                Destination = $Path[($i*2)+1]
                GuestUser = $Credential.Username
                GuestPassword = $Credential.GetNetworkCredential().password
                Server = $ViHandle
                Force = $true
            }
            Copy-VMGuestFile @params
        }
    }
    Write-SeparatorLine
}