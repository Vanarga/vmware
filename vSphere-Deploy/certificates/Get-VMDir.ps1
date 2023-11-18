function Get-VMDir {
    <#
    .SYNOPSIS
        Displays the currently used VMDir certificate via OpenSSL.

    .DESCRIPTION
        Displays the currently used VMDir certificate via OpenSSL.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Get-VmDir

        PS C:\> Get-VmDir

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Get-VmDir
    #>
    [CmdletBinding ()]
    Param ()
    $computerName = Get-WmiObject -Class Win32_ComputerSystem
    $defFQDN = "$($computerName.Name).$($computerName.Domain)".ToLower()
    $vmDirHost = $(
        Write-Host -Object "Do you want to dispaly the VMDir SSL certificate of $defFQDN ?"
        $inputFQDN = Read-Host "Press ENTER to accept or input a new FQDN"
        if ($inputFQDN) {
            $inputFQDN
        } else {
            $defFQDN
        }
    )
    $params = @{
        openSSLArgs = "s_client -servername $vmDirHost -connect `"${vmDirHost}:636`""
    }
    Invoke-OpenSSL @params
}