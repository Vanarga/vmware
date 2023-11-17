function Invoke-ExecuteScript {
    <#
    .SYNOPSIS
        Execute a script via Invoke-VMScript.

    .DESCRIPTION

    .PARAMETER Script

    .PARAMETER Hostname

    .PARAMETER Username

    .PARAMETER Password

    .PARAMETER ViHandle

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Invoke-ExecuteScript -Script < > -Hostname < > -Username < > -ViHandle < >

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
            $Script,
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
            $ViHandle
    )

    Write-SeparatorLine

    $Script | ForEach-Object {Write-Output $_} | Out-String

    Write-SeparatorLine

    return Invoke-VMScript -ScriptText $(if ($Script.count -gt 1) {$Script -join(";")} else {$Script}) -vm $Hostname -GuestUser $Credential.Username -GuestPassword $Credential.GetNetworkCredential().password -Server $ViHandle
}