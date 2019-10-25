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
	[cmdletbinding()]
	param (
		[Parameter(Mandatory=$true)]
		$CertDir,
		[Parameter(Mandatory=$true)]
		$CertInfo
	)

	# Create credential from username and password.
    if ($CertInfo.Username) {
        $secPassword = ConvertTo-SecureString $Certinfo.Password -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PSCredential ($CertInfo.Username, $secPassword)
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
    if ((Test-NetConnection -ComputerName $ca -Port 443 -ErrorAction Ignore -InformationLevel Quiet).TCPTestSucceeded) {
		$ssl = "https"
	} else {
		$ssl = "http"
	}

	# Set the URL to use HTTPS or HTTP based on previous test. (Note: The '-1' in Renewal=-1 indicates that it will download the current certificate.)
	$url = $ssl + ':' + "//$($ca)/certsrv/certnew.p7b?ReqID=CACert&Renewal=-1&Enc=DER"

	# If there are Credentials, use them otherwise try to download the certificate without them.
    if ($CertInfo.Username) {
        Invoke-WebRequest -Uri $url -OutFile "$CertDir\certnew.p7b" -Credential $credential
    } else {
        Invoke-WebRequest -Uri $url -OutFile "$CertDir\certnew.p7b"
    }

	# Define empty array.
  	$caCerts = @()

	# Call Invoke-OpenSSL to convert the p7b certificate to PEM and split the string on '-', then remove any zero length items.
	$p7bChain = (Invoke-OpenSSL "pkcs7 -inform PEM -outform PEM -in `"$CertDir\certnew.p7b`" -print_certs").Split("-") | Where-Object {$_.Length -gt 0}

	# Find the index of all the BEGIN CERTIFICATE lines.
	$index = (0..($p7bChain.count - 1)) | Where-Object {$p7bChain[$_] -match "BEGIN CERTIFICATE"}

	# Extract the Certificates and append the BEGIN CERTIFICATE and END CERTIFICATE lines.
	foreach ($i in $index) {
		$caCerts += $p7bChain[$i+1].insert($p7bChain[$i+1].length,'-----END CERTIFICATE-----').insert(0,'-----BEGIN CERTIFICATE-----')
	}

	# Save the PEM Chain certificate.
	$caCerts | Set-Content -Path "$CertDir\chain.cer" -Encoding ascii

	# Save the Root and Intermidiate Certificates.
	switch ($caCerts.Count)	{
		1	{	$caCerts[0] | Set-Content -Path "$CertDir\root64.cer"		-Encoding ascii}

		2	{	$caCerts[0] | Set-Content -Path "$CertDir\interm64.cer"		-Encoding ascii
				$caCerts[1] | Set-Content -Path "$CertDir\root64.cer"		-Encoding ascii}

		3	{	$caCerts[0] | Set-Content -Path "$CertDir\interm264.cer"	-Encoding ascii
				$caCerts[1] | Set-Content -Path "$CertDir\interm64.cer"		-Encoding ascii
				$caCerts[2] | Set-Content -Path "$CertDir\root64.cer"		-Encoding ascii}
	}
}