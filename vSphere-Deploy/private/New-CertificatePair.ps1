function New-CertificatePair {
    <#
    .SYNOPSIS
        Configure Private/Public Keys for ssh authentication without password.

    .DESCRIPTION
        Configure Private/Public Keys for ssh authentication without password.

    .PARAMETER CertDir
        The mandatory string parameter CertDir is the local path to the location of the replacement certificates.

    .PARAMETER Deployment
        The mandatory parameter Deployment contains all the settings for a specific vSphere node deployement.

    .PARAMETER ViHandle
        The mandatory parameter ViHandle is the session connection information for the vSphere node.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        New-CertificatePair -CertDir <String>
                            -Deployment <String[]>
                            -ViHandle <VI Session>

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
            [string]$CertDir,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [stringp[]]$Deployment,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            $ViHandle
    )

    $CertDir = $CertDir + "\" + $Deployment.Hostname
    $credential = New-Object -TypeName System.Management.Automation.PSCredential("root", [securestring](ConvertTo-SecureString -String $Deployment.VCSARootPass -AsPlainText -Force))

    $params = @{
        Script = '[ ! -s /root/.ssh/authorized_keys ] && echo "File authorized keys does not exist or is empty."'
        Hostname = $Deployment.Hostname
        Credential = $credential
        ViHandle = $ViHandle
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
            ViHandle = $ViHandle
        }
        Invoke-ExecuteScript @params

        # Copy private and public keys to deployment folder for host.
        $FilePath = $null
        $FilePath = @()
        $FilePath += "/root/.ssh/" + $Deployment.Hostname
        $FilePath += $CertDir+ "\" + $Deployment.Hostname + ".priv"
        $FilePath += "/root/.ssh/" + $Deployment.Hostname + ".pub"
        $FilePath += $CertDir+ "\" + $Deployment.Hostname + ".pub"
        $params = @{
            Path = $FilePath
            Hostname = $Deployment.Hostname
            Credential = $credential
            ViHandle = $ViHandle
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
                ViHandle = $ViHandle
            }
            Invoke-ExecuteScript @params

            $FilePath = $null
            $FilePath = @()
            $FilePath += "/root/.ssh/" + $Deployment.SSODomainName
            $FilePath += $CertDir + "\" + $Deployment.SSODomainName + ".priv"
            $FilePath += "/root/.ssh/" + $Deployment.SSODomainName + ".pub"
            $FilePath += $CertDir + "\" + $Deployment.SSODomainName + ".pub"
            $params = @{
                Path = $FilePath
                Hostname = $Deployment.Hostname
                Credential = $credential
                ViHandle = $ViHandle
                Upload = $false
            }
            Copy-FileToServer @params
        } else {
            $FilePath = $null
            $FilePath = @()
            $FilePath += $CertDir + "\" + $Deployment.SSODomainName + ".pub"
            $FilePath += "/root/.ssh/" + $Deployment.SSODomainName + ".pub"
            $params = @{
                Path = $FilePath
                Hostname = $Deployment.Hostname
                Credential = $credential
                ViHandle = $ViHandle
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
                ViHandle = $ViHandle
            }
            Invoke-ExecuteScript @params
        }
    }
}