function New-AuthProxyService {
    <#
    .SYNOPSIS
        Configure the Domain Join Auth Proxy Service.

    .DESCRIPTION

    .PARAMETER Deployment

    .PARAMETER ADDomain

    .PARAMETER ViHandle

    .EXAMPLE
        The example below shows the command line use with Parameters.

        New-AuthProxyService -Deployment < > -ADDomain < > -ViHandle < >

        PS C:\> New-AuthProxyService

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - New-AuthProxyService
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $Deployment,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $ViHandle,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $AdDomain
    )

    # Set Join Domain Authorization Proxy (vmcam) startype to Automatic and restart service.
    $commandList = $null
    $commandList = @()
    $commandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
    $commandList += "export VMWARE_LOG_DIR=/var/log"
    $commandList += "export VMWARE_CFG_DIR=/etc/vmware"
    $commandList += "export VMWARE_DATA_DIR=/storage"
    $commandList += "/usr/lib/vmware-vmon/vmon-cli --update vmcam --starttype AUTOMATIC"
    $commandList += "/usr/lib/vmware-vmon/vmon-cli --restart vmcam"
    $commandList += "/usr/lib/vmware-vmcam/bin/camconfig add-domain -d " + $AdDomain.ADDomain + " -u " + $AdDomain.ADVMCamUser + " -w `'" + $AdDomain.ADvmcamPass + "`'"

    # Service update
    $params = @{
        Script = $commandList
        Hostname = $Deployment.Hostname
        Credential = New-Object -TypeName System.Management.Automation.PSCredential("root", [securestring](ConvertTo-SecureString -String $Deployment.VCSARootPass -AsPlainText -Force))
        ViHandle = $ViHandle
    }
    Invoke-ExecuteScript @params
}