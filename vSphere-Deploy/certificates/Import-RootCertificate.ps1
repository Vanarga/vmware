function Import-RootCertificate {
    <#
    .SYNOPSIS
        Downloads the CA root certificates and saves them to the root cert folders.

    .DESCRIPTION
        Downloads the CA root certificates and saves them to the root cert folders.

    .PARAMETER CertDir
        The mandatory string parameter CertDir is the local path to the location of the replacement certificates.

    .PARAMETER CertInfo
        The mandatory string array parameter CertInfo holds all the information to connect to the Certificate Authority.

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Import-RootCertificate -CertDir <String>
                               -CertInfo <String[]>

        PS C:\> Import-RootCertificate

    .NOTES
        Author: Michael van Blijdesteijn
        Last Edit: 2019-10-24
        Version 1.0 - Import-RootCertificate
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
            [string[]]$CertInfo
    )

    # Create credential from username and password.
    if ($CertInfo.Username) {
        $secPassword = ConvertTo-SecureString -String $CertInfo.Password -AsPlainText -Force
        $credential = New-Object -TypeName System.Management.Automation.PSCredential($CertInfo.Username, $secPassword)
    }

    # Select the Certificate Authority furthest from Root to download the chain certificate from.
    if ($CertInfo.SubCA2) {
        $ca = $CertInfo.SubCA2
    } elseif ($CertInfo.SubCA1) {
        $ca = $CertInfo.SubCA1
    } else {
        $ca = $CertInfo.RootCA
    }

    # Check to see if the CA is using TCP port 443 or 80.
    $params = @{
        ComputerName = $ca
        Port = 443
        ErrorAction = "Ignore"
        InformationLevel = "Quiet"
    }
    if ((Test-NetConnection @params).TCPTestSucceeded) {
        $ssl = "https"
    } else {
        $ssl = "http"
    }

    # Set the URL to use HTTPS or HTTP based on previous test. (Note: The '-1' in Renewal=-1 indicates that it will download the current certificate.)
    $Url = $ssl + ':' + "//$($ca)/certsrv/certnew.p7b?ReqID=CACert&Renewal=-1&Enc=DER"

    # If there are Credentials, use them otherwise try to download the certificate without them.
    if ($CertInfo.Username) {
        $params = @{
            Uri = $Url
            OutFile = "$CertDir\certnew.p7b"
            Credential = $credential
        }
        Invoke-WebRequest @params
    } else {
        $params = @{
            Uri = $Url
            OutFile = "$CertDir\certnew.p7b"
        }
        Invoke-WebRequest @params
    }

    # Define empty array.
      $caCerts = @()

    # Call Invoke-OpenSsl to convert the p7b certificate to PEM and split the string on '-', then remove any zero length items.
    $p7bChain = (Invoke-OpenSsl -OpenSslArgs "pkcs7 -inform PEM -outform PEM -in `"$CertDir\certnew.p7b`" -print_certs").Split("-") | Where-Object {$_.Length -gt 0}

    # Find the index of all the BEGIN CERTIFICATE lines.
    $index = (0..($p7bChain.count - 1)) | Where-Object {$p7bChain[$_] -match "BEGIN CERTIFICATE"}

    # Extract the Certificates and append the BEGIN CERTIFICATE and END CERTIFICATE lines.
    ForEach ($i in $index) {
        $caCerts += $p7bChain[$i+1].insert($p7bChain[$i+1].length,'-----END CERTIFICATE-----').insert(0,'-----BEGIN CERTIFICATE-----')
    }

    # Save the PEM Chain certificate.
    $caCerts | Set-Content -Path "$CertDir\chain.cer" -Encoding Ascii

    # Save the Root and Intermidiate Certificates.
    Switch ($caCerts.Count) {
        1    { $caCerts[0] | Set-Content -Path "$CertDir\root64.cer" -Encoding Ascii}

        2    { $caCerts[0] | Set-Content -Path "$CertDir\interm64.cer" -Encoding Ascii
              $caCerts[1] | Set-Content -Path "$CertDir\root64.cer" -Encoding Ascii}

        3    { $caCerts[0] | Set-Content -Path "$CertDir\interm264.cer" -Encoding Ascii
              $caCerts[1] | Set-Content -Path "$CertDir\interm64.cer" -Encoding Ascii
              $caCerts[2] | Set-Content -Path "$CertDir\root64.cer" -Encoding Ascii}
    }
}