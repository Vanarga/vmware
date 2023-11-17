function New-SolutionCSR {
    <#
    .SYNOPSIS
        Create RSA private key and CSR for vSphere 6.0 SSL templates

    .DESCRIPTION

    .PARAMETER SVCDir

    .PARAMETER CSRName

    .PARAMETER CFGName

    .PARAMETER PrivFile

    .PARAMETER Flag

    .PARAMETER SolutionUser

    .PARAMETER CertDir

    .PARAMETER Certinfor

    .EXAMPLE
        The example below shows the command line use with Parameters.

        New-SolutionCSR -SVCDir < > -CSRName < > -CFGName < > -PrivFile < > -Flag < > -SolutionUser < > -CertDir < > -Certinfor < >

        PS C:\> New-SolutionCSR

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - New-SolutionCSR
    #>
    [CmdletBinding ()]
    Param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $SvcDir,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $CsrName,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $CfgName,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $PrivateFile,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $Flag,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $SolutionUser,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $CertDir,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $CertInfo
    )

    if (-not(Test-Path -Path "$CertDir\$SvcDir")) {
        New-Item -Path "$CertDir\$SvcDir" -Type Directory
    }
    # vSphere 5 and 6 CSR Options are different. Set according to flag type
    # VUM 6.0 needs vSphere 5 template type
    $commonName = $CsrName.Split(".")[0] + " " + $CertInfo.CompanyName
    if ($Flag -eq 5) {
        $csrOption1 = "dataEncipherment"
    }
    if ($Flag -eq 6) {
        $csrOption1 = "nonRepudiation"
    }
    $defFQDN = $CertInfo.CompanyName
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
    countryName = $($CertInfo.Country)
    stateOrProvinceName = $($CertInfo.State)
    localityName = $($CertInfo.Locality)
    0.organizationName = $($CertInfo.OrgName)
    organizationalUnitName = $($CertInfo.OrgUnit)
    commonName = $commonName
    "
    Set-Location -Path $CertDir
    if (-not(Test-Path -Path $SvcDir)) {
        New-Item -Path "Machine" -Type Directory
    }
    # Create CSR and private key
    $out = $requestTemplate | Out-File -FilePath "$CertDir\$SvcDir\$CfgName" -Encoding default -Force
    Invoke-OpenSSL -OpenSSLArgs "req -new -nodes -out `"$CertDir\$SvcDir\$CsrName`" -keyout `"$CertDir\$SvcDir\$CsrName.key`" -config `"$CertDir\$SvcDir\$CfgName`""
    Invoke-OpenSSL -OpenSSLArgs "rsa -in `"$CertDir\$SvcDir\$CsrName.key`" -out `"$CertDir\$SvcDir\$PrivateFile`""
    Remove-Item -Path "$SvcDir\$CsrName.key"
    Write-Host -Object "CSR is located at $CertDir\$SvcDir\$CsrName" -ForegroundColor Yellow
}