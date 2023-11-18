function Invoke-VmcaCertificateMint {
    <#
    .SYNOPSIS
        This function issues a new SSL certificate from the VMCA.

    .DESCRIPTION
        This function issues a new SSL certificate from the VMCA.

    .PARAMETER SvcDir
        The mandatory string parameter SvcDir is the vmware service directory name and is used for the subfolder to place the certficates in.

    .PARAMETER CfgFile
        The mandatory string parameter CfgFile is the name of the configuration file.

    .PARAMETER CertFile
        The mandatory string parameter CertFile is the name of the certificate file.

    .PARAMETER PrivateFile
        The mandatory string parameter CertFile is the name of the certificate file.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Invoke-VmcaCertificateMint -SvcDir <String>
                                   -CfgFile <String>
                                   -CertFile <String>
                                   -PrivateFile <String>

        PS C:\> Invoke-VmcaCertificateMint

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Invoke-VmcaCertificateMint
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string]$SvcDir,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string]$CfgFile,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string]$CertFile,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string]$PrivateFile
    )

    if (-not(Test-Path -Path "$CertDir\$SvcDir")) {
        New-Item -Path "$CertDir\$SvcDir" -Type Directory
    }
    $computerName = Get-WmiObject -Class Win32_ComputerSystem
    $defFQDN = "$($computerName.name).$($computerName.domain)".ToLower()
    $machineFQDN = $(
        Write-Host -Object "Do you want to replace the SSL certificate on $defFQDN ?"
        $inputFQDN = Read-Host -Prompt "Press ENTER to accept or input a new FQDN"
        if ($inputFQDN) {$inputFQDN} else {$defFQDN}
    )
    $pscFQDN = $(
        Write-Host "Is the PSC $defFQDN ?"
        $inputFQDN = Read-Host -Prompt "Press ENTER to accept or input the correct PSC FQDN"
        if ($inputFQDN) {$inputFQDN} else {$defFQDN}
    )
    $machineIP = [System.Net.Dns]::GetHostAddresses("$machineFQDN").IPAddressToString -like '*.*'
    Write-Host -Object $machineIP
    $vmwTemplate = "
    #
    # Template file for a CSR request
    #
    # Country is needed and has to be 2 characters
    Country = $country
    Name = $companyName
    Organization = $orgName
    OrgUnit = $orgUnit
    State = $state
    Locality = $locality
    IPAddress = $machineIP
    Email = $email
    Hostname = $machineFQDN
    "
    $out = $vmwTemplate | Out-File -FilePath "$CertDir\$SvcDir\$CfgFile" -Encoding default -Force
    # Mint certificate from VMCA and save to disk
    Set-Location -Path "C:\Program Files\VMware\vCenter Server\vmcad"
    .\certool --genkey --privkey=$CertDir\$SvcDir\$PrivateFile --pubkey=$CertDir\$SvcDir\$SvcDir.pub
    .\certool --gencert --cert=$CertDir\$SvcDir\$CertFile --privkey=$CertDir\$SvcDir\$PrivateFile --config=$CertDir\$SvcDir\$CfgFile --server=$pscFQDN
    if (Test-Path -Path "$CertDir\$SvcDir\$CertFile") {
        Write-Host -Object "PEM file located at $CertDir\$SvcDir\new_machine.cer" -ForegroundColor Yellow
    }
}