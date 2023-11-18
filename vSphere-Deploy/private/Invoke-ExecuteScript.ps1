function Invoke-ExecuteScript {
    <#
    .SYNOPSIS
        Execute a script via Invoke-VMScript.

    .DESCRIPTION
        Execute a script via Invoke-VMScript.

    .PARAMETER Script
        The mandatory string array Script is the array if strings containing the commands to be executed.

    .PARAMETER Hostname
        The mandatory string parameter Hostname is the name of the host on which the script should be executed.

    .PARAMETER Credential
        The mandatory secure string parameter Credential is the credentials needed to connect to the host.

    .PARAMETER ViHandle
        The mandatory parameter ViHandle is the session connection information for the vSphere node.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Invoke-ExecuteScript -Script <String[]>
                             -Hostname <String>
                             -Credential <Secure String>
                             -ViHandle <VI Session>

        PS C:\> Invoke-ExecuteScript

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Invoke-ExecuteScript
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string[]]$Script,
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
            $ViHandle
    )

    Write-SeparatorLine

    $Script | ForEach-Object {Write-Output $_} | Out-String

    Write-SeparatorLine

    return Invoke-VMScript -ScriptText $(if ($Script.count -gt 1) {$Script -join(";")} else {$Script}) -vm $Hostname -GuestUser $Credential.Username -GuestPassword $Credential.GetNetworkCredential().password -Server $ViHandle
}