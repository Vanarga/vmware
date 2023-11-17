function New-NetDumpsterService {
    <#
    .SYNOPSIS
        Configure Network Dumpster to Auto Start and start service.

    .DESCRIPTION

    .PARAMETER Hostname

    .PARAMETER Username

    .PARAMETER Password

    .PARAMETER ViHandle

    .EXAMPLE
        The example below shows the command line use with Parameters.

        New-NetDumpsterService -Hostname < > -Username < > -Password < > -ViHandle < >

        PS C:\> New-NetDumpsterService

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - New-NetDumpsterService
    #>
    [CmdletBinding ()]
    Param (
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

    $commandList = $null
    $commandList = @()

    $commandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
    $commandList += "export VMWARE_LOG_DIR=/var/log"
    $commandList += "export VMWARE_CFG_DIR=/etc/vmware"
    $commandList += "export VMWARE_DATA_DIR=/storage"
    $commandList += "/usr/lib/vmware-vmon/vmon-cli --update netdumper --starttype AUTOMATIC"
    $commandList += "/usr/lib/vmware-vmon/vmon-cli --start netdumper"

    # Service update
    $params = @{
        Script = $commandList
        Hostname = $Hostname
        Credential = $Credential
        ViHandle = $ViHandle
    }
    Invoke-ExecuteScript @params
}