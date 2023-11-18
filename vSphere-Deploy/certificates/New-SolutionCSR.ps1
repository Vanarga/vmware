function New-SolutionCsr {
    <#
    .SYNOPSIS
        Create RSA private key and CSR for vSphere 6.0 SSL templates.

    .DESCRIPTION
        Create RSA private key and CSR for vSphere 6.0 SSL templates.

    .PARAMETER SvcDir
        The mandatory string parameter SvcDir is the vmware service directory name and is used for the subfolder to place the certficates in.

    .PARAMETER CsrFile
        The mandatory string parameter CsrFile is the CSR filename.

    .PARAMETER CfgFile
        The mandatory string parameter CfgFile is the configuration filename.

    .PARAMETER PrivateFile
        The mandatory string parameter CertFile is the name of the certificate file.

    .PARAMETER Flag
        The mandatory integer parameter Flag determines the template for vSphere 5 or 6.

    .PARAMETER CertDir
        The mandatory string parameter CertDir is the local path to the location of the replacement certificates.

    .PARAMETER CertInfo
        The mandatory string array parameter CertInfo holds all the information to connect to the Certificate Authority.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        New-SolutionCsr -SvcDir <String>
                        -CsrFile <String>
                        -CfgFile <String>
                        -PrivateFile <String>
                        -Flag <Int>
                        -CertDir <String>
                        -CertInfo <String[]>

        PS C:\> New-SolutionCsr

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - New-SolutionCsr
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
            [string]$CsrFile,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string]$CfgFile,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string]$PrivateFile,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [int]$Flag,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string]$CertDir,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
            [string[]]$CertInfo
    )

    if (-not(Test-Path -Path "$CertDir\$SvcDir")) {
        New-Item -Path "$CertDir\$SvcDir" -Type Directory
    }
    # vSphere 5 and 6 CSR Options are different. Set according to flag type
    # VUM 6.0 needs vSphere 5 template type
    $commonName = $CsrFile.Split(".")[0] + " " + $CertInfo.CompanyName
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
    $out = $requestTemplate | Out-File -FilePath "$CertDir\$SvcDir\$CfgFile" -Encoding default -Force
    Invoke-OpenSSL -OpenSSLArgs "req -new -nodes -out `"$CertDir\$SvcDir\$CsrFile`" -keyout `"$CertDir\$SvcDir\$CsrFile.key`" -config `"$CertDir\$SvcDir\$CfgFile`""
    Invoke-OpenSSL -OpenSSLArgs "rsa -in `"$CertDir\$SvcDir\$CsrFile.key`" -out `"$CertDir\$SvcDir\$PrivateFile`""
    Remove-Item -Path "$SvcDir\$CsrFile.key"
    Write-Host -Object "CSR is located at $CertDir\$SvcDir\$CsrFile" -ForegroundColor Yellow
}