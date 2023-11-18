function Copy-FileToServer {
    <#
    .SYNOPSIS
        Copy a file to a VM.

    .DESCRIPTION
        Copy a file to a VM.

    .PARAMETER Path
        The mandatory string array parameter Path holds the source and destination paths for the file copy.

    .PARAMETER Hostname
        The mandatory string parameter Hostname is the name of the destination host to copy the file to.

    .PARAMETER Username
        The mandatory string parameter Username is the username needed to authenticate with the destination host.

    .PARAMETER Password
        The mandatory secure string parameter Password is the password needed to authenticate with the destination host.

    .PARAMETER ViHandle
        The mandatory parameter ViHandle is the session connection information for the vSphere node.

    .PARAMETER Upload
        The mandatory Boolean parameter Upload will cause the file to be sent to the destination if True and downloaded if False.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Copy-FileToServer -Path <String>
                          -Hostname <String>
                          -Username <String>
                          -Password <String>
                          -ViHandle <VI Session>
                          -Upload <Bool>

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
            [string]$Path,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string]$Hostname,
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
            [bool]$Upload
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