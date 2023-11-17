function New-CertificatePair {
    <#
    .SYNOPSIS
        Configure Private/Public Keys for ssh authentication without password.

    .DESCRIPTION

    .PARAMETER CertDir

    .PARAMETER Deployment

    .PARAMETER VIHandle

    .EXAMPLE
        The example below shows the command line use with Parameters.

        New-CertificatePair -CertDir < > -Deployment < > -VIHandle < >

        PS C:\> New-CertificatePair

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - New-CertificatePair
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
            $VIHandle
    )

    $certPath = $CertDir + "\" + $Deployment.Hostname
    $credential = New-Object -TypeName System.Management.Automation.PSCredential("root", [securestring](ConvertTo-SecureString -String $Deployment.VCSARootPass -AsPlainText -Force))

    $params = @{
        Script = '[ ! -s /root/.ssh/authorized_keys ] && echo "File authorized keys does not exist or is empty."'
        Hostname = $Deployment.Hostname
        Credential = $credential
        ViHandle = $VIHandle
    }
    $createKeyPair = $(Invoke-ExecuteScript @params).Scriptoutput

    if ($createKeyPair) {
        # Create key pair for logining in to host without password.
        $commandList = $null
        $commandList = @()
        # Create and pemissions .ssh folder.
        $commandList += "mkdir /root/.ssh"
        $commandList += "chmod 700 /root/.ssh"
        # Create key pair for logining in to host without password.
        $commandList += "/usr/bin/ssh-keygen -t rsa -b 4096 -N `"`" -f /root/.ssh/" + $Deployment.Hostname + " -q"
        # Add public key to authorized_keys for root account and permission authorized_keys.
        $commandList += "cat /root/.ssh/" + $Deployment.Hostname + ".pub >> /root/.ssh/authorized_keys"
        $commandList += "chmod 600 /root/.ssh/authorized_keys"
        $params = @{
            Script = $commandList
            Hostname = $Deployment.Hostname
            Credential = $credential
            ViHandle = $VIHandle
        }
        Invoke-ExecuteScript @params

        # Copy private and public keys to deployment folder for host.
        $filePath = $null
        $filePath = @()
        $filePath += "/root/.ssh/" + $Deployment.Hostname
        $filePath += $certPath+ "\" + $Deployment.Hostname + ".priv"
        $filePath += "/root/.ssh/" + $Deployment.Hostname + ".pub"
        $filePath += $certPath+ "\" + $Deployment.Hostname + ".pub"
        $params = @{
            Path = $filePath
            Hostname = $Deployment.Hostname
            Credential = $credential
            VIHandle = $VIHandle
            Upload = $false
        }
        Copy-FileToServer @params

        # If there is no global private/public keys pair for the SSO domain hosts, create it.
        if (-not(Test-Path $($CertDir + "\" + $Deployment.SSODomainName + ".priv"))) {
            $commandList = $null
            $commandList = @()
            # Create key pair for logining in to host without password.
            $commandList += "/usr/bin/ssh-keygen -t rsa -b 4096 -N `"`" -f /root/.ssh/" + $Deployment.SSODomainName + " -q"
            # Add public key to authorized_keys for root account and permission authorized_keys.
            $commandList += "cat /root/.ssh/" + $Deployment.SSODomainName + ".pub >> /root/.ssh/authorized_keys"
            $params = @{
                Script = $commandList
                Hostname = $Deployment.Hostname
                Credential = $credential
                ViHandle = $VIHandle
            }
            Invoke-ExecuteScript @params

            $filePath = $null
            $filePath = @()
            $filePath += "/root/.ssh/" + $Deployment.SSODomainName
            $filePath += $CertDir + "\" + $Deployment.SSODomainName + ".priv"
            $filePath += "/root/.ssh/" + $Deployment.SSODomainName + ".pub"
            $filePath += $CertDir + "\" + $Deployment.SSODomainName + ".pub"
            $params = @{
                Path = $filePath
                Hostname = $Deployment.Hostname
                Credential = $credential
                VIHandle = $VIHandle
                Upload = $false
            }
            Copy-FileToServer @params
        } else {
            $filePath = $null
            $filePath = @()
            $filePath += $CertDir + "\" + $Deployment.SSODomainName + ".pub"
            $filePath += "/root/.ssh/" + $Deployment.SSODomainName + ".pub"
            $params = @{
                Path = $filePath
                Hostname = $Deployment.Hostname
                Credential = $credential
                VIHandle = $VIHandle
                Upload = $true
            }
            Copy-FileToServer @params
            $commandList = $null
            $commandList = @()
            # Add public cert to authorized keys.
            $commandList += "cat /root/.ssh/$($Deployment.SSODomainName).pub >> /root/.ssh/authorized_keys"
            $params = @{
                Script = $commandList
                Hostname = $Deployment.Hostname
                Credential = $credential
                ViHandle = $VIHandle
            }
            Invoke-ExecuteScript @params
        }
    }
}