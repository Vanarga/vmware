function Import-HostRootCertificate {
    <#
    .SYNOPSIS
        Download the Node self signed certificate and install it in the local trusted root certificate store.

    .DESCRIPTION
        Download the Node self signed certificate and install it in the local trusted root certificate store.

    .PARAMETER CertDir
        The mandatory string parameter CertDir is the local path to the location of the replacement certificates.

    .PARAMETER Deployment
        The mandatory parameter Deployment contains all the settings for a specific vSphere node deployement.

    .PARAMETER ViHandle
       The mandatory parameter ViHandle is the session connection information for the vSphere node.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Import-HostRootCertificate -CertDir <String>
                                   -Deployment <String[]>
                                   -ViHandle <VI Session>

        PS C:\> Import-HostRootCertificate

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Import-HostRootCertificate
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string]$CertDir,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [String[]]$Deployment,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $ViHandle
    )

    Write-SeparatorLine

    $rootCertDir = $CertDir+ "\" + $Deployment.Hostname.Split(".")[0] + "_self_signed_root_cert.crt"

    $Credential = New-Object -TypeName System.Management.Automation.PSCredential("root", [securestring](ConvertTo-SecureString -String $Deployment.VCSARootPass -AsPlainText -Force))

    $commandList = $null
    $commandList = @()
    $commandList += "/usr/lib/vmware-vmafd/bin/dir-cli trustedcert list --login `'administrator@" + $Deployment.SSODomainName + "`' --password `'" + $Deployment.SSOAdminPass + "`' | grep `'CN(id):`'"
    $params = @{
        Script = $commandList
        Hostname = $Deployment.Hostname
        Credential = $credential
        ViHandle = $ViHandle
    }
    $Certid = $(Invoke-ExecuteScript @params).Scriptoutput.Split("")[2]

    $commandList = $null
    $commandList = @()
    $commandList += "/usr/lib/vmware-vmafd/bin/dir-cli trustedcert get --id $Certid --outcert /root/vcrootcert.crt --login `'administrator@" + $Deployment.SSODomainName + "`' --password `'" + $Deployment.SSOAdminPass + "`'"
    $params = @{
        Script = $commandList
        Hostname = $Deployment.Hostname
        Credential = $credential
        ViHandle = $ViHandle
    }
    Invoke-ExecuteScript @params

    $FilePath = $null
    $FilePath = @()
    $FilePath += "/root/vcrootcert.crt"
    $FilePath += $rootCertDir
    $params = @{
        Path = $FilePath
        Hostname = $Deployment.Hostname
        Credential = $credential
        ViHandle = $ViHandle
        Upload = $false
    }
    Copy-FileToServer @params

    Import-Certificate -FilePath $rootCertDir -CertStoreLocation 'Cert:\LocalMachine\Root' -Verbose

    Write-SeparatorLine
}