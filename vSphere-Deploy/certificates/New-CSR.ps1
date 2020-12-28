function New-CSR {
    <#
    .SYNOPSIS
        Create RSA private key and CSR for vSphere 6.0 SSL templates.

    .DESCRIPTION

    .PARAMETER SVCDir

    .PARAMETER CSRName

    .PARAMETER CFGName

    .PARAMETER PrivFile

    .PARAMETER Flag

    .PARAMETER CertDir

    .PARAMETER Certinfo

    .EXAMPLE
        The example below shows the command line use with Parameters.

        New-CSR -SVCDir < > -CSRName < > -CFGName < > -PrivFile < > -Flag < > -CertDir < > -Certinfo < >

        PS C:\> New-CSR

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - New-CSR
    #>
    [cmdletbinding()]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $SVCDir,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $CSRName,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $CFGName,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $PrivFile,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $Flag,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $CertDir,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $Certinfo
    )

    if (-not(Test-Path -Path "$CertDir\$SVCDir")) {
        New-Item -Path "$CertDir\$SVCDir" -Type Directory
    }
    # vSphere 5 and 6 CSR Options are different. Set according to flag type
    # VUM 6.0 needs vSphere 5 template type
    if ($Flag -eq 5) {
        $csrOption1 = "dataEncipherment"
    }
    if ($Flag -eq 6) {
        $csrOption1 = "nonRepudiation"
    }
    $defFQDN = $Certinfo.CompanyName
    $commonName = $CSRName.Split(".")[0] + " " + $Certinfo.CompanyName
    $machineShort = $defFQDN.Split(".")[0]
    $machineIP = [System.Net.Dns]::GetHostAddresses("$defFQDN").IPAddressToString
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
    basicConstraints = CA:FALSE
    keyUsage = digitalSignature, keyEncipherment, $csrOption1
    subjectAltName = IP:$machineIP,DNS:$defFQDN,DNS:$machineShort

    [ req_distinguished_name ]
    countryName = $($Certinfo.Country)
    stateOrProvinceName = $($Certinfo.State)
    localityName = $($Certinfo.Locality)
    0.organizationName = $($Certinfo.OrgName)
    organizationalUnitName = $($Certinfo.OrgUnit)
    commonName = $commonName
    "
    Set-Location $CertDir
    if (-not(Test-Path -Path $SVCDir)) {
        New-Item -Path "Machine" -Type Directory
    }
    # Create CSR and private key
    $out = $requestTemplate | Out-File -FilePath "$CertDir\$SVCDir\$CFGName" -Encoding default -Force
    Invoke-OpenSSL -OpenSSLArgs "req -new -nodes -out `"$CertDir\$SVCDir\$CSRName`" -keyout `"$CertDir\$SVCDir\$CSRName.key`" -config `"$CertDir\$SVCDir\$CFGName`""
    Invoke-OpenSSL -OpenSSLArgs "rsa -in `"$CertDir\$SVCDir\$CSRName.key`" -out `"$CertDir\$SVCDir\$PrivFile`""
    Remove-Item -Path "$SVCDir\$CSRName.key"
    Write-Host -Object "CSR is located at $CertDir\$SVCDir\$CSRName" -ForegroundColor Yellow
}