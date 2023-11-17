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
        $servicePath,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $csrName,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $configName,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $privateFile,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $flag,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $solutionUser,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $certPath,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $certInfo
    )

    if (-not(Test-Path -Path "$certPath\$servicePath")) {
        New-Item -Path "$certPath\$servicePath" -Type Directory
    }
    # vSphere 5 and 6 CSR Options are different. Set according to flag type
    # VUM 6.0 needs vSphere 5 template type
    $commonName = $csrName.Split(".")[0] + " " + $certInfo.CompanyName
    if ($flag -eq 5) {
        $csrOption1 = "dataEncipherment"
    }
    if ($flag -eq 6) {
        $csrOption1 = "nonRepudiation"
    }
    $defFQDN = $certInfo.CompanyName
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
    countryName = $($certInfo.Country)
    stateOrProvinceName = $($certInfo.State)
    localityName = $($certInfo.Locality)
    0.organizationName = $($certInfo.OrgName)
    organizationalUnitName = $($certInfo.OrgUnit)
    commonName = $commonName
    "
    Set-Location -Path $certPath
    if (-not(Test-Path -Path $servicePath)) {
        New-Item -Path "Machine" -Type Directory
    }
    # Create CSR and private key
    $out = $requestTemplate | Out-File -FilePath "$certPath\$servicePath\$configName" -Encoding default -Force
    Invoke-OpenSSL -OpenSSLArgs "req -new -nodes -out `"$certPath\$servicePath\$csrName`" -keyout `"$certPath\$servicePath\$csrName.key`" -config `"$certPath\$servicePath\$configName`""
    Invoke-OpenSSL -OpenSSLArgs "rsa -in `"$certPath\$servicePath\$csrName.key`" -out `"$certPath\$servicePath\$privateFile`""
    Remove-Item -Path "$servicePath\$csrName.key"
    Write-Host -Object "CSR is located at $certPath\$servicePath\$csrName" -ForegroundColor Yellow
}