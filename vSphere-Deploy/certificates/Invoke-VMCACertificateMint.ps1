function Invoke-VMCACertificateMint {
    <#
    .SYNOPSIS
        This function issues a new SSL certificate from the VMCA.

    .DESCRIPTION

    .PARAMETER SVCDir

    .PARAMETER CFGFile

    .PARAMETER CertFile

    .PARAMETER PrivFile

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Invoke-VMCACertificateMint -SVCDir < > -CFGFile < > -CertFile < > -PrivFile < >

        PS C:\> Invoke-VMCACertificateMint

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Invoke-VMCACertificateMint
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $servicePath,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $configFile,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $certFile,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $privateFile
    )

    if (-not(Test-Path -Path "$certPath\$servicePath")) {
        New-Item -Path "$certPath\$servicePath" -Type Directory
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
    $out = $vmwTemplate | Out-File -FilePath "$certPath\$servicePath\$configFile" -Encoding default -Force
    # Mint certificate from VMCA and save to disk
    Set-Location -Path "C:\Program Files\VMware\vCenter Server\vmcad"
    .\certool --genkey --privkey=$certPath\$servicePath\$privateFile --pubkey=$certPath\$servicePath\$servicePath.pub
    .\certool --gencert --cert=$certPath\$servicePath\$certFile --privkey=$certPath\$servicePath\$privateFile --config=$certPath\$servicePath\$configFile --server=$pscFQDN
    if (Test-Path -Path "$certPath\$servicePath\$certFile") {
        Write-Host -Object "PEM file located at $certPath\$servicePath\new_machine.cer" -ForegroundColor Yellow
    }
}