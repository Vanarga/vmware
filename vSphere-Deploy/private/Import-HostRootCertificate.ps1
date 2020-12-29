function Import-HostRootCertificate {
    <#
    .SYNOPSIS
        Download the Node self signed certificate and install it in the local trusted root certificate store.

    .DESCRIPTION

    .PARAMETER CertPath

    .PARAMETER Deployment

    .PARAMETER VIHandle

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Import-HostRootCertificate -CertPath < > -Deployment < > -VIHandle < >

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
            $CertPath,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $Deployment,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $VIHandle
    )

    Write-SeparatorLine

    $rootCertPath = $CertPath+ "\" + $Deployment.Hostname.Split(".")[0] + "_self_signed_root_cert.crt"

    $credential = New-Object -TypeName System.Management.Automation.PSCredential("root", [securestring](ConvertTo-SecureString -String $Deployment.VCSARootPass -AsPlainText -Force))

    $commandList = $null
    $commandList = @()
    $commandList += "/usr/lib/vmware-vmafd/bin/dir-cli trustedcert list --login `'administrator@" + $Deployment.SSODomainName + "`' --password `'" + $Deployment.SSOAdminPass + "`' | grep `'CN(id):`'"
    $params = @{
        Script = $commandList
        Hostname = $Deployment.Hostname
        Credential = $credential
        ViHandle = $VIHandle
    }
    $Certid = $(Invoke-ExecuteScript @params).Scriptoutput.Split("")[2]

    $commandList = $null
    $commandList = @()
    $commandList += "/usr/lib/vmware-vmafd/bin/dir-cli trustedcert get --id $Certid --outcert /root/vcrootcert.crt --login `'administrator@" + $Deployment.SSODomainName + "`' --password `'" + $Deployment.SSOAdminPass + "`'"
    $params = @{
        Script = $commandList
        Hostname = $Deployment.Hostname
        Credential = $credential
        ViHandle = $VIHandle
    }
    Invoke-ExecuteScript @params

    $filePath = $null
    $filePath = @()
    $filePath += "/root/vcrootcert.crt"
    $filePath += $rootCertPath
    $params = @{
        Path = $filePath
        Hostname = $Deployment.Hostname
        Credential = $credential
        VIHandle = $VIHandle
        Upload = $false
    }
    Copy-FileToServer @params

    Import-Certificate -FilePath $rootCertPath -CertStoreLocation 'Cert:\LocalMachine\Root' -Verbose

    Write-SeparatorLine
}