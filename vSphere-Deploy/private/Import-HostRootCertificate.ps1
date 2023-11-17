function Import-HostRootCertificate {
    <#
    .SYNOPSIS
        Download the Node self signed certificate and install it in the local trusted root certificate store.

    .DESCRIPTION

    .PARAMETER CertDir

    .PARAMETER Deployment

    .PARAMETER ViHandle

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Import-HostRootCertificate -CertDir < > -Deployment < > -ViHandle < >

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
            $CertDir,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $Deployment,
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

    Import-Certificate -FilePath $RootCertDir -CertStoreLocation 'Cert:\LocalMachine\Root' -Verbose

    Write-SeparatorLine
}