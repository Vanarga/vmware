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
        $SVCDir,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $CFGFile,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $CertFile,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $PrivFile
    )

    if (-not(Test-Path -Path "$CertDir\$SVCDir")) {
        New-Item -Path "$CertDir\$SVCDir" -Type Directory
    }
    $computerName = Get-WmiObject -Class Win32_ComputerSystem
    $defFQDN = "$($computerName.name).$($computerName.domain)".ToLower()
    $machineFQDN = $(
        Write-Host -Object "Do you want to replace the SSL certificate on $defFQDN ?"
        $InputFQDN = Read-Host -Prompt "Press ENTER to accept or input a new FQDN"
        if ($InputFQDN) {$InputFQDN} else {$defFQDN}
    )
    $pscFQDN = $(
        Write-Host "Is the PSC $defFQDN ?"
        $InputFQDN = Read-Host -Prompt "Press ENTER to accept or input the correct PSC FQDN"
        if ($InputFQDN) {$InputFQDN} else {$defFQDN}
    )
    $machineIP = [System.Net.Dns]::GetHostAddresses("$machineFQDN").IPAddressToString -like '*.*'
    Write-Host -Object $machineIP
    $VMWTemplate = "
    #
    # Template file for a CSR request
    #
    # Country is needed and has to be 2 characters
    Country = $Country
    Name = $CompanyName
    Organization = $OrgName
    OrgUnit = $OrgUnit
    State = $State
    Locality = $Locality
    IPAddress = $MachineIP
    Email = $email
    Hostname = $machineFQDN
    "
    $out = $VMWTemplate | Out-File -FilePath "$CertDir\$SVCDir\$CFGFile" -Encoding default -Force
    # Mint certificate from VMCA and save to disk
    Set-Location -Path "C:\Program Files\VMware\vCenter Server\vmcad"
    .\certool --genkey --privkey=$CertDir\$SVCDir\$PrivFile --pubkey=$CertDir\$SVCDir\$SVCDir.pub
    .\certool --gencert --cert=$CertDir\$SVCDir\$CertFile --privkey=$CertDir\$SVCDir\$PrivFile --config=$CertDir\$SVCDir\$CFGFile --server=$pscFQDN
    if (Test-Path -Path "$CertDir\$SVCDir\$CertFile") {
        Write-Host -Object "PEM file located at $CertDir\$SVCDir\new_machine.cer" -ForegroundColor Yellow
    }
}