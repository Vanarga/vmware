function New-VMCACSR {
    <#
    .SYNOPSIS
        Create RSA private key and CSR.

    .DESCRIPTION

    .EXAMPLE
        The example below shows the command line use with Parameters.

        New-VMCACSR

        PS C:\> New-VMCACSR

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - New-VMCACSR
    #>
    [CmdletBinding ()]
    Param ()
    # Create RSA private key and CSR
    $computerName = Get-WmiObject -Class Win32_ComputerSystem
    $defFQDN = "$($computerName.Name).$($computerName.Domain)".ToLower()
    $vpscFQDN = $(
        Write-Host -Object "Is the vCenter Platform Services Controller FQDN $defFQDN ?"
        $inputFQDN = Read-Host -Prompt "Press ENTER to accept or input a new PSC FQDN"
        if ($inputFQDN) {$inputFQDN} else {$defFQDN}
    )
    $requestTemplate = "[ req ]
    default_md = sha512
    default_bits = 2048
    default_keyfile = rui.key
    distinguished_name = req_distinguished_name
    encrypt_key = no
    prompt = no
    string_mask = nombstr
    req_extensions = v3_req

    [ v3_req ]
    basicConstraints = CA:TRUE

    [ req_distinguished_name ]
    countryName = $country
    stateOrProvinceName = $state
    localityName = $locality
    0.organizationName = $orgUnit
    commonName = $vspcFQDN
    "
    Set-Location $CertDir
    if (-not(Test-Path -Path "VMCA")) {
        New-Item -Path "VMCA" -Type Directory
    }
    # Create CSR and private key
    $out = $requestTemplate | Out-File -FilePath "$CertDir\VMCA\root_signing_cert.cfg" -Encoding default -Force
    Invoke-OpenSSL -OpenSSLArgs "req -new -nodes -out `"$CertDir\VMCA\root_signing_cert.csr`" -keyout `"$CertDir\VMCA\vmca-org.key`" -config `"$CertDir\VMCA\root_signing_cert.cfg`""
    Invoke-OpenSSL -OpenSSLArgs "rsa -in `"$CertDir\VMCA\vmca-org.key`" -out `"$CertDir\VMCA\root_signing_cert.key`""
    Remove-Item -Path "VMCA\vmca-org.key"
    Write-Host -Object "CSR is located at $CertDir\VMCA\root_signing_cert.csr" -ForegroundColor Yellow
}