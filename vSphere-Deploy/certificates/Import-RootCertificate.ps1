function Import-RootCertificate {
    <#
    .SYNOPSIS
        Create PEM file for supplied certificate

    .DESCRIPTION

    .PARAMETER CertDir

    .PARAMETER CertInfo

    .EXAMPLE
        The example below shows the command line use with Parameters.

        Import-RootCertificate -CertDir < > -CertInfo < >

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
        $certDir,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        $certInfo
    )

    # Create credential from username and password.
    if ($certInfo.Username) {
        $secPassword = ConvertTo-SecureString -String $certInfo.Password -AsPlainText -Force
        $credential = New-Object -TypeName System.Management.Automation.PSCredential($certInfo.Username, $secPassword)
    }

    # Select the Certificate Authority furthest from Root to download the chain certificate from.
    if ($certInfo.SubCA2) {
        $ca = $certInfo.SubCA2
    } elseif ($certInfo.SubCA1) {
        $ca = $certInfo.SubCA1
    } else {
        $ca = $certInfo.RootCA
    }

    # Check to see if the CA is using TCP port 443 or 80.
    $params = @{
        computerName = $ca
        port = 443
        errorAction = "Ignore"
        informationLevel = "Quiet"
    }
    if ((Test-NetConnection @params).TCPTestSucceeded) {
        $ssl = "https"
    } else {
        $ssl = "http"
    }

    # Set the URL to use HTTPS or HTTP based on previous test. (Note: The '-1' in Renewal=-1 indicates that it will download the current certificate.)
    $url = $ssl + ':' + "//$($ca)/certsrv/certnew.p7b?ReqID=CACert&Renewal=-1&Enc=DER"

    # If there are Credentials, use them otherwise try to download the certificate without them.
    if ($certInfo.Username) {
        $params = @{
            uri = $url
            outFile = "$certDir\certnew.p7b"
            credential = $credential
        }
        Invoke-WebRequest @params
    } else {
        $params = @{
            uri = $url
            outFile = "$certDir\certnew.p7b"
        }
        Invoke-WebRequest @params
    }

    # Define empty array.
      $caCerts = @()

    # Call Invoke-OpenSSL to convert the p7b certificate to PEM and split the string on '-', then remove any zero length items.
    $p7bChain = (Invoke-OpenSSL -OpenSSLArgs "pkcs7 -inform PEM -outform PEM -in `"$certDir\certnew.p7b`" -print_certs").Split("-") | Where-Object {$_.Length -gt 0}

    # Find the index of all the BEGIN CERTIFICATE lines.
    $index = (0..($p7bChain.count - 1)) | Where-Object {$p7bChain[$_] -match "BEGIN CERTIFICATE"}

    # Extract the Certificates and append the BEGIN CERTIFICATE and END CERTIFICATE lines.
    ForEach ($i in $index) {
        $caCerts += $p7bChain[$i+1].insert($p7bChain[$i+1].length,'-----END CERTIFICATE-----').insert(0,'-----BEGIN CERTIFICATE-----')
    }

    # Save the PEM Chain certificate.
    $caCerts | Set-Content -Path "$certDir\chain.cer" -Encoding Ascii

    # Save the Root and Intermidiate Certificates.
    Switch ($caCerts.Count) {
        1    { $caCerts[0] | Set-Content -Path "$certDir\root64.cer" -Encoding Ascii}

        2    { $caCerts[0] | Set-Content -Path "$certDir\interm64.cer" -Encoding Ascii
              $caCerts[1] | Set-Content -Path "$certDir\root64.cer" -Encoding Ascii}

        3    { $caCerts[0] | Set-Content -Path "$certDir\interm264.cer" -Encoding Ascii
              $caCerts[1] | Set-Content -Path "$certDir\interm64.cer" -Encoding Ascii
              $caCerts[2] | Set-Content -Path "$certDir\root64.cer" -Encoding Ascii}
    }
}