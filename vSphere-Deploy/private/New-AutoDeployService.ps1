function New-AutoDeployService {
    <#
    .SYNOPSIS
        Configure the Autodeploy Service - set auto start, register vCenter, and start service.

    .DESCRIPTION
        Configure the Autodeploy Service - set auto start, register vCenter, and start service.

    .PARAMETER Deployment
        The mandatory parameter Deployment contains all the settings for a specific vSphere node deployement.

    .PARAMETER ViHandle
        The mandatory parameter ViHandle is the session connection information for the vSphere node.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        New-AutoDeployService -Deployment <String[]>
                              -ViHandle <VI Session>

        PS C:\> New-AutoDeployService

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - New-AutoDeployService
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string[]]$Deployment,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $ViHandle
    )

    $commandList = $null
    $commandList = @()
    $credential = New-Object -TypeName System.Management.Automation.PSCredential("root", [securestring](ConvertTo-SecureString -String $Deployment.VCSARootPass -AsPlainText -Force))

    # Register Autodeploy to vCenter if not changing certificates.
    if (-not $Deployment.Certs) {
        $commandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
        $commandList += "export VMWARE_LOG_DIR=/var/log"
        $commandList += "export VMWARE_CFG_DIR=/etc/vmware"
        $commandList += "export VMWARE_DATA_DIR=/storage"
        $commandList += "/usr/lib/vmware-vmon/vmon-cli --stop rbd"
        $commandList += "/usr/bin/autodeploy-register -R -a " + $Deployment.IP + " -u Administrator@" + $Deployment.SSODomainName + " -w `'" + $Deployment.SSOAdminPass + "`' -p 80"
        $params = @{
            Script = $commandList
            Hostname = $Deployment.Hostname
            Credential = $credential
            ViHandle = $ViHandle
        }
        Invoke-ExecuteScript @params
    }

    # Set Autodeploy (rbd) startype to Automatic and restart service.
    $commandList = $null
    $commandList = @()
    $commandList += "export VMWARE_PYTHON_PATH=/usr/lib/vmware/site-packages"
    $commandList += "export VMWARE_LOG_DIR=/var/log"
    $commandList += "export VMWARE_CFG_DIR=/etc/vmware"
    $commandList += "export VMWARE_DATA_DIR=/storage"
    $commandList += "/usr/lib/vmware-vmon/vmon-cli --update rbd --starttype AUTOMATIC"
    $commandList += "/usr/lib/vmware-vmon/vmon-cli --restart rbd"

    # imagebuilder set startype to Automatic and restart service.
    $commandList += "/usr/lib/vmware-vmon/vmon-cli --update imagebuilder --starttype AUTOMATIC"
    $commandList += "/usr/lib/vmware-vmon/vmon-cli --restart imagebuilder"

    # Service update
    $params = @{
        Script = $commandList
        Hostname = $Deployment.Hostname
        Credential = $credential
        ViHandle = $ViHandle
    }
    Invoke-ExecuteScript @params
}